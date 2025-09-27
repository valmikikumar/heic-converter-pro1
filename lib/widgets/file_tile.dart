import 'package:flutter/material.dart';
import 'dart:io';

class FileTile extends StatelessWidget {
  final dynamic file;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const FileTile({
    super.key,
    required this.file,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Image thumbnail
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                image: _getImageDecoration(),
                color: theme.colorScheme.surfaceVariant,
              ),
              child: _getFallbackWidget(),
            ),
            
            // Overlay with file info
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.8),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _getFileName(),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (_getFileSize().isNotEmpty)
                      Text(
                        _getFileSize(),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 10,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            
            // Format badge
            Positioned(
              top: 4,
              left: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _getFormat(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  DecorationImage? _getImageDecoration() {
    try {
      if (file is String) {
        final filePath = file as String;
        final imageFile = File(filePath);
        if (imageFile.existsSync()) {
          return DecorationImage(
            image: FileImage(imageFile),
            fit: BoxFit.cover,
          );
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Widget _getFallbackWidget() {
    final theme = Theme.of(context);
    
    return Center(
      child: Icon(
        Icons.image,
        size: 32,
        color: theme.colorScheme.outline,
      ),
    );
  }

  String _getFileName() {
    try {
      if (file is String) {
        return (file as String).split('/').last;
      }
      return 'Unknown';
    } catch (e) {
      return 'Unknown';
    }
  }

  String _getFileSize() {
    try {
      if (file is String) {
        final filePath = file as String;
        final imageFile = File(filePath);
        if (imageFile.existsSync()) {
          final size = imageFile.lengthSync();
          if (size < 1024) {
            return '${size}B';
          } else if (size < 1024 * 1024) {
            return '${(size / 1024).toStringAsFixed(1)}KB';
          } else {
            return '${(size / (1024 * 1024)).toStringAsFixed(1)}MB';
          }
        }
      }
      return '';
    } catch (e) {
      return '';
    }
  }

  String _getFormat() {
    try {
      if (file is String) {
        final fileName = (file as String).split('/').last;
        final extension = fileName.split('.').last.toLowerCase();
        return extension.toUpperCase();
      }
      return 'FILE';
    } catch (e) {
      return 'FILE';
    }
  }
}
