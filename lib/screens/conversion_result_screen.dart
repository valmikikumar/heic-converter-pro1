import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:photo_view/photo_view.dart';
import 'dart:io';
import '../providers/auth_provider.dart';
import '../services/heic_conversion_service.dart';
import '../services/firestore_service.dart';
import '../widgets/ad_banner_widget.dart';
import '../widgets/gradient_button.dart';
import '../utils/app_constants.dart';
import '../utils/app_theme.dart';

class ConversionResultScreen extends ConsumerStatefulWidget {
  final List<String> convertedFiles;
  final String outputFormat;

  const ConversionResultScreen({
    super.key,
    required this.convertedFiles,
    required this.outputFormat,
  });

  @override
  ConsumerState<ConversionResultScreen> createState() => _ConversionResultScreenState();
}

class _ConversionResultScreenState extends ConsumerState<ConversionResultScreen>
    with TickerProviderStateMixin {
  final HEICConversionService _conversionService = HEICConversionService();
  final FirestoreService _firestoreService = FirestoreService();
  
  List<String> _convertedFiles = [];
  bool _isConverting = false;
  double _progress = 0.0;
  String _currentFileName = '';
  late AnimationController _successController;
  late Animation<double> _successAnimation;

  @override
  void initState() {
    super.initState();
    _convertedFiles = widget.convertedFiles;
    _successController = AnimationController(
      duration: AppConstants.mediumAnimationDuration,
      vsync: this,
    );
    _successAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _successController, curve: AppTheme.bounceCurve),
    );
    _startConversion();
  }

  @override
  void dispose() {
    _successController.dispose();
    super.dispose();
  }

  Future<void> _startConversion() async {
    final authState = ref.read(authProvider);
    if (authState.user == null) return;

    setState(() {
      _isConverting = true;
      _progress = 0.0;
    });

    try {
      final results = await _conversionService.convertBatch(
        inputPaths: widget.convertedFiles,
        outputFormat: widget.outputFormat,
        keepExif: true, // Default value, should be passed from previous screen
        resizePercentage: 100.0, // Default value, should be passed from previous screen
        userId: authState.user!.uid,
        onProgress: (current, total) {
          setState(() {
            _progress = current / total;
          });
        },
        onFileComplete: (inputPath, outputFileName) {
          setState(() {
            _currentFileName = outputFileName;
          });
        },
      );

      // Save conversions to Firestore
      for (final conversion in results) {
        await _firestoreService.saveConversion(conversion);
      }

      setState(() {
        _convertedFiles = results.map((c) => c.convertedPath).toList();
        _isConverting = false;
      });

      // Show success animation
      _successController.forward();

      // Show interstitial ad for free users
      if (!authState.isPro) {
        // AdInterstitialService.showInterstitialAd();
      }

    } catch (e) {
      setState(() {
        _isConverting = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Conversion failed: $e'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }

  Future<void> _shareAllFiles() async {
    try {
      final files = _convertedFiles
          .map((path) => XFile(path))
          .toList();

      await Share.shareXFiles(
        files,
        text: 'Converted HEIC files using ${AppConstants.appName}',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sharing files: $e')),
        );
      }
    }
  }

  Future<void> _shareSingleFile(int index) async {
    try {
      final file = XFile(_convertedFiles[index]);
      await Share.shareXFiles([file]);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sharing file: $e')),
        );
      }
    }
  }

  void _showImageViewer(int index) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _ImageViewerScreen(
          imagePath: _convertedFiles[index],
          fileName: _convertedFiles[index].split('/').last,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = ref.watch(authProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conversion Result'),
        leading: IconButton(
          icon: const Icon(Icons.home),
          onPressed: () => context.go(AppRoutes.home),
        ),
      ),
      body: Column(
        children: [
          // Status header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            decoration: BoxDecoration(
              color: _isConverting 
                  ? theme.colorScheme.primary.withOpacity(0.1)
                  : AppTheme.successGreen.withOpacity(0.1),
              border: Border(
                bottom: BorderSide(
                  color: theme.colorScheme.outline.withOpacity(0.2),
                ),
              ),
            ),
            child: _isConverting
                ? _buildProgressHeader()
                : _buildSuccessHeader(),
          ),
          
          // Main content
          Expanded(
            child: _isConverting
                ? _buildProgressContent()
                : _buildResultContent(),
          ),
          
          // Banner ad for free users
          if (!authState.isPro && !_isConverting) const AdBannerWidget(),
        ],
      ),
    );
  }

  Widget _buildProgressHeader() {
    final theme = Theme.of(context);
    
    return Row(
      children: [
        SizedBox(
          width: 32,
          height: 32,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Converting Files...',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
              Text(
                '${(_progress * 100).toInt()}% Complete',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessHeader() {
    final theme = Theme.of(context);
    
    return AnimatedBuilder(
      animation: _successAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: 0.8 + (0.2 * _successAnimation.value),
          child: Row(
            children: [
              Icon(
                Icons.check_circle,
                color: AppTheme.successGreen,
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
                        fontWeight: FontWeight.w600,
                        color: AppTheme.successGreen,
                      ),
                    ),
                    Text(
                      '${_convertedFiles.length} file(s) converted to ${widget.outputFormat.toUpperCase()}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProgressContent() {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        children: [
          // Progress bar
          LinearProgressIndicator(
            value: _progress,
            backgroundColor: theme.colorScheme.outline.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
          ),
          
          const SizedBox(height: 24),
          
          // Current file info
          if (_currentFileName.isNotEmpty) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Icons.image,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _currentFileName,
                        style: theme.textTheme.bodyMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          
          // Instructions
          Text(
            'Please wait while we convert your files. This may take a few moments depending on file sizes.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultContent() {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        // Action buttons
        Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _shareAllFiles,
                  icon: const Icon(Icons.share),
                  label: const Text('Share All'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GradientButton(
                  onPressed: () => context.go(AppRoutes.home),
                  child: const Text('Convert More'),
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
            itemCount: _convertedFiles.length,
            itemBuilder: (context, index) {
              return _buildImageThumbnail(index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildImageThumbnail(int index) {
    final theme = Theme.of(context);
    final filePath = _convertedFiles[index];
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
                    case 'view':
                      _showImageViewer(index);
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
                    value: 'view',
                    child: Row(
                      children: [
                        Icon(Icons.visibility, size: 20),
                        SizedBox(width: 8),
                        Text('View'),
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
