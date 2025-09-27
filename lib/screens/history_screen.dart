import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:photo_view/photo_view.dart';
import 'dart:io';
import '../services/storage_service.dart';
import '../services/heic_converter.dart';
import '../models/converted_file.dart';
import '../utils/app_constants.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final StorageService _storageService = StorageService();
  final HEICConverterService _converterService = HEICConverterService();
  
  List<ConvertedFile> _convertedFiles = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    
    try {
      final files = _storageService.getAllConvertedFiles();
      setState(() {
        _convertedFiles = files;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading history: $e')),
        );
      }
    }
  }

  List<ConvertedFile> get _filteredFiles {
    var files = _convertedFiles;
    
    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      files = files.where((file) =>
          file.fileName.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }
    
    // Apply format filter
    if (_selectedFilter != 'all') {
      files = files.where((file) => file.outputFormat == _selectedFilter).toList();
    }
    
    return files;
  }

  Future<void> _deleteFile(ConvertedFile file) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete File'),
        content: Text('Are you sure you want to delete "${file.fileName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        // Delete from storage
        await _storageService.deleteConvertedFile(file);
        
        // Delete physical file
        await _converterService.deleteFile(file.convertedPath);
        
        // Reload history
        await _loadHistory();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('File deleted successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete file: $e')),
          );
        }
      }
    }
  }

  Future<void> _shareFile(ConvertedFile file) async {
    try {
      final xFile = XFile(file.convertedPath);
      await Share.shareXFiles([xFile], text: 'Converted with ${AppConstants.appName}');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sharing file: $e')),
        );
      }
    }
  }

  void _showFileDetails(ConvertedFile file) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.outline,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'File Details',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailItem('File Name', file.fileName),
                      _buildDetailItem('Original Format', 'HEIC'),
                      _buildDetailItem('Output Format', file.outputFormat.toUpperCase()),
                      _buildDetailItem('Converted Date', _formatDate(file.convertedAt)),
                      _buildDetailItem('Original Size', file.originalSizeFormatted),
                      _buildDetailItem('Converted Size', file.fileSizeFormatted),
                      _buildDetailItem('Compression', '${file.compressionRatio.toStringAsFixed(1)}%'),
                      _buildDetailItem('Resize', '${file.resizePercentage.toInt()}%'),
                      _buildDetailItem('EXIF Preserved', file.keepExif ? 'Yes' : 'No'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _shareFile(file),
                      icon: const Icon(Icons.share),
                      label: const Text('Share'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showImageViewer(file),
                      icon: const Icon(Icons.visibility),
                      label: const Text('View'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  void _showImageViewer(ConvertedFile file) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _ImageViewerScreen(
          imagePath: file.convertedPath,
          fileName: file.fileName,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filteredFiles = _filteredFiles;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conversion History'),
        leading: IconButton(
          icon: const Icon(Icons.home),
          onPressed: () => context.go(AppConstants.homeRoute),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadHistory,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and filter bar
          Container(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Column(
              children: [
                // Search bar
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search files...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    isDense: true,
                  ),
                  onChanged: (value) {
                    setState(() => _searchQuery = value);
                  },
                ),
                
                const SizedBox(height: 12),
                
                // Filter chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('all', 'All'),
                      const SizedBox(width: 8),
                      ...AppConstants.supportedOutputFormats.map(
                        (format) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _buildFilterChip(format, format.toUpperCase()),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Statistics
          if (_convertedFiles.isNotEmpty)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding),
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem('Files', _convertedFiles.length.toString()),
                  _buildStatItem('Total Saved', _getTotalSpaceSaved()),
                  _buildStatItem('Avg Compression', _getAverageCompression()),
                ],
              ),
            ),
          
          const SizedBox(height: 16),
          
          // Files list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredFiles.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppConstants.defaultPadding,
                        ),
                        itemCount: filteredFiles.length,
                        itemBuilder: (context, index) {
                          final file = filteredFiles[index];
                          return _buildFileCard(file);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String value, String label) {
    final isSelected = _selectedFilter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => _selectedFilter = selected ? value : 'all');
      },
    );
  }

  Widget _buildStatItem(String label, String value) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onPrimaryContainer,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.largePadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 80,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 24),
            Text(
              _searchQuery.isNotEmpty || _selectedFilter != 'all'
                  ? 'No files found'
                  : 'No conversion history',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isNotEmpty || _selectedFilter != 'all'
                  ? 'Try adjusting your search or filter'
                  : 'Convert some HEIC files to see them here',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            if (_searchQuery.isEmpty && _selectedFilter == 'all') ...[
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () => context.go(AppConstants.filePickerRoute),
                icon: const Icon(Icons.add_photo_alternate),
                label: const Text('Convert Files'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFileCard(ConvertedFile file) {
    final theme = Theme.of(context);
    final fileExists = File(file.convertedPath).existsSync();
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: theme.colorScheme.surfaceVariant,
          ),
          child: fileExists
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(file.convertedPath),
                    fit: BoxFit.cover,
                  ),
                )
              : Icon(
                  Icons.broken_image,
                  color: theme.colorScheme.outline,
                ),
        ),
        title: Text(
          file.fileName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${file.outputFormat.toUpperCase()} • ${file.fileSizeFormatted} • ${_formatDate(file.convertedAt)}',
              style: theme.textTheme.bodySmall,
            ),
            if (file.keepExif)
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'EXIF Preserved',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontSize: 10,
                  ),
                ),
              ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'view':
                _showFileDetails(file);
                break;
              case 'share':
                _shareFile(file);
                break;
              case 'delete':
                _deleteFile(file);
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'view',
              child: Row(
                children: [
                  Icon(Icons.visibility, size: 20),
                  SizedBox(width: 8),
                  Text('View Details'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'share',
              child: Row(
                children: [
                  Icon(Icons.share, size: 20),
                  SizedBox(width: 8),
                  Text('Share'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 20),
                  SizedBox(width: 8),
                  Text('Delete'),
                ],
              ),
            ),
          ],
        ),
        onTap: () => _showFileDetails(file),
      ),
    );
  }

  String _getTotalSpaceSaved() {
    final totalSaved = _convertedFiles.fold<int>(
      0,
      (sum, file) => sum + (file.originalSize - file.convertedSize),
    );
    
    if (totalSaved < 1024) {
      return '${totalSaved}B';
    } else if (totalSaved < 1024 * 1024) {
      return '${(totalSaved / 1024).toStringAsFixed(1)}KB';
    } else {
      return '${(totalSaved / (1024 * 1024)).toStringAsFixed(1)}MB';
    }
  }

  String _getAverageCompression() {
    if (_convertedFiles.isEmpty) return '0%';
    
    final totalCompression = _convertedFiles.fold<double>(
      0,
      (sum, file) => sum + file.compressionRatio,
    );
    
    return '${(totalCompression / _convertedFiles.length).toStringAsFixed(1)}%';
  }
}

class _ImageViewerScreen extends StatelessWidget {
  final String imagePath;
  final String fileName;

  const _ImageViewerScreen({
    required this.imagePath,
    required this.fileName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(fileName),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.black,
      body: PhotoView(
        imageProvider: FileImage(File(imagePath)),
        minScale: PhotoViewComputedScale.contained,
        maxScale: PhotoViewComputedScale.covered * 2,
        backgroundDecoration: const BoxDecoration(color: Colors.black),
      ),
    );
  }
}
