import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './screens/wifiauthscreen.dart';
import './screens/firstscreen.dart';
import 'package:permission_handler/permission_handler.dart';


// Import the WiFiAuthScreen

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

    await _requestNotificationPermission();

  final prefs = await SharedPreferences.getInstance();
  final bool isFirstTime = prefs.getString('username') == null;
  await AwesomeNotifications().initialize(
    null,
    [
      NotificationChannel(
        channelKey: 'basic_channel',
        channelName: 'Basic Notifications',
        channelDescription: 'Notification channel for basic features',
        importance: NotificationImportance.Max,
        locked: true,
      )
    ],
  );
  runApp(MyApp(isFirstTime: isFirstTime));
}

Future<void> _requestNotificationPermission() async {
  // Check if the notification permission is granted
  PermissionStatus status = await Permission.notification.request();

  if (status.isGranted) {
    print("Notification permission granted.");
  } else {
    print("Notification permission denied.");
  }
}

class MyApp extends StatelessWidget {
  final bool isFirstTime;

  MyApp({required this.isFirstTime});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WiFi Authenticator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: isFirstTime ? FirstTimeLoginScreen() : WiFiAuthScreen(),
    );
  }
}
