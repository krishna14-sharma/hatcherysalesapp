import 'package:flutter/material.dart';

import '../services/dashboard_service.dart';
import '../theme/app_theme.dart';

/// Big "Today's collection" card at the top of the dashboard.
class HeroStatCard extends StatelessWidget {
  const HeroStatCard({super.key, required this.data, required this.loading});

  final DashboardData? data;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final d = data;
    final failed = d?.trFailed ?? false;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppColors.headerGradient,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.25),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Today's collection",
              style: TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 6),
          loading
              ? _shimmer(width: 160, height: 32)
              : Text(
                  (d == null || failed) ? '—' : formatInr(d.todayCollection),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w700),
                ),
          const SizedBox(height: 14),
          Row(
            children: [
              _pill(Icons.receipt_long_outlined,
                  loading || d == null || failed ? '—' : '${d.todayTrCount} TRs today'),
              const SizedBox(width: 8),
              _pill(Icons.date_range_outlined,
                  loading || d == null || failed
                      ? '—'
                      : 'Month ${shortInr(d.monthCollection)}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _pill(IconData icon, String text) => Flexible(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.16),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 15, color: Colors.white),
              const SizedBox(width: 6),
              Flexible(
                child: Text(text,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500)),
              ),
            ],
          ),
        ),
      );
}

/// Small white KPI tile.
class StatTile extends StatelessWidget {
  const StatTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.caption,
    this.loading = false,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final String? caption;
  final bool loading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Icon(icon, size: 17, color: AppColors.primary),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(label,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 12.5, color: AppColors.textSecondary)),
                  ),
                ],
              ),
              const Spacer(),
              loading
                  ? _shimmer(width: 70, height: 22, dark: true)
                  : Text(value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary)),
              if (caption != null) ...[
                const SizedBox(height: 2),
                Text(caption!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Bar chart of the last 7 days' collections. Plain widgets — no package.
class WeekBarChart extends StatelessWidget {
  const WeekBarChart({super.key, required this.days, this.loading = false});

  final List<DayValue> days;
  final bool loading;

  static const _wd = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  Widget build(BuildContext context) {
    final maxV = days.fold<double>(0, (m, d) => d.value > m ? d.value : m);
    final total = days.fold<double>(0, (s, d) => s + d.value);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text('Collections · last 7 days',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary)),
              ),
              Text(loading ? '' : formatInr(total),
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary)),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 130,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(days.length, (i) {
                final d = days[i];
                final isToday = i == days.length - 1;
                final frac = (loading || maxV <= 0) ? 0.0 : d.value / maxV;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (!loading && d.value > 0)
                          Text(shortInr(d.value),
                              maxLines: 1,
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: isToday
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  color: isToday
                                      ? AppColors.primary
                                      : AppColors.textSecondary)),
                        const SizedBox(height: 4),
                        Container(
                          height: 4 + 86 * frac,
                          decoration: BoxDecoration(
                            color: isToday
                                ? AppColors.primary
                                : AppColors.accent.withOpacity(0.55),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(isToday ? 'Today' : _wd[d.day.weekday - 1],
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight:
                                    isToday ? FontWeight.w700 : FontWeight.w400,
                                color: isToday
                                    ? AppColors.textPrimary
                                    : AppColors.textSecondary)),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

/// Warns about old records saved with a blank TR/DM number.
class MissingNumberAlert extends StatelessWidget {
  const MissingNumberAlert({
    super.key,
    required this.trMissing,
    required this.dmMissing,
    this.onTapTr,
    this.onTapDm,
  });

  final int trMissing;
  final int dmMissing;
  final VoidCallback? onTapTr;
  final VoidCallback? onTapDm;

  @override
  Widget build(BuildContext context) {
    final parts = <String>[
      if (trMissing > 0) '$trMissing TR${trMissing == 1 ? '' : 's'}',
      if (dmMissing > 0) '$dmMissing supply record${dmMissing == 1 ? '' : 's'}',
    ];
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFED7AA)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.warning_amber_rounded, color: Color(0xFFEA580C)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${parts.join(' and ')} saved without a number',
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF9A3412))),
                const SizedBox(height: 2),
                const Text(
                    'These were saved before the fix. Open the list to find them (tagged "No number").',
                    style: TextStyle(fontSize: 12.5, color: Color(0xFF9A3412))),
                const SizedBox(height: 6),
                Wrap(spacing: 8, children: [
                  if (trMissing > 0)
                    _link('View TRs', onTapTr),
                  if (dmMissing > 0)
                    _link('View supplies', onTapDm),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _link(String t, VoidCallback? onTap) => InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(t,
              style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFEA580C),
                  decoration: TextDecoration.underline)),
        ),
      );
}

/// Recent TRs list card.
class RecentTrCard extends StatelessWidget {
  const RecentTrCard({super.key, required this.items, this.onViewAll});

  final List<RecentTr> items;
  final VoidCallback? onViewAll;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(
                child: Text('Recent TRs',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary)),
              ),
              TextButton(onPressed: onViewAll, child: const Text('View all')),
            ],
          ),
          if (items.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text('No TRs yet',
                  style: TextStyle(color: AppColors.textSecondary)),
            )
          else
            ...items.map((t) {
              final ok = t.number.trim().isNotEmpty && t.number != 'null';
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      child: Text(
                        t.customer.isEmpty ? '?' : t.customer[0].toUpperCase(),
                        style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(t.customer,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textPrimary)),
                          Text(ok ? t.number : 'No number',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: ok
                                      ? AppColors.textSecondary
                                      : AppColors.danger)),
                        ],
                      ),
                    ),
                    Text(formatInr(t.amount),
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary)),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}

Widget _shimmer({required double width, required double height, bool dark = false}) =>
    Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: dark ? const Color(0xFFE8EEF5) : Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
    );
