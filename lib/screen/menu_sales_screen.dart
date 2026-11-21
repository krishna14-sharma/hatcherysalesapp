import 'dart:io';

import 'package:flutter/material.dart';

import '../models/menu.dart';
import '../models/menu_list.dart';
import '../services/dashboard_service.dart';
import '../theme/app_theme.dart';
import '../widgets/dashboard_widgets.dart';
import '../widgets/ui.dart';
import '../widgets/app_version.dart';

/// Home screen: live dashboard on top, then the entry and report menus.
class SalesMenuGrid extends StatefulWidget {
  static const id = 'SalesMenuGrid';

  @override
  State<SalesMenuGrid> createState() => _SalesMenuGridState();
}

class _SalesMenuGridState extends State<SalesMenuGrid> {
  DashboardData? _data;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final d = await DashboardService.load();
    if (!mounted) return;
    setState(() {
      _data = d;
      _loading = false;
    });
  }

  /// Opens a screen and refreshes the dashboard when the user comes back.
  void _open(String route) {
    Navigator.of(context).pushNamed(route).then((_) {
      if (mounted) _load();
    });
  }

  Future<void> _confirmExit() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Exit app?'),
        content: const Text('You will need to log in again next time.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Exit',
                  style: TextStyle(color: AppColors.danger))),
        ],
      ),
    );
    if (ok == true) exit(0);
  }

  String _v(bool failed, String value) => (_loading || failed) ? '—' : value;

  @override
  Widget build(BuildContext context) {
    final d = _data;
    final entry = DUMMY_CATEGORIES.where((m) => m.section == 'entry').toList();
    final reports =
        DUMMY_CATEGORIES.where((m) => m.section == 'reports').toList();
    final missingTr = d?.trMissingNumber ?? 0;
    final missingDm = d?.dmMissingNumber ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Phoenix Sales'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: _loading ? null : _load,
          ),
          IconButton(
            tooltip: 'Exit',
            icon: const Icon(Icons.power_settings_new),
            onPressed: _confirmExit,
          ),
        ],
      ),
      body: Column(
        children: [
          const UserHeader(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _load,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  // ---------- Dashboard ----------
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        HeroStatCard(data: d, loading: _loading),
                        const SizedBox(height: 12),
                        GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1.55,
                          padding: EdgeInsets.zero,
                          children: [
                            StatTile(
                              icon: Icons.local_shipping_outlined,
                              label: 'Supplies today',
                              loading: _loading,
                              value: _v(d?.dmFailed ?? true,
                                  '${d?.todayDmCount ?? 0}'),
                              caption: _loading || (d?.dmFailed ?? true)
                                  ? null
                                  : '${d!.todayChicks} chicks',
                              onTap: () => _open('ListDmData'),
                            ),
                            StatTile(
                              icon: Icons.egg_outlined,
                              label: 'Demands today',
                              loading: _loading,
                              value: _v(d?.demandFailed ?? true,
                                  '${d?.todayDemandCount ?? 0}'),
                              caption: _loading || (d?.demandFailed ?? true)
                                  ? null
                                  : '${d!.todayDemandChicks} chicks',
                              onTap: () => _open('ListDemadData'),
                            ),
                            StatTile(
                              icon: Icons.account_balance_wallet_outlined,
                              label: 'Expenses today',
                              loading: _loading,
                              value: _v(d?.expenseFailed ?? true,
                                  formatInr(d?.todayExpenses ?? 0)),
                              onTap: () => _open('ListExpenseData'),
                            ),
                            StatTile(
                              icon: Icons.insights_outlined,
                              label: 'Chicks this month',
                              loading: _loading,
                              value: _v(d?.dmFailed ?? true,
                                  '${d?.monthChicks ?? 0}'),
                              caption: _loading || (d?.dmFailed ?? true)
                                  ? null
                                  : '${d!.monthDmCount} supplies',
                              onTap: () => _open('ListDmData'),
                            ),
                          ],
                        ),
                        if (!_loading && (missingTr > 0 || missingDm > 0)) ...[
                          const SizedBox(height: 12),
                          MissingNumberAlert(
                            trMissing: missingTr,
                            dmMissing: missingDm,
                            onTapTr: () => _open('ListTrData'),
                            onTapDm: () => _open('ListDmData'),
                          ),
                        ],
                        const SizedBox(height: 12),
                        WeekBarChart(
                          days: d?.last7Days ?? const [],
                          loading: _loading,
                        ),
                      ]),
                    ),
                  ),

                  // ---------- Menus ----------
                  _sectionTitle('New entry'),
                  _grid(entry),
                  _sectionTitle('Reports'),
                  _grid(reports),

                  // ---------- Recent ----------
                  if (!_loading && d != null && !d.trFailed)
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      sliver: SliverToBoxAdapter(
                        child: RecentTrCard(
                          items: d.recentTrs,
                          onViewAll: () => _open('ListTrData'),
                        ),
                      ),
                    ),
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(16, 24, 16, 24),
                      child: AppVersionText(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) => SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 10),
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      );

  Widget _grid(List<Menu> items) => SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        sliver: SliverGrid(
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 220,
            mainAxisExtent: 118,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, i) {
              final m = items[i];
              return MenuItem(m.id, m.title, m.color, m.routeName, m.icon,
                  subtitle: m.subtitle,
                  onOpen: m.routeName == null ? null : () => _open(m.routeName!));
            },
            childCount: items.length,
          ),
        ),
      );
}

class MenuItem extends StatelessWidget {
  final String title;
  final String id;
  final Color color;
  final String? routeName;
  final IconData? icon;
  final String? subtitle;
  final VoidCallback? onOpen;

  MenuItem(this.id, this.title, this.color, this.routeName, this.icon,
      {this.subtitle, this.onOpen});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onOpen ??
            (routeName == null
                ? null
                : () => Navigator.of(context).pushNamed(routeName!)),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 20, color: color),
              ),
              const Spacer(),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
