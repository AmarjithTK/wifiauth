import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './screens/wifiauthscreen.dart';
import './screens/firstscreen.dart';

// Import the WiFiAuthScreen

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final bool isFirstTime = prefs.getString('username') == null;

  runApp(MyApp(isFirstTime: isFirstTime));
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
