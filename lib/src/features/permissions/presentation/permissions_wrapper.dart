import 'package:flutter/material.dart';
import 'permissions_screen.dart';
import '../../../../src/core/services/permissions_service.dart';

class PermissionsWrapper extends StatefulWidget {
  final Widget child;

  const PermissionsWrapper({super.key, required this.child});

  @override
  State<PermissionsWrapper> createState() => _PermissionsWrapperState();
}

class _PermissionsWrapperState extends State<PermissionsWrapper> {
  bool _isLoading = true;
  bool _hasPermissions = false;

  @override
  void initState() {
    super.initState();
    _checkInitialPermissions();
  }

  Future<void> _checkInitialPermissions() async {
    final hasPermissions = await PermissionsService.checkPermissions();
    if (mounted) {
      setState(() {
        _hasPermissions = hasPermissions;
        _isLoading = false;
      });
    }
  }

  void _onPermissionsGranted() {
    setState(() {
      _hasPermissions = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (!_hasPermissions) {
      return PermissionsScreen(
        onPermissionsGranted: _onPermissionsGranted,
      );
    }

    return widget.child;
  }
}
