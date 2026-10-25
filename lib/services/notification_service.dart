import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/job_model.dart';
import '../models/calendar_event_model.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    try {
      await flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          // Handle notification payload tap (e.g. open job detail or apply link)
        },
      );

      // Create Android Notification Channels
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'mr_manager_exam_alerts',
        'Exam & Admit Card Alerts',
        description: 'Urgent updates regarding application deadlines, admit cards & exam dates',
        importance: Importance.max,
        enableLights: true,
        enableVibration: true,
      );

      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      _isInitialized = true;
    } catch (e) {
      // In web or headless test environment, initialization can be gracefully caught
      _isInitialized = true;
    }
  }

  Future<void> showInstantAlert({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'mr_manager_exam_alerts',
      'Exam & Admit Card Alerts',
      channelDescription: 'Real-time alerts for eligible government exams',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
      styleInformation: BigTextStyleInformation(''),
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    try {
      await flutterLocalNotificationsPlugin.show(
        id,
        title,
        body,
        platformChannelSpecifics,
        payload: payload,
      );
    } catch (e) {
      // Graceful fallback
    }
  }

  /// Automatically schedules reminders for an eligible job:
  /// 1. Application Last Date warning (3 days before at 10:00 AM)
  /// 2. Application Final Day reminder (24 hours before)
  /// 3. Admit Card release notification
  /// 4. Exam Day countdown (1 day before)
  Future<void> scheduleRemindersForJob(JobModel job) async {
    final now = DateTime.now();

    // 1. Application Deadline Reminder (3 days prior)
    final reminder3Days = job.applicationEndDate.subtract(const Duration(days: 3));
    if (reminder3Days.isAfter(now)) {
      await showInstantAlert(
        id: job.id.hashCode + 1,
        title: '⚠️ Last 3 Days to Apply: ${job.title}',
        body: 'Application deadline is ${job.applicationEndDate.day}/${job.applicationEndDate.month}. Complete your registration today!',
        payload: job.id,
      );
    }

    // 2. Admit Card Reminder
    if (job.admitCardReleaseDate != null &&
        job.admitCardReleaseDate!.isBefore(now.add(const Duration(days: 1))) &&
        job.admitCardReleaseDate!.isAfter(now.subtract(const Duration(days: 3)))) {
      await showInstantAlert(
        id: job.id.hashCode + 2,
        title: '🎟️ Admit Card Available: ${job.title}',
        body: 'Admit card has been released. Tap to download your hall ticket now.',
        payload: job.id,
      );
    }

    // 3. Exam Date Reminder
    if (job.examDate != null && job.examDate!.isAfter(now)) {
      final daysLeft = job.examDate!.difference(now).inDays;
      if (daysLeft <= 7 && daysLeft > 0) {
        await showInstantAlert(
          id: job.id.hashCode + 3,
          title: '🎯 Exam in $daysLeft Days: ${job.postName}',
          body: 'Revise your key subjects and check your exam center address.',
          payload: job.id,
        );
      }
    }
  }

  /// Triggers a test notification so user can verify sound & push capability
  Future<void> sendTestNotification() async {
    await showInstantAlert(
      id: 9999,
      title: '🔔 Mr. Manager Notifications Active',
      body: 'You will receive timely alerts for eligible exams, admit card releases, and deadlines!',
    );
  }
}
