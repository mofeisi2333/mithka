//
//  date_text.dart
//
//  Locale-aware compact chat timestamps.
//

import 'package:intl/intl.dart';
import 'package:mithka/l10n/app_localizations.dart';

class DateText {
  // 星期日 … 星期六, indexed by DateTime.weekday (Mon=1 … Sun=7).
  static const _weekdays = {
    'zhHans': [
      AppStringKeys.dateWeekdayMondayChinese,
      AppStringKeys.dateWeekdayTuesdayChinese,
      AppStringKeys.dateWeekdayWednesdayChinese,
      AppStringKeys.dateWeekdayThursdayChinese,
      AppStringKeys.dateWeekdayFridayChinese,
      AppStringKeys.dateWeekdaySaturdayChinese,
      AppStringKeys.dateWeekdaySundayChinese,
    ],
    'zhHant': [
      AppStringKeys.dateWeekdayMondayChinese,
      AppStringKeys.dateWeekdayTuesdayChinese,
      AppStringKeys.dateWeekdayWednesdayChinese,
      AppStringKeys.dateWeekdayThursdayChinese,
      AppStringKeys.dateWeekdayFridayChinese,
      AppStringKeys.dateWeekdaySaturdayChinese,
      AppStringKeys.dateWeekdaySundayChinese,
    ],
    'ja': [
      AppStringKeys.dateWeekdayMondayJapanese,
      AppStringKeys.dateWeekdayTuesdayJapanese,
      AppStringKeys.dateWeekdayWednesdayJapanese,
      AppStringKeys.dateWeekdayThursdayJapanese,
      AppStringKeys.dateWeekdayFridayJapanese,
      AppStringKeys.dateWeekdaySaturdayJapanese,
      AppStringKeys.dateWeekdaySundayJapanese,
    ],
    'ko': [
      AppStringKeys.dateWeekdayMondayKorean,
      AppStringKeys.dateWeekdayTuesdayKorean,
      AppStringKeys.dateWeekdayWednesdayKorean,
      AppStringKeys.dateWeekdayThursdayKorean,
      AppStringKeys.dateWeekdayFridayKorean,
      AppStringKeys.dateWeekdaySaturdayKorean,
      AppStringKeys.dateWeekdaySundayKorean,
    ],
    'en': ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
    'fr': ['lun.', 'mar.', 'mer.', 'jeu.', 'ven.', 'sam.', 'dim.'],
    'es': ['lun', 'mar', 'mie', 'jue', 'vie', 'sab', 'dom'],
    'de': ['Mo.', 'Di.', 'Mi.', 'Do.', 'Fr.', 'Sa.', 'So.'],
  };

  static const _yesterday = {
    'zhHans': AppStringKeys.dateYesterdayChinese,
    'zhHant': AppStringKeys.dateYesterdayChinese,
    'ja': AppStringKeys.dateYesterdayJapanese,
    'ko': AppStringKeys.dateYesterdayKorean,
    'en': 'Yesterday',
    'fr': 'Hier',
    'es': 'Ayer',
    'de': 'Gestern',
  };

  static const _periods = {
    'zhHans': [
      AppStringKeys.datePeriodBeforeDawnChinese,
      AppStringKeys.datePeriodMorningChinese,
      AppStringKeys.datePeriodForenoonChinese,
      AppStringKeys.datePeriodNoonChinese,
      AppStringKeys.datePeriodAfternoonChinese,
      AppStringKeys.datePeriodEveningChinese,
    ],
    'zhHant': [
      AppStringKeys.datePeriodBeforeDawnChinese,
      AppStringKeys.datePeriodMorningChinese,
      AppStringKeys.datePeriodForenoonChinese,
      AppStringKeys.datePeriodNoonChinese,
      AppStringKeys.datePeriodAfternoonChinese,
      AppStringKeys.datePeriodEveningChinese,
    ],
    'ja': [
      AppStringKeys.datePeriodBeforeDawnJapanese,
      AppStringKeys.datePeriodMorningJapanese,
      AppStringKeys.datePeriodForenoonJapanese,
      AppStringKeys.datePeriodNoonJapanese,
      AppStringKeys.datePeriodAfternoonJapanese,
      AppStringKeys.datePeriodNightJapanese,
    ],
    'ko': [
      AppStringKeys.datePeriodBeforeDawnKorean,
      AppStringKeys.datePeriodMorningKorean,
      AppStringKeys.datePeriodForenoonKorean,
      AppStringKeys.datePeriodNoonKorean,
      AppStringKeys.datePeriodAfternoonKorean,
      AppStringKeys.datePeriodNightKorean,
    ],
  };

