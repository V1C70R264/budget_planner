import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:open_file/open_file.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal() {
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const  InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        _onSelectNotification(response.payload);
      },
    );
  }

  Future _onSelectNotification(String? payload) async {
    if (payload != null) {
      await OpenFile.open(payload);
    }
  }

  Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> showStylishNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'your_channel_id',
      'Your Channel Name',
      channelDescription: 'Your channel description',
      importance: Importance.max,
      priority: Priority.high,
      styleInformation: BigTextStyleInformation(
        'Time to check your budget!',
        htmlFormatBigText: true,
        contentTitle: '<b>MoneyMinder</b>',
        htmlFormatContentTitle: true,
        summaryText: 'Budget reminder',
        htmlFormatSummaryText: true,
      ),
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      'MoneyMinder',
      'Time to check your budget!',
      platformChannelSpecifics,
    );
  }

  Future<void> showProgressNotification(int progress) async {
    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'progress_channel',
      'Progress Notifications',
      channelDescription: 'Notifications for download progress',
      importance: Importance.max,
      priority: Priority.high,
      onlyAlertOnce: true,
      showProgress: true,
      maxProgress: 100,
      progress: progress,
    );
    final NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      'Downloading Receipt',
      'Progress: $progress%',
      platformChannelSpecifics,
    );
  }

  Future<void> showCompletedNotification(String filePath) async {
    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'completion_channel',
      'Completion Notifications',
      channelDescription: 'Notifications for completed tasks',
      importance: Importance.max,
      priority: Priority.high,
      icon: 'download_complete',
      largeIcon: DrawableResourceAndroidBitmap('download_complete'),
    );
    final NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      1,
      'PDF Generated',
      'Tap to open your PDF',
      platformChannelSpecifics,
      payload: filePath,
    );
  }
}
