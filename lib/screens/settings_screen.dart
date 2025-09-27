import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/auth_provider.dart';
import '../utils/app_constants.dart';
import '../utils/app_theme.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _darkMode = false;
  bool _notifications = true;
  bool _autoSave = true;
  String _defaultFormat = AppConstants.defaultOutputFormat;
  double _compressionQuality = AppConstants.defaultCompressionQuality.toDouble();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _darkMode = prefs.getBool('dark_mode') ?? false;
      _notifications = prefs.getBool('notifications') ?? true;
      _autoSave = prefs.getBool('auto_save') ?? true;
      _defaultFormat = prefs.getString('default_format') ?? AppConstants.defaultOutputFormat;
      _compressionQuality = prefs.getDouble('compression_quality') ?? AppConstants.defaultCompressionQuality.toDouble();
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dark_mode', _darkMode);
    await prefs.setBool('notifications', _notifications);
    await prefs.setBool('auto_save', _autoSave);
    await prefs.setString('default_format', _defaultFormat);
    await prefs.setDouble('compression_quality', _compressionQuality);
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: AppConstants.appName,
      applicationVersion: AppConstants.appVersion,
      applicationIcon: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.photo_library_outlined,
          color: Colors.white,
          size: 32,
        ),
      ),
      children: [
        const Text('Convert HEIC photos with professional quality'),
        const SizedBox(height: 16),
        const Text(
          'Features:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const Text('• Convert HEIC/HEIF to JPG, PNG, PDF'),
        const Text('• Batch processing'),
        const Text('• Pro features with subscription'),
        const Text('• Cloud sync across devices'),
        const Text('• Modern Material 3 design'),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = ref.watch(authProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRoutes.home),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        children: [
          // App Settings
          _buildSectionHeader('App Settings', Icons.settings),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Dark Mode'),
                  subtitle: const Text('Use dark theme'),
                  value: _darkMode,
                  onChanged: (value) {
                    setState(() => _darkMode = value);
                    _saveSettings();
                  },
                  secondary: const Icon(Icons.dark_mode),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Notifications'),
                  subtitle: const Text('Receive app notifications'),
                  value: _notifications,
                  onChanged: (value) {
                    setState(() => _notifications = value);
                    _saveSettings();
                  },
                  secondary: const Icon(Icons.notifications),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Auto Save'),
                  subtitle: const Text('Automatically save converted files'),
                  value: _autoSave,
                  onChanged: (value) {
                    setState(() => _autoSave = value);
                    _saveSettings();
                  },
                  secondary: const Icon(Icons.save),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Conversion Settings
          _buildSectionHeader('Conversion Settings', Icons.transform),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.format_align_left),
                  title: const Text('Default Output Format'),
                  subtitle: Text(AppConstants.formatDisplayNames[_defaultFormat] ?? _defaultFormat.toUpperCase()),
                  trailing: DropdownButton<String>(
                    value: _defaultFormat,
                    items: AppConstants.supportedOutputFormats.map((format) {
                      return DropdownMenuItem(
                        value: format,
                        child: Text(AppConstants.formatDisplayNames[format] ?? format.toUpperCase()),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _defaultFormat = value);
                        _saveSettings();
                      }
                    },
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.photo_filter),
                  title: Text('Compression Quality: ${_compressionQuality.round()}%'),
                  subtitle: Slider(
                    value: _compressionQuality,
                    min: AppConstants.minCompressionQuality.toDouble(),
                    max: AppConstants.maxCompressionQuality.toDouble(),
                    divisions: 20,
                    onChanged: (value) {
                      setState(() => _compressionQuality = value);
                      _saveSettings();
                    },
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Account Settings
          _buildSectionHeader('Account', Icons.person),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.account_circle),
                  title: const Text('Profile'),
                  subtitle: Text(authState.user?.email ?? ''),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.go(AppRoutes.profile),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(
                    authState.isPro ? Icons.workspace_premium : Icons.free_breakfast,
                    color: authState.isPro ? AppTheme.accentOrange : theme.colorScheme.outline,
                  ),
                  title: const Text('Subscription'),
                  subtitle: Text(authState.isPro ? 'Pro Plan Active' : 'Free Plan'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.go(AppRoutes.profile),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Support & Info
          _buildSectionHeader('Support & Info', Icons.info),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.help),
                  title: const Text('Help Center'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Help Center coming soon')),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.privacy_tip),
                  title: const Text('Privacy Policy'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Privacy Policy coming soon')),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.description),
                  title: const Text('Terms of Service'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Terms of Service coming soon')),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('About App'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _showAboutDialog,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // App Version
          Center(
            child: Text(
              'Version ${AppConstants.appVersion}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: theme.colorScheme.primary, size: 20),
          const SizedBox(width: 8),
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}