  static String _two(int n) => n.toString().padLeft(2, '0');

  static String _label(String value) => AppStrings.t(value);

  static String get _localeKey {
    final locale = Intl.getCurrentLocale();
    if (locale.startsWith('zh_Hant') ||
        locale.startsWith('zh-Hant') ||
        locale.contains('_TW') ||
        locale.contains('_HK') ||
        locale.contains('_MO')) {
      return 'zhHant';
    }
    if (locale.startsWith('zh')) return 'zhHans';
    final language = locale.split(RegExp('[-_]')).first;
    return _weekdays.containsKey(language) ? language : 'en';
  }

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  /// Chat-list timestamp.
  static String listLabel(int unix) {
    if (unix <= 0) return '';
    final date = DateTime.fromMillisecondsSinceEpoch(unix * 1000);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (_sameDay(date, now)) return _timeLabel(date);
    if (_sameDay(date, now.subtract(const Duration(days: 1)))) {
      return _label(_yesterday[_localeKey] ?? _yesterday['en']!);
    }
    final dayStart = DateTime(date.year, date.month, date.day);
    final days = today.difference(dayStart).inDays;
    if (days < 7) {
      return _label(
        (_weekdays[_localeKey] ?? _weekdays['en']!)[date.weekday - 1],
      );
    }
    if (date.year == now.year) return '${_two(date.month)}/${_two(date.day)}';
    return '${date.year}/${_two(date.month)}/${_two(date.day)}';
  }

  /// Centered in-conversation separator: "2024/06/04 晚上7:54".
  static String separatorLabel(int unix) {
    if (unix <= 0) return '';
    final date = DateTime.fromMillisecondsSinceEpoch(unix * 1000);
    final now = DateTime.now();
    if (_sameDay(date, now)) return _timeLabel(date);
    final datePart = date.year == now.year
        ? '${_two(date.month)}/${_two(date.day)}'
        : '${date.year}/${_two(date.month)}/${_two(date.day)}';
    return '$datePart ${_timeLabel(date)}';
  }

  /// In-bubble 24-hour time, e.g. "22:47".
  static String bubbleLabel(int unix) {
    if (unix <= 0) return '';
    final date = DateTime.fromMillisecondsSinceEpoch(unix * 1000);
    return '${_two(date.hour)}:${_two(date.minute)}';
  }

  /// Reply quote timestamp, e.g. "Yesterday 0:38".
  static String quoteLabel(int unix) {
    if (unix <= 0) return '';
    final date = DateTime.fromMillisecondsSinceEpoch(unix * 1000);
    final now = DateTime.now();
    final time = '${date.hour}:${_two(date.minute)}';
    if (_sameDay(date, now)) return time;
    if (_sameDay(date, now.subtract(const Duration(days: 1)))) {
      return '${_label(_yesterday[_localeKey] ?? _yesterday['en']!)} $time';
    }
    final datePart = date.year == now.year
        ? '${_two(date.month)}/${_two(date.day)}'
        : '${date.year}/${_two(date.month)}/${_two(date.day)}';
    return '$datePart $time';
  }

  static String _timeLabel(DateTime date) {
    final key = _localeKey;
    if (_periods.containsKey(key)) return _periodTime(date, key);
    return '${_two(date.hour)}:${_two(date.minute)}';
  }

  static String _periodTime(DateTime date, String key) {
    final hour = date.hour;
    final periodSet = _periods[key] ?? _periods['zhHans']!;
    final int periodIndex;
    if (hour < 5) {
      periodIndex = 0;
    } else if (hour < 8) {
      periodIndex = 1;
    } else if (hour < 11) {
      periodIndex = 2;
    } else if (hour < 13) {
      periodIndex = 3;
    } else if (hour < 18) {
      periodIndex = 4;
    } else {
      periodIndex = 5;
    }
    final displayHour = hour <= 12 ? hour : hour - 12;
    return '${_label(periodSet[periodIndex])}$displayHour:${_two(date.minute)}';
  }
}
