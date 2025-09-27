import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/heic_converter.dart';
import '../services/storage_service.dart';
import '../models/converted_file.dart';
import '../utils/app_constants.dart';

class ConversionProgressScreen extends StatefulWidget {
  final List<String> selectedFiles;
  final String outputFormat;
  final bool keepExif;
  final double resizePercentage;

  const ConversionProgressScreen({
    super.key,
    required this.selectedFiles,
    required this.outputFormat,
    required this.keepExif,
    required this.resizePercentage,
  });

  @override
  State<ConversionProgressScreen> createState() => _ConversionProgressScreenState();
}

class _ConversionProgressScreenState extends State<ConversionProgressScreen> {
  final HEICConverterService _converterService = HEICConverterService();
  final StorageService _storageService = StorageService();
  
  List<ConvertedFile> _convertedFiles = [];
  List<String> _failedFiles = [];
  int _currentFileIndex = 0;
  bool _isConverting = false;
  bool _isCancelled = false;
  double _overallProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _startConversion();
  }

  Future<void> _startConversion() async {
    setState(() {
      _isConverting = true;
      _currentFileIndex = 0;
      _overallProgress = 0.0;
    });

    try {
      final results = await _converterService.convertBatch(
        inputPaths: widget.selectedFiles,
        outputFormat: widget.outputFormat,
        keepExif: widget.keepExif,
        resizePercentage: widget.resizePercentage,
        compressionQuality: _storageService.getCompressionQuality(),
        onProgress: (current, total) {
          if (!_isCancelled && mounted) {
            setState(() {
              _currentFileIndex = current;
              _overallProgress = current / total;
            });
          }
        },
      );

      if (!_isCancelled && mounted) {
        setState(() {
          _convertedFiles = results;
          _isConverting = false;
        });

        // Save to history
        for (final file in results) {
          await _storageService.saveConvertedFile(file);
        }

        // Navigate to result screen
        context.go(AppConstants.resultRoute, extra: {
          'convertedFiles': _convertedFiles.map((f) => f.convertedPath).toList(),
          'outputFormat': widget.outputFormat,
        });
      }
    } catch (e) {
      if (!_isCancelled && mounted) {
        setState(() {
          _isConverting = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Conversion failed: $e')),
        );
      }
    }
  }

  void _cancelConversion() {
    setState(() {
      _isCancelled = true;
      _isConverting = false;
    });
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Conversion Cancelled'),
        content: const Text('The conversion process has been cancelled.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go(AppConstants.homeRoute);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  String _getCurrentFileName() {
    if (_currentFileIndex > 0 && _currentFileIndex <= widget.selectedFiles.length) {
      return widget.selectedFiles[_currentFileIndex - 1].split('/').last;
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Converting Files'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: _isConverting ? _cancelConversion : null,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          children: [
            // Overall progress
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.transform,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Converting Files',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${_currentFileIndex}/${widget.selectedFiles.length}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    LinearProgressIndicator(
                      value: _overallProgress,
                      backgroundColor: theme.colorScheme.outline.withOpacity(0.2),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${(_overallProgress * 100).toInt()}% Complete',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Current file info
            if (_isConverting && _getCurrentFileName().isNotEmpty) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.defaultPadding),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            theme.colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Converting:',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.outline,
                              ),
                            ),
                            Text(
                              _getCurrentFileName(),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            // File list
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.defaultPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'File List',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: ListView.builder(
                          itemCount: widget.selectedFiles.length,
                          itemBuilder: (context, index) {
                            final filePath = widget.selectedFiles[index];
                            final fileName = filePath.split('/').last;
                            final isCompleted = index < _currentFileIndex;
                            final isCurrent = index == _currentFileIndex - 1 && _isConverting;
                            
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: isCompleted
                                        ? Icon(
                                            Icons.check_circle,
                                            color: theme.colorScheme.primary,
                                            size: 20,
                                          )
                                        : isCurrent
                                            ? CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor: AlwaysStoppedAnimation<Color>(
                                                  theme.colorScheme.primary,
                                                ),
                                              )
                                            : Icon(
                                                Icons.radio_button_unchecked,
                                                color: theme.colorScheme.outline,
                                                size: 20,
                                              ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      fileName,
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        color: isCompleted
                                            ? theme.colorScheme.primary
                                            : theme.colorScheme.onSurface,
                                        fontWeight: isCompleted || isCurrent
                                            ? FontWeight.w500
                                            : FontWeight.normal,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (isCompleted)
                                    Icon(
                                      Icons.done,
                                      color: theme.colorScheme.primary,
                                      size: 16,
                                    ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Cancel button
            if (_isConverting)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _cancelConversion,
                  icon: const Icon(Icons.cancel),
                  label: const Text('Cancel Conversion'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
