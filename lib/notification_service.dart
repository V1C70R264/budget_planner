import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:open_file/open_file.dart';

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
    const InitializationSettings initializationSettings =
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
    const InitializationSettings initializationSettings =
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
    print("Current progress: $progress");

    late final AndroidNotificationDetails androidPlatformChannelSpecifics;
    String title;
    String body;

    if (progress <= 99) {
     // print("Showing progress notification");
      androidPlatformChannelSpecifics = AndroidNotificationDetails(
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
      title = 'Downloading Receipt';
      body = 'Progress: $progress%';
    } else {
     // print("Showing completion notification");
      androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'progress_channel',
        'Progress Notifications',
        channelDescription: 'Notifications for download progress',
        importance: Importance.max,
        priority: Priority.high,
      );
      title = 'Receipt Downloaded Successfully';
      body = 'Tap to open your PDF';
    }

    final NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
    );
  }

  Future<void> showCompletedNotification(String filePath) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'completion_channel',
      'Completion Notifications',
      channelDescription: 'Notifications for completed tasks',
      importance: Importance.max,
      priority: Priority.high,
      icon: 'download_complete',
      largeIcon: DrawableResourceAndroidBitmap('download_complete'),
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      1,
      'PDF Generated',
      'Tap to open your PDF',
      platformChannelSpecifics,
      payload: filePath,
    );
  }

  Future<void> showBalanceNotification(double remainingBalance, double depositedAmount) async {
    //print("Checking balance: Remaining = $remainingBalance, Deposited = $depositedAmount");
    
    if (depositedAmount > 0 && remainingBalance <= depositedAmount / 2) {
     // print("Balance is half or less than half of deposited amount. Showing notification.");
      const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'balance_alert_channel',
        'Balance Alert Notifications',
        channelDescription: 'Notifications for low balance alerts',
        importance: Importance.max,
        priority: Priority.high,
      );
      const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
      
      await flutterLocalNotificationsPlugin.show(
        0,
        'Balance Alert ⚠️',  // Added caution emoji here
        'Your balance is TZS ${remainingBalance.toStringAsFixed(2)}/=',
        platformChannelSpecifics,
      );
    } else {
      //print("Balance is still above half of deposited amount. No notification shown.");
    }
  }
}
