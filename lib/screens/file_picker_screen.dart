import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/heic_converter.dart';
import '../services/storage_service.dart';
import '../utils/app_constants.dart';

class FilePickerScreen extends StatefulWidget {
  const FilePickerScreen({super.key});

  @override
  State<FilePickerScreen> createState() => _FilePickerScreenState();
}

class _FilePickerScreenState extends State<FilePickerScreen> {
  final HEICConverterService _converterService = HEICConverterService();
  final StorageService _storageService = StorageService();
  
  List<String> _selectedFiles = [];
  String _outputFormat = AppConstants.defaultOutputFormat;
  bool _keepExif = AppConstants.defaultKeepExif;
  double _resizePercentage = AppConstants.defaultResizePercentage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    _outputFormat = _storageService.getDefaultOutputFormat();
    _keepExif = _storageService.getKeepExifByDefault();
    _resizePercentage = _storageService.getDefaultResizePercentage();
  }

  Future<void> _pickFiles() async {
    try {
      // Request storage permission
      final status = await Permission.storage.request();
      if (status != PermissionStatus.granted) {
        _showPermissionDialog();
        return;
      }

      setState(() => _isLoading = true);

      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: AppConstants.supportedInputFormats,
        allowMultiple: true,
        withData: false,
        withReadStream: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final selectedPaths = result.files
            .map((file) => file.path!)
            .where((path) => _converterService.isSupportedFormat(path))
            .toList();

        setState(() {
          _selectedFiles = selectedPaths;
          _isLoading = false;
        });

        if (_selectedFiles.isEmpty) {
          _showUnsupportedFormatDialog();
        }
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorDialog('Failed to pick files: $e');
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permission Required'),
        content: const Text(
          'This app needs storage permission to access your HEIC files. '
          'Please grant permission in settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  void _showUnsupportedFormatDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unsupported Format'),
        content: Text(
          'Please select HEIC or HEIF files only. '
          'Supported formats: ${AppConstants.supportedInputFormats.join(', ')}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _startConversion() {
    if (_selectedFiles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one file')),
      );
      return;
    }

    context.go(AppConstants.conversionProgressRoute, extra: {
      'files': _selectedFiles,
      'outputFormat': _outputFormat,
      'keepExif': _keepExif,
      'resizePercentage': _resizePercentage,
    });
  }

  void _removeFile(int index) {
    setState(() {
      _selectedFiles.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Files'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppConstants.homeRoute),
        ),
      ),
      body: Column(
        children: [
          // Selected files section
          Expanded(
            flex: _selectedFiles.isEmpty ? 3 : 2,
            child: _selectedFiles.isEmpty
                ? _buildEmptyState()
                : _buildSelectedFilesList(),
          ),
          
          // Options panel
          if (_selectedFiles.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                border: Border(
                  top: BorderSide(
                    color: theme.colorScheme.outline.withOpacity(0.2),
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Conversion Options',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildOptionsPanel(),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _startConversion,
                      icon: const Icon(Icons.transform),
                      label: Text('Convert ${_selectedFiles.length} file(s)'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      floatingActionButton: _selectedFiles.isEmpty
          ? FloatingActionButton.extended(
              onPressed: _isLoading ? null : _pickFiles,
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.add_photo_alternate),
              label: Text(_isLoading ? 'Loading...' : 'Select Files'),
            )
          : null,
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
              Icons.photo_library_outlined,
              size: 80,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 24),
            Text(
              'Select HEIC Files',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Choose HEIC or HEIF images to convert to your preferred format',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _pickFiles,
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.add_photo_alternate),
              label: Text(_isLoading ? 'Loading...' : 'Browse Files'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedFilesList() {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Row(
            children: [
              Icon(
                Icons.check_circle,
                color: theme.colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Selected Files (${_selectedFiles.length})',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: _pickFiles,
                icon: const Icon(Icons.add),
                label: const Text('Add More'),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding),
            itemCount: _selectedFiles.length,
            itemBuilder: (context, index) {
              final filePath = _selectedFiles[index];
              final fileName = filePath.split('/').last;
              
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Icon(
                    Icons.image,
                    color: theme.colorScheme.primary,
                  ),
                  title: Text(
                    fileName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    _converterService.getFileSize(filePath).toString(),
                    style: theme.textTheme.bodySmall,
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => _removeFile(index),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildOptionsPanel() {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        // Output Format
        Row(
          children: [
            Icon(Icons.format_align_left, size: 20, color: theme.colorScheme.outline),
            const SizedBox(width: 8),
            Text('Output Format:', style: theme.textTheme.bodyMedium),
            const SizedBox(width: 16),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _outputFormat,
                decoration: const InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: AppConstants.supportedOutputFormats.map((format) {
                  return DropdownMenuItem(
                    value: format,
                    child: Text(AppConstants.formatDisplayNames[format] ?? format.toUpperCase()),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _outputFormat = value);
                  }
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // Keep EXIF checkbox
        CheckboxListTile(
          title: const Text('Keep EXIF metadata'),
          subtitle: const Text('Preserve photo information (date, camera settings, etc.)'),
          value: _keepExif,
          onChanged: (value) {
            setState(() => _keepExif = value ?? false);
          },
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
        ),
        
        const SizedBox(height: 16),
        
        // Resize slider
        Row(
          children: [
            Icon(Icons.aspect_ratio, size: 20, color: theme.colorScheme.outline),
            const SizedBox(width: 8),
            Text('Resize:', style: theme.textTheme.bodyMedium),
            const SizedBox(width: 16),
            Expanded(
              child: Slider(
                value: _resizePercentage,
                min: AppConstants.minResizePercentage,
                max: AppConstants.maxResizePercentage,
                divisions: 10,
                label: '${_resizePercentage.round()}%',
                onChanged: (value) {
                  setState(() => _resizePercentage = value);
                },
              ),
            ),
            Text('${_resizePercentage.round()}%'),
          ],
        ),
      ],
    );
  }
}
