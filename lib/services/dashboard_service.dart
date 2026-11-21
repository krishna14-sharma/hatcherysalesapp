import '../constant/constants.dart';
import '../network/network.dart';
import 'doc_number_service.dart';

/// Figures shown on the home dashboard. Every value is computed in the app
/// from the existing report APIs, so no server changes are needed.
class DashboardData {
  // Today
  double todayCollection = 0;
  int todayTrCount = 0;
  int todayDmCount = 0;
  int todayChicks = 0;
  int todayDemandCount = 0;
  int todayDemandChicks = 0;
  double todayExpenses = 0;

  // This month
  double monthCollection = 0;
  int monthTrCount = 0;
  int monthChicks = 0;
  int monthDmCount = 0;

  /// Collection per day for the last 7 days (oldest first).
  List<DayValue> last7Days = [];

  /// Records saved with a blank number (the old bug) — so they can be fixed.
  int trMissingNumber = 0;
  int dmMissingNumber = 0;

  List<RecentTr> recentTrs = [];

  /// Which sections failed to load (shown as "—" instead of 0).
  bool trFailed = false;
  bool dmFailed = false;
  bool demandFailed = false;
  bool expenseFailed = false;
}

class DayValue {
  DayValue(this.day, this.value);
  final DateTime day;
  double value;
}

class RecentTr {
  RecentTr(this.number, this.customer, this.amount, this.date);
  final String number;
  final String customer;
  final double amount;
  final DateTime? date;
}

class DashboardService {
  DashboardService._();

  static Future<DashboardData> load() async {
    final d = DashboardData();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    d.last7Days = List.generate(
        7, (i) => DayValue(today.subtract(Duration(days: 6 - i)), 0));

    await Future.wait([
      _loadTr(d, today),
      _loadDm(d, today),
      _loadDemand(d, today),
      _loadExpenses(d, today),
    ]);
    return d;
  }

  static Future<void> _loadTr(DashboardData d, DateTime today) async {
    try {
      final data = await NetworkHelper(DocNumberService.buildUri(
          'ShowAllTrData', {'AreaCode': AreaCode, 'uname': UserName})).getData();
      final rows = (data['TrData'] as List?) ?? const [];
      final recent = <RecentTr>[];
      for (final c in rows) {
        if (!DocNumberService.isValid(c['TRNo']?.toString())) d.trMissingNumber++;
        final date = parseServerDate(c['TrDate']);
        final amt = toNum(c['TrAmount']);
        recent.add(RecentTr(c['TRNo']?.toString() ?? '',
            c['CName']?.toString() ?? '', amt, date));
        if (date == null) continue;
        if (_sameDay(date, today)) {
          d.todayCollection += amt;
          d.todayTrCount++;
        }
        if (date.year == today.year && date.month == today.month) {
          d.monthCollection += amt;
          d.monthTrCount++;
        }
        for (final dv in d.last7Days) {
          if (_sameDay(dv.day, date)) dv.value += amt;
        }
      }
      recent.sort((a, b) => (b.date ?? DateTime(1900)).compareTo(a.date ?? DateTime(1900)));
      d.recentTrs = recent.take(5).toList();
    } catch (e) {
      print('Dashboard TR load failed: $e');
      d.trFailed = true;
    }
  }

  static Future<void> _loadDm(DashboardData d, DateTime today) async {
    try {
      final data = await NetworkHelper(DocNumberService.buildUri(
          'ShowAllDMData', {'AreaCode': AreaCode, 'uname': UserName})).getData();
      final rows = (data['DMData'] as List?) ?? const [];
      for (final c in rows) {
        if (!DocNumberService.isValid(c['DMNo']?.toString())) d.dmMissingNumber++;
        final date = parseServerDate(c['DMDate']);
        final chicks = toNum(c['TotalChicks']).round();
        if (date == null) continue;
        if (_sameDay(date, today)) {
          d.todayDmCount++;
          d.todayChicks += chicks;
        }
        if (date.year == today.year && date.month == today.month) {
          d.monthDmCount++;
          d.monthChicks += chicks;
        }
      }
    } catch (e) {
      print('Dashboard DM load failed: $e');
      d.dmFailed = true;
    }
  }

