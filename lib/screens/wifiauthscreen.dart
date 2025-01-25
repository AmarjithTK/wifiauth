import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For MethodChannel
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/academic.dart'; // AcademicAuth class
import '../utils/hostel.dart'; // HostelWifiAuth class

class WiFiAuthScreen extends StatefulWidget {
  @override
  _WiFiAuthScreenState createState() => _WiFiAuthScreenState();
}

class _WiFiAuthScreenState extends State<WiFiAuthScreen> {
  final TextEditingController _logController = TextEditingController();
  String responseMessage = '';
  String? _connectedWifi; // Tracks the currently connected WiFi
  bool _isAuthenticated = false; // Tracks authentication status

  // Instances of the authentication classes
  final HostelWifiAuth _hostelWifiAuth = HostelWifiAuth();
  final AcademicAuth _academicAuth = AcademicAuth();

  // Method channel to communicate with native Android code
  static const platform = MethodChannel('com.example.wifiauth/network');

  String? _username;
  String? _password;
  String? _secretCode;

  @override
  void initState() {
    super.initState();
    _loadCredentials();
  }

  Future<void> _loadCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('username');
      _password = prefs.getString('password');
      _secretCode = prefs.getString('secretCode');
    });
  }

  /// Connects to the Hostel WiFi network.
  Future<void> connectToHostelWiFi() async {
    if (_username == null || _password == null) {
      setState(() {
        responseMessage = "Credentials not found. Please login first.";
      });
      return;
    }

    _logController.clear();
    _logController.text += "Connecting to Hostel WiFi...\n";

    try {
      final String log = await _hostelWifiAuth.login(_username!, _password!);
      _logController.text += log + "\n";
      setState(() {
        responseMessage = log;
        _isAuthenticated = true;
        _connectedWifi = "Hostel WiFi";
      });

      await _useNetworkAsIs();
    } catch (e) {
      _logController.text += "Error: $e\n";
      setState(() {
        responseMessage = "Error: $e";
        _isAuthenticated = false;
        _connectedWifi = null;
      });
    }
  }

  /// Connects to the Academic WiFi network.
  Future<void> connectToAcademicWiFi() async {
    if (_username == null || _password == null) {
      setState(() {
        responseMessage = "Credentials not found. Please login first.";
      });
      return;
    }

    _logController.clear();
    _logController.text += "Connecting to Academic WiFi...\n";

    try {
      final String log = await _academicAuth.login(_username!, _password!);
      _logController.text += log + "\n";
      setState(() {
        responseMessage = log;
        _isAuthenticated = true;
        _connectedWifi = "Academic WiFi";
      });

      await _useNetworkAsIs();
    } catch (e) {
      _logController.text += "Error: $e\n";
      setState(() {
        responseMessage = "Error: $e";
        _isAuthenticated = false;
        _connectedWifi = null;
      });
    }
  }

  /// Logs out from the connected WiFi network.
  Future<void> logout() async {
    _logController.text += "Logging out from $_connectedWifi...\n";

    try {
      if (_connectedWifi == "Hostel WiFi") {
        final String log = await _hostelWifiAuth.logout();
        _logController.text += log + "\n";
      } else if (_connectedWifi == "Academic WiFi") {
        final String log = await _academicAuth.logout();
        _logController.text += log + "\n";
      }

      setState(() {
        _isAuthenticated = false;
        _connectedWifi = null;
        responseMessage = "Logged out successfully.";
      });
    } catch (e) {
      _logController.text += "Error during logout: $e\n";
      setState(() {
        responseMessage = "Error during logout: $e";
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
        title: Center(child: Text('WiFi Authenticator')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Display connected WiFi card if authenticated
            if (_isAuthenticated && _connectedWifi != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        "Connected to:",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        _connectedWifi!,
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.green,
                        ),
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: logout,
                        child: Text('Logout'),
                      ),
                    ],
                  ),
                ),
              ),

            // Display authentication buttons
            if (!_isAuthenticated) ...[
              ElevatedButton(
                onPressed: connectToHostelWiFi,
                child: Text('Connect to Hostel WiFi'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: connectToAcademicWiFi,
                child: Text('Connect to Academic WiFi'),
              ),
            ],

            SizedBox(height: 20),
            Text(responseMessage),
            SizedBox(height: 20),

            // Display detailed logs
            Expanded(
              child: TextField(
                controller: _logController,
                maxLines: null, // Allow multiple lines
                readOnly: true, // Make it read-only
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Detailed Logs',
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "Made by AmarjithTK (B22EE)",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
