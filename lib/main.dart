import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
import 'package:flutter/services.dart'; // For MethodChannel

// Import the authentication classes from lib/utils
import './utils/academic.dart'; // AcademicAuth class
import './utils/hostel.dart'; // HostelWifiAuth class

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WiFi Authenticator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: WiFiAuthenticatorScreen(),
    );
  }
}

class WiFiAuthenticatorScreen extends StatefulWidget {
  @override
  _WiFiAuthenticatorScreenState createState() =>
      _WiFiAuthenticatorScreenState();
}

class _WiFiAuthenticatorScreenState extends State<WiFiAuthenticatorScreen> {
  final TextEditingController _logController = TextEditingController();
  String responseMessage = '';

  // Instances of the authentication classes
  final HostelWifiAuth _hostelWifiAuth = HostelWifiAuth();
  final AcademicAuth _academicAuth = AcademicAuth();

  // Method channel to communicate with native Android code
  static const platform = MethodChannel('com.example.wifiauth/network');

  /// Connects to the Hostel WiFi network.
  Future<void> connectToHostelWiFi() async {
    _logController.clear();
    _logController.text += "Connecting to Hostel WiFi...\n";

    try {
      final String log =
          await _hostelWifiAuth.login("amarjith_b220682ee", "j2");
      _logController.text += log + "\n";
      setState(() {
        responseMessage = log;
      });

      // Mark the network as validated after successful login
      await _useNetworkAsIs();
    } catch (e) {
      _logController.text += "Error: $e\n";
      setState(() {
        responseMessage = "Error: $e";
      });
    }
  }

  /// Connects to the Academic WiFi network.
  Future<void> connectToAcademicWiFi() async {
    _logController.clear();
    _logController.text += "Connecting to Academic WiFi...\n";

    try {
      final String log = await _academicAuth.login("amarjith_b220682ee", "j2");
      _logController.text += log + "\n";
      setState(() {
        responseMessage = log;
      });

      // Mark the network as validated after successful login
      await _useNetworkAsIs();
    } catch (e) {
      _logController.text += "Error: $e\n";
      setState(() {
        responseMessage = "Error: $e";
      });
    }
  }

  /// Marks the network as validated using the native method.
  Future<void> _useNetworkAsIs() async {
    try {
      // Call the native method to mark the network as validated
      await platform.invokeMethod('useNetworkAsIs');
      _logController.text += "Network marked as validated.\n";
    } on PlatformException catch (e) {
      _logController.text +=
          "Failed to mark network as validated: ${e.message}\n";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('WiFi Authenticator'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: connectToHostelWiFi,
              child: Text('Connect to Hostel WiFi'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: connectToAcademicWiFi,
              child: Text('Connect to Academic WiFi'),
            ),
            SizedBox(height: 20),
            Text(responseMessage),
            SizedBox(height: 20),
            Expanded(
              child: TextField(
                controller: _logController,
                maxLines: null, // Allow multiple lines
                readOnly: true, // Make it read-only
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Logs and Response',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
