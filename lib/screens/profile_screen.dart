import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../widgets/pro_badge.dart';
import '../widgets/gradient_button.dart';
import '../utils/app_constants.dart';
import '../utils/app_theme.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final authState = ref.watch(authProvider);
    final authNotifier = ref.read(authProvider.notifier);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.go(AppRoutes.settings),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Profile header
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                child: Column(
                  children: [
                    // Avatar
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: theme.colorScheme.primary,
                      child: Text(
                        authState.user?.displayName?.substring(0, 1).toUpperCase() ?? 'U',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Name and Pro badge
                    Text(
                      authState.user?.displayName ?? 'User',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    ProBadge(isPro: authState.isPro, size: 20),
                    
                    const SizedBox(height: 8),
                    
                    // Email
                    Text(
                      authState.user?.email ?? '',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Upgrade section for free users
            if (!authState.isPro) ...[
              const UpgradePromptWidget(
                title: 'Upgrade to Pro',
                description: 'Unlock unlimited conversions and premium features',
                onUpgrade: null, // TODO: Implement upgrade functionality
              ),
              const SizedBox(height: 24),
            ],
            
            // Statistics section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Statistics',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Total Conversions',
                            authState.user?.totalConversions.toString() ?? '0',
                            Icons.transform,
                            theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            'Account Type',
                            authState.isPro ? 'Pro' : 'Free',
                            authState.isPro ? Icons.workspace_premium : Icons.free_breakfast,
                            authState.isPro ? AppTheme.accentOrange : theme.colorScheme.outline,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Account actions
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.history),
                    title: const Text('Conversion History'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // TODO: Navigate to history screen
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('History feature coming soon')),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.download),
                    title: const Text('Downloaded Files'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // TODO: Navigate to downloads screen
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Downloads feature coming soon')),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.share),
                    title: const Text('Share App'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // TODO: Implement share functionality
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Share feature coming soon')),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.help),
                    title: const Text('Help & Support'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // TODO: Navigate to help screen
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Help feature coming soon')),
                      );
                    },
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Sign out button
            GradientButton(
              onPressed: () => _showSignOutDialog(context, authNotifier),
              gradient: LinearGradient(
                colors: [AppTheme.errorRed, AppTheme.errorRed.withOpacity(0.8)],
              ),
              child: const Text('Sign Out'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showSignOutDialog(BuildContext context, authNotifier) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              authNotifier.signOut();
              context.go(AppRoutes.login);
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}
