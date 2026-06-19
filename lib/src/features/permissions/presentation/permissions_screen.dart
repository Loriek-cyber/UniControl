import 'package:flutter/material.dart';
import '../../../../src/core/services/permissions_service.dart';

class PermissionsScreen extends StatefulWidget {
  final VoidCallback onPermissionsGranted;

  const PermissionsScreen({super.key, required this.onPermissionsGranted});

  @override
  State<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen> {
  bool _isRequesting = false;
  bool _hasDeniedForever = false;

  Future<void> _handleFixPermissions() async {
    setState(() {
      _isRequesting = true;
    });

    final isGranted = await PermissionsService.requestPermissions();

    setState(() {
      _isRequesting = false;
    });

    if (isGranted) {
      widget.onPermissionsGranted();
    } else {
      // If we ask and they say no, or if they permanently denied
      setState(() {
        _hasDeniedForever = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Permissions Required'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.warning_amber_rounded,
                size: 80,
                color: colorScheme.error,
              ),
              const SizedBox(height: 24),
              Text(
                'Missing Permissions',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.error,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'UniControl needs network and location permissions to discover and communicate with other devices on your local network.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: 48),
              if (_isRequesting)
                const CircularProgressIndicator()
              else if (_hasDeniedForever) ...[
                Text(
                  'Permissions were denied. Please enable them manually in the app settings.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: PermissionsService.openSettings,
                  icon: const Icon(Icons.settings),
                  label: const Text('Open App Settings'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: _handleFixPermissions,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Check Again'),
                )
              ] else
                FilledButton.icon(
                  onPressed: _handleFixPermissions,
                  icon: const Icon(Icons.build),
                  label: const Text('Fix Problems'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    textStyle: theme.textTheme.titleMedium,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
