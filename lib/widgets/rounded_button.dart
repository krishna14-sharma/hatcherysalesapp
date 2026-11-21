import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// App-wide primary button. Same constructor as before, so every existing
/// screen picks up the new look automatically.
///
/// Any of the old "light blue" colours map to the brand primary; other
/// colours are respected. Titles like "Next..." / "Previous..." are cleaned up.
class RoundedButton extends StatelessWidget {
  RoundedButton({this.title, this.colour, required this.onPressed, this.icon});

  final Color? colour;
  final String? title;
  final Function onPressed;
  final IconData? icon;

  static final _legacyBlues = <int>{
    Colors.lightBlueAccent.value,
    Colors.lightBlue.value,
    Colors.blue.value,
    Colors.blueAccent.value,
  };

  bool get _isSecondary {
    final t = (title ?? '').toLowerCase();
    return t.startsWith('previous') || t.startsWith('back') || t.startsWith('cancel');
  }

  String get _label =>
      (title ?? '').replaceAll(RegExp(r'\.+$'), '').trim();

  @override
  Widget build(BuildContext context) {
    final VoidCallback cb = () => onPressed();

    final Color bg = (colour == null || _legacyBlues.contains(colour!.value))
        ? AppColors.primary
        : colour!;

    final Widget child = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[Icon(icon, size: 20), const SizedBox(width: 8)],
        Text(_label),
        if (icon == null && _label.toLowerCase() == 'next') ...[
          const SizedBox(width: 6),
          const Icon(Icons.arrow_forward, size: 20),
        ],
      ],
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: SizedBox(
        width: double.infinity,
        child: _isSecondary
            ? OutlinedButton(onPressed: cb, child: child)
            : ElevatedButton(
                onPressed: cb,
                style: ElevatedButton.styleFrom(
                  backgroundColor: bg,
                  foregroundColor: Colors.white,
                ),
                child: child,
              ),
      ),
    );
  }
}
