import 'package:flutter/material.dart';
import 'package:threshold/helper/usage_stats.dart';

Future<void> showAllPermissionsSheet(
  BuildContext context, {
  required VoidCallback onGrantPressed,
}) async {
  final theme = Theme.of(context);

  await showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isDismissible: false,
    enableDrag: false,
    isScrollControlled: true,
    builder: (context) => PopScope(
      canPop: false,
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _SheetHandle(),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.security,
                          color: theme.colorScheme.primary,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Required Permissions',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'This app requires 4 permissions to function properly:',
                    ),
                    const SizedBox(height: 16),
                    _PermissionItem(
                      icon: Icons.bar_chart,
                      title: 'Usage Stats',
                      subtitle: 'Track app usage',
                    ),
                    _PermissionItem(
                      icon: Icons.accessibility,
                      title: 'Accessibility',
                      subtitle: 'Monitor app activity',
                    ),
                    _PermissionItem(
                      icon: Icons.layers,
                      title: 'Display Overlay',
                      subtitle: 'Show blocking overlays',
                    ),
                    _PermissionItem(
                      icon: Icons.admin_panel_settings,
                      title: 'Device Admin',
                      subtitle: 'Prevent uninstallation',
                    ),
                    const SizedBox(height: 16),
                    _PrivacyNote(),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Reject'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            onPressed: () {
                              Navigator.pop(context);
                              onGrantPressed();
                            },
                            child: const Text('Grant All'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    ),
  );
}

Future<void> showPermissionsStatusSheet(
  BuildContext context, {
  required VoidCallback onGrantPressed,
}) async {
  final usageStats = await UsageStatsHelper.hasPermission();
  final accessibility = await UsageStatsHelper.hasAccessibilityPermission();
  final overlay = await UsageStatsHelper.hasOverlayPermission();
  final deviceAdmin = await UsageStatsHelper.hasDeviceAdminPermission();

  if (!context.mounted) return;

  final theme = Theme.of(context);
  final allGranted = usageStats && accessibility && overlay && deviceAdmin;

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) => Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SheetHandle(),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Permissions Status',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                _PermissionRow(name: 'Usage Stats', granted: usageStats),
                _PermissionRow(name: 'Accessibility', granted: accessibility),
                _PermissionRow(name: 'Display Overlay', granted: overlay),
                _PermissionRow(name: 'Device Admin', granted: deviceAdmin),
                const SizedBox(height: 24),
                if (!allGranted)
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        Navigator.pop(context);
                        onGrantPressed();
                      },
                      child: const Text('Grant All'),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
}

void showPermissionHelpSheet(
  BuildContext context, {
  required VoidCallback onTryAgainPressed,
}) {
  final theme = Theme.of(context);

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            _SheetHandle(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Icon(
                    Icons.help_outline,
                    color: theme.colorScheme.primary,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Permission Help',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'How to enable permissions manually:',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _PermissionHelpItem(
                      icon: Icons.bar_chart,
                      title: 'Usage Stats',
                      path:
                          'Settings → Apps → Special app access → Usage access → threshold',
                    ),
                    const SizedBox(height: 12),
                    _PermissionHelpItem(
                      icon: Icons.accessibility,
                      title: 'Accessibility Service',
                      path:
                          'Settings → Accessibility → Downloaded apps → threshold',
                    ),
                    const SizedBox(height: 12),
                    _PermissionHelpItem(
                      icon: Icons.layers,
                      title: 'Display Overlay',
                      path:
                          'Settings → Apps → Special app access → Display over other apps → threshold',
                    ),
                    const SizedBox(height: 12),
                    _PermissionHelpItem(
                      icon: Icons.admin_panel_settings,
                      title: 'Device Admin',
                      path:
                          'Settings → Security → Device admin apps → threshold',
                    ),
                    const SizedBox(height: 20),
                    _AccessibilityWarningBox(),
                    const SizedBox(height: 16),
                    _ManufacturerNote(),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () {
                          Navigator.pop(context);
                          onTryAgainPressed();
                        },
                        child: const Text('Try Again'),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}


class _SheetHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 32,
        height: 4,
        margin: const EdgeInsets.only(top: 12, bottom: 20),
        decoration: BoxDecoration(
          color: Theme.of(
            context,
          ).colorScheme.onSurfaceVariant.withOpacity(0.4),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

class _PrivacyNote extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.primary.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.lock, color: theme.colorScheme.primary, size: 20),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'All data stays on your device',
              style: TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _PermissionItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _PermissionItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PermissionRow extends StatelessWidget {
  final String name;
  final bool granted;

  const _PermissionRow({required this.name, required this.granted});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            granted ? Icons.check_circle : Icons.cancel,
            color: granted ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 12),
          Text(name),
        ],
      ),
    );
  }
}

class _PermissionHelpItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String path;

  const _PermissionHelpItem({
    required this.icon,
    required this.title,
    required this.path,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.only(left: 26),
          child: Text(
            path,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}

class _AccessibilityWarningBox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.error.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                size: 20,
                color: theme.colorScheme.error,
              ),
              const SizedBox(width: 8),
              Text(
                "Can't enable Accessibility?",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '1. Go to Settings → Apps → threshold\n'
            '2. Tap the menu (⋮) in the top right\n'
            '3. Select "Allow restricted settings"\n'
            '4. Authenticate with PIN/biometric\n'
            '5. Now try enabling Accessibility again',
            style: TextStyle(
              fontSize: 12,
              height: 1.4,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _ManufacturerNote extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.secondary.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            size: 20,
            color: theme.colorScheme.secondary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Note: Menu paths may vary slightly depending on your Android version and device manufacturer.',
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
