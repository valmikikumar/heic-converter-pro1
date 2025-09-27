import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:photo_view/photo_view.dart';
import 'dart:io';
import '../services/heic_converter.dart';
import '../utils/app_constants.dart';

class ResultScreen extends StatefulWidget {
  final List<String> convertedFiles;
  final String outputFormat;

  const ResultScreen({
    super.key,
    required this.convertedFiles,
    required this.outputFormat,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final HEICConverterService _converterService = HEICConverterService();
  int _selectedImageIndex = 0;

  void _showSuccessMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text(AppConstants.successConversionComplete),
          ],
        ),
        backgroundColor: AppConstants.successColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _openFolder() {
    // In a real implementation, this would open the file manager
    // to the output folder
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Files saved to /Documents/HEIC-Converter'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _shareAllFiles() async {
    try {
      final files = widget.convertedFiles
          .map((path) => XFile(path))
          .toList();

      await Share.shareXFiles(
        files,
        text: 'Converted HEIC files using ${AppConstants.appName}',
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sharing files: $e')),
      );
    }
  }

  Future<void> _shareSingleFile(int index) async {
    try {
      final file = XFile(widget.convertedFiles[index]);
      await Share.shareXFiles([file]);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sharing file: $e')),
      );
    }
  }

  Future<void> _deleteFile(int index) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete File'),
        content: const Text('Are you sure you want to delete this file?'),
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
      final success = await _converterService.deleteFile(widget.convertedFiles[index]);
      if (success) {
        setState(() {
          widget.convertedFiles.removeAt(index);
          if (_selectedImageIndex >= widget.convertedFiles.length) {
            _selectedImageIndex = widget.convertedFiles.length - 1;
          }
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('File deleted successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete file')),
        );
      }
    }
  }

  void _copyFilePath(int index) {
    final path = widget.convertedFiles[index];
    Clipboard.setData(ClipboardData(text: path));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('File path copied to clipboard')),
    );
  }

  void _showImageViewer(int index) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _ImageViewerScreen(
          imagePath: widget.convertedFiles[index],
          fileName: widget.convertedFiles[index].split('/').last,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _showSuccessMessage();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conversion Complete'),
        leading: IconButton(
          icon: const Icon(Icons.home),
          onPressed: () => context.go(AppConstants.homeRoute),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareAllFiles,
            tooltip: 'Share All',
          ),
        ],
      ),
      body: widget.convertedFiles.isEmpty
          ? _buildEmptyState()
          : Column(
              children: [
                // Success header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppConstants.defaultPadding),
                  decoration: BoxDecoration(
                    color: AppConstants.successColor.withOpacity(0.1),
                    border: Border(
                      bottom: BorderSide(
                        color: theme.colorScheme.outline.withOpacity(0.2),
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: AppConstants.successColor,
                        size: 32,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppConstants.successConversionComplete,
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: AppConstants.successColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '${widget.convertedFiles.length} file(s) converted to ${widget.outputFormat.toUpperCase()}',
                              style: theme.textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Action buttons
                Padding(
                  padding: const EdgeInsets.all(AppConstants.defaultPadding),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _openFolder,
                          icon: const Icon(Icons.folder_open),
                          label: const Text('Open Folder'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _shareAllFiles,
                          icon: const Icon(Icons.share),
                          label: const Text('Share All'),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Image grid
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(AppConstants.defaultPadding),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: 1,
                    ),
                    itemCount: widget.convertedFiles.length,
                    itemBuilder: (context, index) {
                      return _buildImageThumbnail(index);
                    },
                  ),
                ),
              ],
            ),
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
              Icons.image_not_supported,
              size: 80,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 24),
            Text(
              'No converted files',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Something went wrong during conversion',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => context.go(AppConstants.homeRoute),
              icon: const Icon(Icons.home),
              label: const Text('Back to Home'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageThumbnail(int index) {
    final theme = Theme.of(context);
    final filePath = widget.convertedFiles[index];
    final fileName = filePath.split('/').last;
    
    return GestureDetector(
      onTap: () => _showImageViewer(index),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Image thumbnail
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: FileImage(File(filePath)),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            
            // Overlay with file info
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Text(
                  fileName,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            
            // Action menu
            Positioned(
              top: 4,
              right: 4,
              child: PopupMenuButton<String>(
                icon: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Icon(
                    Icons.more_vert,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                onSelected: (value) {
                  switch (value) {
                    case 'share':
                      _shareSingleFile(index);
                      break;
                    case 'copy':
                      _copyFilePath(index);
                      break;
                    case 'delete':
                      _deleteFile(index);
                      break;
                  }
                },
                itemBuilder: (context) => [
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
                    value: 'copy',
                    child: Row(
                      children: [
                        Icon(Icons.copy, size: 20),
                        SizedBox(width: 8),
                        Text('Copy Path'),
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
            ),
          ],
        ),
      ),
    );
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
