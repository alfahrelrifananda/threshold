import 'package:flutter/material.dart';
import 'package:threshold/model.dart';
import 'package:threshold/helper/time_tools.dart';
import 'package:threshold/helper/usage_stats.dart';

void showAppOptionsSheet(
  BuildContext context, {
  required AppUsageStat stat,
  required Map<String, dynamic>? appInfo,
  required bool hasTimer,
  required int? timerLimit,
  required Future<void> Function() onTimersChanged,
  required Future<void> Function(Set<String>) onAppIgnored,
  required Set<String> ignoredPackages,
}) {
  final theme = Theme.of(context);
  final appName =
      appInfo?['appName'] as String? ?? stat.packageName.split('.').last;

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
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
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Text(
              appName,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),
          ListTile(
            leading: Icon(
              hasTimer ? Icons.timer : Icons.timer_outlined,
              color: theme.colorScheme.primary,
            ),
            title: Text(hasTimer ? 'Edit Timer' : 'Set Timer'),
            subtitle: hasTimer ? Text('Current limit: $timerLimit minutes') : null,
            onTap: () {
              Navigator.pop(context);
              showTimerSheet(
                context,
                stat: stat,
                appInfo: appInfo,
                hasTimer: hasTimer,
                currentLimit: timerLimit,
                onTimersChanged: onTimersChanged,
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.block, color: theme.colorScheme.error),
            title: const Text('Ignore App'),
            subtitle: const Text('Hide from usage stats'),
            onTap: () {
              Navigator.pop(context);
              showIgnoreAppSheet(
                context,
                packageName: stat.packageName,
                appName: appName,
                ignoredPackages: ignoredPackages,
                onAppIgnored: onAppIgnored,
              );
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    ),
  );
}

void showTimerSheet(
  BuildContext context, {
  required AppUsageStat stat,
  required Map<String, dynamic>? appInfo,
  required bool hasTimer,
  required int? currentLimit,
  required Future<void> Function() onTimersChanged,
}) {
  final theme = Theme.of(context);
  int selectedMinutes = currentLimit ?? 30;
  final appName =
      appInfo?['appName'] as String? ?? stat.packageName.split('.').last;

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) => StatefulBuilder(
      builder: (context, setSheetState) => Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _SheetHandle(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Set Timer for $appName',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Limit usage to $selectedMinutes minutes per day',
                    style: theme.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 16),
                  Slider(
                    value: selectedMinutes.toDouble(),
                    min: 5,
                    max: 300,
                    divisions: 59,
                    label: '$selectedMinutes min',
                    onChanged: (value) {
                      setSheetState(() => selectedMinutes = value.toInt());
                    },
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Used today: ${TimeTools.formatTime(stat.totalTime)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      if (hasTimer) ...[
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () async {
                              await UsageStatsHelper.removeAppTimer(
                                  stat.packageName);
                              await onTimersChanged();
                              if (context.mounted) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Timer removed'),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
                            },
                            child: const Text('Remove'),
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      Expanded(
                        child: FilledButton(
                          onPressed: () async {
                            await UsageStatsHelper.setAppTimer(
                                stat.packageName, selectedMinutes);
                            await onTimersChanged();
                            if (context.mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      'Timer set to $selectedMinutes minutes'),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          },
                          child: const Text('Set Timer'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    ),
  );
}

void showIgnoreAppSheet(
  BuildContext context, {
  required String packageName,
  required String appName,
  required Set<String> ignoredPackages,
  required Future<void> Function(Set<String>) onAppIgnored,
}) {
  final theme = Theme.of(context);

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
                Row(
                  children: [
                    Icon(Icons.block, color: theme.colorScheme.error, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Ignore App',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Hide "$appName" from usage stats and widgets?',
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: () async {
                          final updated = Set<String>.from(ignoredPackages)
                            ..add(packageName);
                          Navigator.pop(context);
                          await onAppIgnored(updated);

                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content:
                                    const Text('App added to ignored list'),
                                behavior: SnackBarBehavior.floating,
                                action: SnackBarAction(
                                  label: 'Undo',
                                  onPressed: () async {
                                    final reverted =
                                        Set<String>.from(updated)
                                          ..remove(packageName);
                                    await onAppIgnored(reverted);
                                  },
                                ),
                              ),
                            );
                          }
                        },
                        child: const Text('Ignore'),
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
          color:
              Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.4),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}