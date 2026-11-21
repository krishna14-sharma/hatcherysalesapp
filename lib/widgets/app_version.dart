import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Shows "Version 1.1.0 (2)". The numbers come from `version:` in
/// pubspec.yaml (name + build number), so there's nothing to update here.
class AppVersionText extends StatelessWidget {
  const AppVersionText({super.key, this.color});

  /// Text colour; defaults to a muted grey.
  final Color? color;

  // Read once and reuse on every screen.
  static final Future<PackageInfo> _info = PackageInfo.fromPlatform();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PackageInfo>(
      future: _info,
      builder: (context, snap) {
        if (!snap.hasData) return const SizedBox(height: 16);
        final p = snap.data!;
        final build = p.buildNumber.isEmpty ? '' : ' (${p.buildNumber})';
        return Text(
          'Version ${p.version}$build',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            letterSpacing: 0.3,
            color: color ?? const Color(0xFF6B7280),
          ),
        );
      },
    );
  }
}
