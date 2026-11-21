import 'package:flutter/material.dart';

import '../constant/constants.dart';
import '../theme/app_theme.dart';

/// Gradient strip under the app bar showing who is logged in.
class UserHeader extends StatelessWidget {
  const UserHeader({super.key, this.subtitle});

  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final name = (UserName ?? '').isEmpty ? 'User' : UserName!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
      decoration: const BoxDecoration(gradient: AppColors.headerGradient),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: Colors.white.withOpacity(0.18),
            child: Text(
              name.substring(0, 1).toUpperCase(),
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello, $name',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined,
                        size: 14, color: Colors.white70),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        subtitle ?? 'Area: ${AreaName ?? '-'}',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// White rounded card with a small heading — groups related form fields.
class FormSection extends StatelessWidget {
  const FormSection({
    super.key,
    required this.title,
    required this.children,
    this.icon,
  });

  final String title;
  final IconData? icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: AppColors.primary),
                const SizedBox(width: 8),
              ],
              Text(
                title.toUpperCase(),
                style: const TextStyle(
                  fontSize: 12,
                  letterSpacing: 0.8,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ..._spaced(children),
        ],
      ),
    );
  }

  static List<Widget> _spaced(List<Widget> items) {
    final out = <Widget>[];
    for (var i = 0; i < items.length; i++) {
      if (i > 0) out.add(const SizedBox(height: 12));
      out.add(items[i]);
    }
    return out;
  }
}

/// Read-only field that opens a date picker when tapped.
class DateField extends StatelessWidget {
  const DateField({
    super.key,
    required this.controller,
    required this.label,
    required this.onTap,
  });

  final TextEditingController controller;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      readOnly: true,
      onTap: onTap,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.event_outlined),
        suffixIcon: const Icon(Icons.arrow_drop_down),
      ),
    );
  }
}

/// Labelled dropdown that matches the text-field style.
class AppDropdown<T> extends StatelessWidget {
  const AppDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.icon,
    this.itemLabel,
  });

  final String label;
  final T? value;
  final List<T> items;
  final ValueChanged<T?> onChanged;
  final IconData? icon;
  final String Function(T)? itemLabel;

  @override
  Widget build(BuildContext context) {
    final safeValue = items.contains(value) ? value : null;
    return DropdownButtonFormField<T>(
      value: safeValue,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon == null ? null : Icon(icon),
      ),
      items: items
          .map((e) => DropdownMenuItem<T>(
                value: e,
                child: Text(
                  itemLabel?.call(e) ?? e.toString(),
                  overflow: TextOverflow.ellipsis,
                ),
              ))
          .toList(),
      onChanged: onChanged,
    );
  }
}

/// Prominent chip showing the auto-generated TR / DM number, with
/// loading and retry states so the user can't continue without one.
class DocNumberBanner extends StatelessWidget {
  const DocNumberBanner({
    super.key,
    required this.label,
    required this.number,
    required this.loading,
    required this.onRetry,
  });

  final String label;
  final String? number;
  final bool loading;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final ok = !loading && number != null && number!.isNotEmpty;
    final failed = !loading && !ok;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: failed
            ? AppColors.danger.withOpacity(0.07)
            : AppColors.primary.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: failed
              ? AppColors.danger.withOpacity(0.35)
              : AppColors.primary.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            failed ? Icons.error_outline : Icons.confirmation_number_outlined,
            color: failed ? AppColors.danger : AppColors.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary)),
                const SizedBox(height: 2),
                if (loading)
                  const Text('Generating…',
                      style: TextStyle(
                          fontSize: 16, color: AppColors.textSecondary))
                else if (ok)
                  Text(number!,
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          letterSpacing: 0.3))
                else
                  const Text('Could not get number',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.danger)),
              ],
            ),
          ),
          if (loading)
            const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2))
          else if (failed)
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Retry'),
            ),
        ],
      ),
    );
  }
}

/// Label / value line used on the review-and-save screens.
class InfoRow extends StatelessWidget {
  const InfoRow(this.label, this.value, {super.key, this.emphasize = false});

  final String label;
  final String? value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final v = (value == null || value!.trim().isEmpty) ? '—' : value!;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(label,
                style: const TextStyle(
                    fontSize: 14, color: AppColors.textSecondary)),
          ),
          Expanded(
            child: Text(
              v,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: emphasize ? 17 : 15,
                fontWeight: emphasize ? FontWeight.w700 : FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Small pill showing the customer's mobile number under the picker.
class MobileHint extends StatelessWidget {
  const MobileHint(this.mobile, {super.key});

  final String? mobile;

  @override
  Widget build(BuildContext context) {
    final m = (mobile == null || mobile!.isEmpty) ? 'Select a customer' : mobile!;
    return Row(
      children: [
        const Icon(Icons.phone_outlined,
            size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 6),
        Text(m,
            style: const TextStyle(
                color: AppColors.textSecondary, fontSize: 14)),
      ],
    );
  }
}

/// Row used inside the customer auto-complete suggestion list.
Widget customerSuggestionRow(String text) {
  final parts = text.split('#');
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
    child: Row(
      children: [
        const Icon(Icons.person_outline,
            size: 20, color: AppColors.textSecondary),
        const SizedBox(width: 10),
        Expanded(
          child: Text(parts.first,
              style: const TextStyle(
                  color: AppColors.textPrimary, fontSize: 16)),
        ),
        if (parts.length > 1)
          Text(parts[1],
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 13)),
      ],
    ),
  );
}

void showAppSnack(BuildContext context, String message, {bool error = true}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      backgroundColor: error ? AppColors.danger : AppColors.success,
      content: Row(
        children: [
          Icon(error ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white),
          const SizedBox(width: 10),
          Expanded(child: Text(message)),
        ],
      ),
    ));
}

/// Parses a positive number; returns false for '', 'abc', '-5', etc.
bool isPositiveNumber(String s) {
  final v = double.tryParse(s.trim());
  return v != null && v >= 0;
}

/// Card used in the TR / Supply registers.
class RecordCard extends StatelessWidget {
  const RecordCard({
    super.key,
    required this.number,
    required this.title,
    this.trailing,
    this.details = const [],
    this.onTap,
  });

  final String? number;
  final String title;
  final String? trailing;
  final List<MapEntry<String, String?>> details;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final hasNo = number != null &&
        number!.trim().isNotEmpty &&
        number!.trim() != 'null';
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: hasNo
                            ? AppColors.primary.withOpacity(0.08)
                            : AppColors.danger.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        hasNo ? number! : 'No number',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: hasNo ? AppColors.primary : AppColors.danger,
                        ),
                      ),
                    ),
                    const Spacer(),
                    if (trailing != null)
                      Text(trailing!,
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(title,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary)),
                if (details.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 14,
                    runSpacing: 4,
                    children: details
                        .where((d) =>
                            d.value != null &&
                            d.value!.isNotEmpty &&
                            d.value != 'null')
                        .map((d) => Text.rich(TextSpan(children: [
                              TextSpan(
                                  text: '${d.key} ',
                                  style: const TextStyle(
                                      fontSize: 12.5,
                                      color: AppColors.textSecondary)),
                              TextSpan(
                                  text: d.value,
                                  style: const TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textPrimary)),
                            ])))
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
