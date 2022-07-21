import 'package:dart_date/dart_date.dart';

import 'package:timeago/timeago.dart' as timeago;

class FormalDates {
  static String? timeAgo({required DateTime? date}) {
    if (date != null) {
      if (date.year == DateTime.now().year) {
        return timeago.format(date);
      } else {
        return formatDmyyyyHm(date: date);
      }
    }
    return null;
  }

  static String? formatDmyyyyHm({required DateTime? date}) {
    // Wed, 1 Jan, 2023 • 14:00
    if (date != null) {
      return date.format('dd MMM, yyyy • HH:mm');
    }
    return null;
  }

  static String? formatEDmyyyy({required DateTime? date}) {
    // Wed, 1 Jan, 2023
    if (date != null) {
      return date.format('E, dd MMM, yyyy');
    }
    return null;
  }

  // Date of birth text.
  static String? formatDmyyyy({required DateTime? date}) {
    // 11 Jan 2023
    if (date != null) {
      return date.format('dd MMM yyyy');
    }
    return null;
  }

  static String? formatHm({required DateTime? date}) {
    // 14:00
    if (date != null) {
      return date.format('HH:mm');
    }
    return null;
  }

  static String playerDuration({required Duration duration}) {
    // formats the episode duration in hh:mm:ss
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    final hours = twoDigits(duration.inHours);
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));

    return [
      if (duration.inHours > 0) hours,
      minutes,
      seconds,
    ].join(':');
  }
}
