import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'dart:io';

class ImagePreviewWidget extends StatelessWidget {
  final String imagePath;
  final String? title;
  final double? width;
  final double? height;
  final BoxFit fit;

  const ImagePreviewWidget({
    super.key,
    required this.imagePath,
    this.title,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: theme.colorScheme.surfaceVariant,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          children: [
            // Image
            SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: Image.file(
                File(imagePath),
                fit: fit,
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.broken_image,
                          size: 32,
                          color: theme.colorScheme.outline,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Failed to load image',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                      ],
                    ),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
              ),
            ),
            
            // Title overlay
            if (title != null)
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
                        Colors.black.withOpacity(0.7),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Text(
                    title!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class ZoomableImagePreview extends StatelessWidget {
  final String imagePath;
  final String? title;
  final double? minScale;
  final double? maxScale;

  const ZoomableImagePreview({
    super.key,
    required this.imagePath,
    this.title,
    this.minScale,
    this.maxScale,
  });

  @override
  Widget build(BuildContext context) {
    return PhotoView(
      imageProvider: FileImage(File(imagePath)),
      minScale: minScale ?? PhotoViewComputedScale.contained,
      maxScale: maxScale ?? PhotoViewComputedScale.covered * 2,
      backgroundDecoration: const BoxDecoration(color: Colors.black),
      loadingBuilder: (context, event) => Center(
        child: CircularProgressIndicator(
          value: event == null ? null : event.cumulativeBytesLoaded / (event.expectedTotalBytes ?? 1),
        ),
      ),
      errorBuilder: (context, error, stackTrace) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.broken_image,
              color: Colors.white,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load image',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ImageGallery extends StatefulWidget {
  final List<String> imagePaths;
  final int initialIndex;
  final String? title;

  const ImageGallery({
    super.key,
    required this.imagePaths,
    this.initialIndex = 0,
    this.title,
  });

  @override
  State<ImageGallery> createState() => _ImageGalleryState();
}

class _ImageGalleryState extends State<ImageGallery> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title ?? 'Image ${_currentIndex + 1}/${widget.imagePaths.length}',
        ),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareCurrentImage(),
          ),
        ],
      ),
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Main image viewer
          PageView.builder(
            controller: _pageController,
            itemCount: widget.imagePaths.length,
            onPageChanged: (index) {
              setState(() => _currentIndex = index);
            },
            itemBuilder: (context, index) {
              return ZoomableImagePreview(
                imagePath: widget.imagePaths[index],
              );
            },
          ),
          
          // Thumbnail strip (if multiple images)
          if (widget.imagePaths.length > 1)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 80,
                color: Colors.black.withOpacity(0.7),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  itemCount: widget.imagePaths.length,
                  itemBuilder: (context, index) {
                    final isSelected = index == _currentIndex;
                    
                    return GestureDetector(
                      onTap: () {
                        _pageController.animateToPage(
                          index,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: Container(
                        width: 60,
                        margin: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected ? Colors.white : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image.file(
                            File(widget.imagePaths[index]),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _shareCurrentImage() {
    // Implement sharing functionality
    // This would use the share_plus package
  }
}

class ImageComparisonWidget extends StatefulWidget {
  final String beforeImagePath;
  final String afterImagePath;
  final String? beforeLabel;
  final String? afterLabel;

  const ImageComparisonWidget({
    super.key,
    required this.beforeImagePath,
    required this.afterImagePath,
    this.beforeLabel,
    this.afterLabel,
  });

  @override
  State<ImageComparisonWidget> createState() => _ImageComparisonWidgetState();
}

class _ImageComparisonWidgetState extends State<ImageComparisonWidget> {
  double _sliderPosition = 0.5;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: theme.colorScheme.surfaceVariant,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          children: [
            // Before image (full)
            SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: Image.file(
                File(widget.beforeImagePath),
                fit: BoxFit.cover,
              ),
            ),
            
            // After image (clipped)
            Positioned(
              left: 0,
              top: 0,
              child: ClipRect(
                child: Align(
                  alignment: Alignment.centerLeft,
                  widthFactor: _sliderPosition,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: double.infinity,
                    child: Image.file(
                      File(widget.afterImagePath),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
            
            // Slider
            Positioned(
              top: 0,
              bottom: 0,
              left: _sliderPosition * MediaQuery.of(context).size.width,
              child: Container(
                width: 2,
                color: Colors.white,
                child: Center(
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.drag_handle,
                      size: 16,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),
            
            // Labels
            if (widget.beforeLabel != null)
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    widget.beforeLabel!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            
            if (widget.afterLabel != null)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    widget.afterLabel!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
