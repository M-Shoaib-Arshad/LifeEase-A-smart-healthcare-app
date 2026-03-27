import 'package:flutter/material.dart';
import '../../services/connectivity_service.dart';

/// Wraps a [child] widget and shows a red "No internet connection" banner at
/// the top whenever the device is offline.
///
/// Usage – wrap the root scaffold content (or the whole [MaterialApp] body):
/// ```dart
/// OfflineBanner(child: Scaffold(...))
/// ```
class OfflineBanner extends StatelessWidget {
  final Widget child;

  const OfflineBanner({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: ConnectivityService().onlineStream,
      builder: (context, snapshot) {
        final offline = snapshot.data == false;
        return Column(
          children: [
            if (offline)
              Material(
                color: Colors.red[700],
                child: SizedBox(
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.wifi_off, color: Colors.white, size: 14),
                        const SizedBox(width: 6),
                        const Text(
                          'No internet connection',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            Expanded(child: child),
          ],
        );
      },
    );
  }
}
