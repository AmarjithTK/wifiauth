import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import '../utils/hostel.dart';

class WiFiAuthScreen extends StatefulWidget {
  @override
  _WiFiAuthScreenState createState() => _WiFiAuthScreenState();
}

class _WiFiAuthScreenState extends State<WiFiAuthScreen> {
  final TextEditingController _logController = TextEditingController();
  String responseMessage = '';
  final HostelWifiAuth _hostelWifiAuth = HostelWifiAuth();
  static const platform = MethodChannel('com.example.wifiauth/network');
  String? _username;
  String? _password;

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _loadCredentials();
  }

  Future<void> _initializeNotifications() async {
    await AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelKey: 'wifi_channel',
          channelName: 'WiFi Control',
          channelDescription: 'Notification channel for WiFi controls',
          defaultColor: Colors.blue,
          importance: NotificationImportance.Max,
          locked: true, // Prevents dismissing by swipe
        )
      ],
    );

    AwesomeNotifications().setListeners(
      onActionReceivedMethod: onActionReceivedMethod,
    );

    await _createPersistentNotification();
  }

  @pragma('vm:entry-point')
  static Future<void> onActionReceivedMethod(ReceivedAction receivedAction) async {
    WidgetsFlutterBinding.ensureInitialized(); // Ensure Flutter engine is ready

    if (receivedAction.buttonKeyPressed == 'connect') {
      final prefs = await SharedPreferences.getInstance();
      final username = prefs.getString('username');
      final password = prefs.getString('password');

      if (username != null && password != null) {
        try {
          await HostelWifiAuth().login(username, password);
          await const MethodChannel('com.example.wifiauth/network')
              .invokeMethod('useNetworkAsIs'); // Ensure network is used as expected
        } catch (e) {
          print('Background connection error: $e');
        }
      }

      // Re-create the notification so it doesn't disappear
      await _createPersistentNotification();
    }
  }

  static Future<void> _createPersistentNotification() async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 1,
        channelKey: 'wifi_channel',
        title: 'Hostel WiFi Control',
        body: 'Tap Connect Now to connect',
        locked: true,
        autoDismissible: false, // Ensures the notification remains until manually disabled
        notificationLayout: NotificationLayout.Default,
      ),
      actionButtons: [
        NotificationActionButton(
          key: 'connect',
          label: 'Connect Now',
          actionType: ActionType.SilentBackgroundAction,
        )
      ],
    );
  }

  Future<void> _loadCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('username');
      _password = prefs.getString('password');
    });
  }

  Future<void> connectToHostelWiFi() async {
    _logController.text += "\n[${DateTime.now()}] Connection attempt initiated\n";

    if (_username == null || _password == null) {
      setState(() => responseMessage = "Credentials not found");
      _logController.text += "[${DateTime.now()}] Credentials missing\n";
      return;
    }

    try {
      final String log = await _hostelWifiAuth.login(_username!, _password!);
      _logController.text += "[${DateTime.now()}] $log\n";
      setState(() => responseMessage = log);
      await _useNetworkAsIs();
    } catch (e) {
      _logController.text += "[${DateTime.now()}] Error: $e\n";
      setState(() => responseMessage = "Error: $e");
    }
  }

  Future<void> _useNetworkAsIs() async {
    try {
      await platform.invokeMethod('useNetworkAsIs');
      _logController.text += "[${DateTime.now()}] Network validated\n";
    } on PlatformException catch (e) {
      _logController.text += "[${DateTime.now()}] Validation error: ${e.message}\n";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: const Text(
            'NITC Hostel WiFiAuth',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.normal, color: Colors.black),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 2,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(height: 50,),
            ElevatedButton(
              onPressed: connectToHostelWiFi,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 15),
                textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
              ),
              child: const Text('Connect to Hostel WiFi'),
            ),
            const SizedBox(height: 24),
            Text(
              responseMessage,
              style: const TextStyle(fontSize: 18, color: Colors.black87),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Expanded(
              child: TextField(
                controller: _logController,
                maxLines: null,
                readOnly: true,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Connection Logs',
                  labelStyle: TextStyle(fontSize: 18),
                  contentPadding: EdgeInsets.all(16),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "Made by AmarjithTK (B22EE)",
                style: TextStyle(
                  fontSize: 25,
                  color: Colors.deepPurple,
                  fontStyle: FontStyle.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