  static Future<void> _loadDemand(DashboardData d, DateTime today) async {
    try {
      final data = await NetworkHelper(DocNumberService.buildUri('ShowDemandData', {
        'AreaCode': AreaCode,
        'uname': UserName,
        'DMDate': _ymd(today),
      })).getData();
      final rows = (data['DemandData'] as List?) ?? const [];
      for (final c in rows) {
        if (c['DMNo']?.toString() == 'null') continue;
        d.todayDemandCount++;
        d.todayDemandChicks += toNum(c['TotalChicks']).round();
      }
    } catch (e) {
      print('Dashboard demand load failed: $e');
      d.demandFailed = true;
    }
  }

  static Future<void> _loadExpenses(DashboardData d, DateTime today) async {
    try {
      final data = await NetworkHelper(DocNumberService.buildUri('ShowAreaExpsData', {
        'uname': UserName,
        'Exp_Date': _ymd(today),
      })).getData();
      final rows = (data['AreaExpenseData'] as List?) ?? const [];
      for (final c in rows) {
        if (c['ExpNo']?.toString() == 'null') continue;
        d.todayExpenses += toNum(c['ExpenseAmount']);
      }
    } catch (e) {
      print('Dashboard expense load failed: $e');
      d.expenseFailed = true;
    }
  }

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static String _ymd(DateTime d) => d.toString().split(' ')[0];
}

/// Number from whatever the server sends ("48,500", 48500, "48500.00", null).
double toNum(dynamic v) {
  if (v == null) return 0;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString().replaceAll(',', '').trim()) ?? 0;
}

/// Reads the date formats a .NET service typically returns:
/// 2026-11-19, 2026-11-19T00:00:00, 11/19/2026 12:00:00 AM,
/// 19-11-2026, 19/11/2026, /Date(1763510400000)/
DateTime? parseServerDate(dynamic raw) {
  if (raw == null) return null;
  final s = raw.toString().trim();
  if (s.isEmpty || s == 'null') return null;

  final ms = RegExp(r'/Date\((-?\d+)').firstMatch(s);
  if (ms != null) {
    final dt = DateTime.fromMillisecondsSinceEpoch(int.parse(ms.group(1)!));
    return DateTime(dt.year, dt.month, dt.day);
  }

  final iso = RegExp(r'^(\d{4})-(\d{1,2})-(\d{1,2})').firstMatch(s);
  if (iso != null) {
    return DateTime(int.parse(iso.group(1)!), int.parse(iso.group(2)!),
        int.parse(iso.group(3)!));
  }

  final m = RegExp(r'^(\d{1,2})[/\-.](\d{1,2})[/\-.](\d{4})').firstMatch(s);
  if (m != null) {
    final a = int.parse(m.group(1)!), b = int.parse(m.group(2)!);
    final y = int.parse(m.group(3)!);
    // .NET default (US) is M/d/yyyy with '/'; '-' or '.' usually means d-M-yyyy.
    final usesSlash = s.contains('/');
    int month, day;
    if (a > 12) {
      day = a; month = b;
    } else if (b > 12) {
      month = a; day = b;
    } else if (usesSlash) {
      month = a; day = b;
    } else {
      day = a; month = b;
    }
    return DateTime(y, month, day);
  }
  return null;
}

/// Indian-style grouping: 1234567.5 -> "12,34,568".
String formatInr(double v) {
  final neg = v < 0;
  var s = v.abs().round().toString();
  if (s.length > 3) {
    final last3 = s.substring(s.length - 3);
    var rest = s.substring(0, s.length - 3);
    final parts = <String>[];
    while (rest.length > 2) {
      parts.insert(0, rest.substring(rest.length - 2));
      rest = rest.substring(0, rest.length - 2);
    }
    if (rest.isNotEmpty) parts.insert(0, rest);
    s = '${parts.join(',')},$last3';
  }
  return '${neg ? '-' : ''}₹$s';
}

/// Short form for chart labels: 48500 -> "48.5K", 1250000 -> "12.5L".
String shortInr(double v) {
  if (v >= 10000000) return '${(v / 10000000).toStringAsFixed(1)}Cr';
  if (v >= 100000) return '${(v / 100000).toStringAsFixed(1)}L';
  if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
  return v.round().toString();
}
