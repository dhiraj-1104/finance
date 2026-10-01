/// Utility for dynamically calculating transaction time range timestamps
/// and constructing the query parameter for `/api/v1/transactions/amounts.json`.
abstract final class TransactionTimeRangeBuilder {
  /// Builds the composite query parameter:
  /// `today_<start>_<end>|thisWeek_<start>_<end>|thisMonth_<start>_<end>|thisYear_<start>_<end>`
  static String buildAmountsQuery({DateTime? now, int firstDayOfWeek = 0}) {
    final current = now ?? DateTime.now();

    final today = getTodayRange(current);
    final thisWeek = getWeekRange(current, firstDayOfWeek: firstDayOfWeek);
    final thisMonth = getMonthRange(current);
    final thisYear = getYearRange(current);

    final todayStr = 'today_${today.$1}_${today.$2}';
    final thisWeekStr = 'thisWeek_${thisWeek.$1}_${thisWeek.$2}';
    final thisMonthStr = 'thisMonth_${thisMonth.$1}_${thisMonth.$2}';
    final thisYearStr = 'thisYear_${thisYear.$1}_${thisYear.$2}';

    return '$todayStr|$thisWeekStr|$thisMonthStr|$thisYearStr';
  }

  /// Calculates (startTimeSeconds, endTimeSeconds) for today (00:00:00 to 23:59:59).
  static (int, int) getTodayRange(DateTime now) {
    final start = DateTime(now.year, now.month, now.day, 0, 0, 0);
    final end = DateTime(now.year, now.month, now.day, 23, 59, 59);
    return (_toUnix(start), _toUnix(end));
  }

  /// Calculates (startTimeSeconds, endTimeSeconds) for current week.
  /// [firstDayOfWeek]: 0 = Sunday, 1 = Monday, 2 = Tuesday, ..., 6 = Saturday.
  static (int, int) getWeekRange(DateTime now, {int firstDayOfWeek = 0}) {
    // Dart DateTime.weekday: 1 = Mon, 2 = Tue, ..., 7 = Sun.
    // Convert to 0..6 where 0 = Sun, 1 = Mon, ..., 6 = Sat.
    final currentWeekday0 = now.weekday % 7;
    final diff = (currentWeekday0 - (firstDayOfWeek % 7) + 7) % 7;

    final startDay = DateTime(now.year, now.month, now.day - diff, 0, 0, 0);
    final endDay = DateTime(
      startDay.year,
      startDay.month,
      startDay.day + 6,
      23,
      59,
      59,
    );

    return (_toUnix(startDay), _toUnix(endDay));
  }

  /// Calculates (startTimeSeconds, endTimeSeconds) for current month (1st to last day 23:59:59).
  static (int, int) getMonthRange(DateTime now) {
    final start = DateTime(now.year, now.month, 1, 0, 0, 0);
    final end = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    return (_toUnix(start), _toUnix(end));
  }

  /// Calculates (startTimeSeconds, endTimeSeconds) for current calendar year (Jan 1 to Dec 31).
  static (int, int) getYearRange(DateTime now) {
    final start = DateTime(now.year, 1, 1, 0, 0, 0);
    final end = DateTime(now.year, 12, 31, 23, 59, 59);
    return (_toUnix(start), _toUnix(end));
  }

  static int _toUnix(DateTime dt) => dt.millisecondsSinceEpoch ~/ 1000;
}
