enum CalendarEventType {
  applicationStart,
  applicationDeadline,
  admitCardRelease,
  examDate,
  resultDate;

  String get label {
    switch (this) {
      case CalendarEventType.applicationStart:
        return 'App Starts';
      case CalendarEventType.applicationDeadline:
        return 'Last Date to Apply';
      case CalendarEventType.admitCardRelease:
        return 'Admit Card Out';
      case CalendarEventType.examDate:
        return 'Exam Day';
      case CalendarEventType.resultDate:
        return 'Result Declaration';
    }
  }

  // Hex color tag or Material color mapping
  int get colorValue {
    switch (this) {
      case CalendarEventType.applicationStart:
        return 0xFF10B981; // Green
      case CalendarEventType.applicationDeadline:
        return 0xFFEF4444; // Red / Alert
      case CalendarEventType.admitCardRelease:
        return 0xFF3B82F6; // Blue
      case CalendarEventType.examDate:
        return 0xFF8B5CF6; // Purple
      case CalendarEventType.resultDate:
        return 0xFFF59E0B; // Amber
    }
  }
}

class ExamCalendarEvent {
  final String id;
  final String jobId;
  final String jobTitle;
  final String organization;
  final CalendarEventType eventType;
  final DateTime date;
  final String description;
  final String? actionUrl;
  final bool isEligibleForUser;

  ExamCalendarEvent({
    required this.id,
    required this.jobId,
    required this.jobTitle,
    required this.organization,
    required this.eventType,
    required this.date,
    required this.description,
    this.actionUrl,
    this.isEligibleForUser = true,
  });

  bool get isToday {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  bool get isUpcoming {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final eventDay = DateTime(date.year, date.month, date.day);
    return eventDay.isAfter(today) || eventDay.isAtSameMomentAs(today);
  }

  int get daysRemaining {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final eventDay = DateTime(date.year, date.month, date.day);
    return eventDay.difference(today).inDays;
  }
}
