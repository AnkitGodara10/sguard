// FILE: lib/core/widgets/connectivity_banner.dart
//
// PURPOSE:
//   A persistent top banner that appears whenever the device loses
//   internet connectivity. It uses ConnectivityService's stream to
//   reactively show/hide based on network state.
//
// HOW TO USE:
//   Wrap any Scaffold body with ConnectivityBanner:
//
//     body: ConnectivityBanner(
//       child: YourActualContent(),
//     ),
//
// WHY THIS MATTERS:
//   SGuard is a safety app. When a student generates a QR or a warden
//   tries to approve a leave with no internet, silent failures are
//   dangerous. This banner makes the offline state unmistakably visible.

import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../services/connectivity_service.dart';
import '../../di/injection.dart';

class ConnectivityBanner extends StatefulWidget {
  final Widget child;

  const ConnectivityBanner({super.key, required this.child});

  @override
  State<ConnectivityBanner> createState() => _ConnectivityBannerState();
}

class _ConnectivityBannerState extends State<ConnectivityBanner>
    with SingleTickerProviderStateMixin {
  late final ConnectivityService _connectivityService;
  bool _isOffline = false;
  late final AnimationController _animController;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _connectivityService = getIt<ConnectivityService>();
    _isOffline = !_connectivityService.isConnected;

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));

    if (_isOffline) _animController.forward();

    // Listen to connectivity changes
    _connectivityService.connectivityStream.listen((isConnected) {
      if (!mounted) return;
      setState(() => _isOffline = !isConnected);
      if (_isOffline) {
        _animController.forward();
      } else {
        _animController.reverse();
      }
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SlideTransition(
          position: _slideAnimation,
          child: _isOffline ? _OfflineBanner() : const SizedBox.shrink(),
        ),
        Expanded(child: widget.child),
      ],
    );
  }
}

class _OfflineBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.error,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: SafeArea(
        bottom: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off, color: Colors.white, size: 16),
            const SizedBox(width: 8),
            Text(
              'No internet connection',
              style: AppTextStyles.labelMedium.copyWith(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
