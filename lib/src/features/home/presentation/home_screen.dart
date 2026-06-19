import 'package:flutter/material.dart';
import '../../../../src/core/services/discovery_service.dart';
import '../../../../src/core/models/discovered_device.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late final DiscoveryService _discoveryService;
  late final AnimationController _radarController;

  @override
  void initState() {
    super.initState();
    _discoveryService = DiscoveryService()..initialize();
    _radarController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _discoveryService.dispose();
    _radarController.dispose();
    super.dispose();
  }

  IconData _getDeviceIcon(String os) {
    switch (os.toLowerCase()) {
      case 'android':
        return Icons.phone_android;
      case 'ios':
        return Icons.phone_iphone;
      case 'windows':
        return Icons.desktop_windows;
      case 'macos':
        return Icons.desktop_mac;
      case 'linux':
        return Icons.computer;
      default:
        return Icons.device_unknown;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('UniControl Radar'),
        centerTitle: true,
        elevation: 0,
      ),
      body: ListenableBuilder(
        listenable: _discoveryService,
        builder: (context, _) {
          final devices = _discoveryService.devices;

          return Column(
            children: [
              const SizedBox(height: 40),
              // Radar Animation Area
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: _radarController,
                      builder: (context, child) {
                        return Container(
                          width: 150 + (_radarController.value * 50),
                          height: 150 + (_radarController.value * 50),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: colorScheme.primary.withOpacity(1.0 - _radarController.value),
                              width: 2,
                            ),
                          ),
                        );
                      },
                    ),
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colorScheme.primaryContainer,
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.primary.withOpacity(0.3),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.radar,
                        size: 50,
                        color: colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              Text(
                'Searching for nearby devices...',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 20),
              // Devices List
              Expanded(
                child: devices.isEmpty
                    ? Center(
                        child: Text(
                          'No devices found yet.',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: colorScheme.onSurface.withOpacity(0.5),
                              ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: devices.length,
                        itemBuilder: (context, index) {
                          final device = devices[index];
                          return Card(
                            elevation: 4,
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                              leading: CircleAvatar(
                                backgroundColor: colorScheme.secondaryContainer,
                                child: Icon(
                                  _getDeviceIcon(device.os),
                                  color: colorScheme.onSecondaryContainer,
                                ),
                              ),
                              title: Text(
                                device.name,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text('${device.os} • ${device.ipAddress}'),
                              trailing: IconButton(
                                icon: Icon(Icons.link, color: colorScheme.primary),
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Connecting to ${device.name}...')),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
