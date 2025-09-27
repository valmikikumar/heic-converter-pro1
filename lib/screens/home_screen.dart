import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../providers/auth_provider.dart';
import '../services/heic_conversion_service.dart';
import '../services/firestore_service.dart';
import '../widgets/ad_banner_widget.dart';
import '../widgets/pro_badge.dart';
import '../widgets/gradient_button.dart';
import '../utils/app_constants.dart';
import '../utils/app_theme.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with TickerProviderStateMixin {
  final HEICConversionService _conversionService = HEICConversionService();
  final FirestoreService _firestoreService = FirestoreService();
  
  List<String> _selectedFiles = [];
  String _outputFormat = AppConstants.defaultOutputFormat;
  bool _keepExif = AppConstants.defaultKeepExif;
  double _resizePercentage = AppConstants.defaultResizePercentage;
  bool _isLoading = false;
  int _selectedIndex = 0;

  late AnimationController _fabController;
  late Animation<double> _fabAnimation;

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
      duration: AppConstants.mediumAnimationDuration,
      vsync: this,
    );
    _fabAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fabController, curve: AppTheme.defaultCurve),
    );
    _fabController.forward();
  }

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
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
            .where((path) => _conversionService.isSupportedFormat(path))
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

  void _startConversion() async {
    final authState = ref.read(authProvider);
    if (authState.user == null) return;

    if (_selectedFiles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one file')),
      );
      return;
    }

    // Check file limit for free users
    if (!authState.isPro) {
      final remaining = _conversionService.getRemainingConversions(
        authState.user!.totalConversions,
        authState.isPro,
      );
      
      if (remaining >= 0 && _selectedFiles.length > remaining) {
        _showUpgradeDialog();
        return;
      }
    }

    // Show conversion progress screen
    context.go(AppRoutes.conversionResult, extra: {
      'files': _selectedFiles,
      'outputFormat': _outputFormat,
      'keepExif': _keepExif,
      'resizePercentage': _resizePercentage,
    });
  }

  void _showUpgradeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Upgrade to Pro'),
        content: Text(
          'You have reached the limit of ${AppConstants.freeUserFileLimit} conversions. '
          'Upgrade to Pro for unlimited conversions and premium features.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ProGradientButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go(AppRoutes.profile);
            },
            child: const Text('Upgrade Now'),
          ),
        ],
      ),
    );
  }

  void _removeFile(int index) {
    setState(() {
      _selectedFiles.removeAt(index);
    });
  }

  void _onTabTapped(int index) {
    setState(() => _selectedIndex = index);
    
    switch (index) {
      case 0:
        // Already on home
        break;
      case 1:
        context.go(AppRoutes.profile);
        break;
      case 2:
        context.go(AppRoutes.settings);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = ref.watch(authProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Implement notifications
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // User info and Pro badge
          Container(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: theme.colorScheme.primary,
                  child: Text(
                    authState.user?.displayName?.substring(0, 1).toUpperCase() ?? 'U',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome back, ${authState.user?.displayName ?? 'User'}!',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      ProBadge(isPro: authState.isPro),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.account_circle),
                  onPressed: () => context.go(AppRoutes.profile),
                ),
              ],
            ),
          ),
          
          // Main content
          Expanded(
            child: _selectedFiles.isEmpty
                ? _buildEmptyState()
                : _buildFileSelectionContent(),
          ),
          
          // Banner ad for free users
          if (!authState.isPro) const AdBannerWidget(),
        ],
      ),
      floatingActionButton: AnimatedBuilder(
        animation: _fabAnimation,
        builder: (context, child) {
          return ScaleTransition(
            scale: _fabAnimation,
            child: FloatingActionButton.extended(
              onPressed: _isLoading ? null : _pickFiles,
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.add_photo_alternate),
              label: Text(_isLoading ? 'Loading...' : 'Select Files'),
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.white,
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onTabTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    final authState = ref.watch(authProvider);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.largePadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryBlue.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(
                Icons.photo_library_outlined,
                size: 60,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Convert HEIC Photos',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Select HEIC files to convert to JPG, PNG, or PDF',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 32),
            GradientButton(
              onPressed: _isLoading ? null : _pickFiles,
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Get Started'),
            ),
            const SizedBox(height: 16),
            if (!authState.isPro) ...[
              const UpgradePromptWidget(
                title: 'Unlock Pro Features',
                description: 'Get unlimited conversions and premium tools',
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFileSelectionContent() {
    final theme = Theme.of(context);
    final authState = ref.watch(authProvider);
    
    return Column(
      children: [
        // Selected files header
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
        
        // File list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding),
            itemCount: _selectedFiles.length,
            itemBuilder: (context, index) {
              final filePath = _selectedFiles[index];
              final fileName = filePath.split('/').last;
              final fileInfo = _conversionService.getFileInfo(filePath);
              
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.image,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  title: Text(
                    fileName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    fileInfo['size'] != null 
                        ? '${(fileInfo['size'] / 1024 / 1024).toStringAsFixed(1)} MB'
                        : 'Unknown size',
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
        
        // Options panel
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
                child: GradientButton(
                  onPressed: _startConversion,
                  child: Text('Convert ${_selectedFiles.length} file(s)'),
                ),
              ),
            ],
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
          subtitle: const Text('Preserve photo information'),
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