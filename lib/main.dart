import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart'; // For MethodChannel

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Authenticate App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AuthenticateScreen(),
    );
  }
}

class AuthenticateScreen extends StatefulWidget {
  @override
  _AuthenticateScreenState createState() => _AuthenticateScreenState();
}

class _AuthenticateScreenState extends State<AuthenticateScreen> {
  final String username = 'amarjith_b220682ee'; // Hardcoded username
  final String password = 'j2'; // Hardcoded password
  String responseMessage = '';
  final TextEditingController _logController = TextEditingController();

  // Method channel to communicate with native Android code
  static const platform = MethodChannel('com.example.wifiauth/network');

  Future<void> authenticate() async {
    final String redirurl = "google.co.in";
    final String url =
        "http://172.20.28.1:8002/index.php?zone=hostelzone&redirurl=$redirurl";

    // Clear previous logs
    _logController.clear();

    // Add request details to the log
    _logController.text += "Sending POST request to: $url\n";
    _logController.text += "Headers: {\n";
    _logController.text +=
        "  \"Content-Type\": \"application/x-www-form-urlencoded\"\n";
    _logController.text += "}\n";
    _logController.text += "Body: {\n";
    _logController.text += "  \"auth_user\": \"$username\",\n";
    _logController.text += "  \"auth_pass\": \"$password\",\n";
    _logController.text += "  \"redirurl\": \"$redirurl\",\n";
    _logController.text += "  \"accept\": \"login\"\n";
    _logController.text += "}\n\n";

    try {
      // Step 1: Send the login request
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
        },
        body: {
          "auth_user": username,
          "auth_pass": password,
          "redirurl": redirurl,
          "accept": "login",
        },
      ).timeout(Duration(seconds: 10)); // Add a timeout

      // Add response details to the log
      _logController.text += "Response received:\n";
      _logController.text += "Status Code: ${response.statusCode}\n";
      _logController.text += "Headers: ${response.headers}\n";
      _logController.text += "Body:\n${response.body}\n";

      if (response.statusCode == 200) {
        setState(() {
          responseMessage = "Authentication successful!";
        });

        // Step 2: Notify Android that the network is authenticated
        // await notifyAndroidOfSuccessfulLogin();

        // Step 3: Mark the network as validated
        await _useNetworkAsIs();
      } else {
        setState(() {
          responseMessage =
              "Authentication failed. Status code: ${response.statusCode}";
        });
      }
    } catch (e) {
      // Add error details to the log
      _logController.text += "Error: $e\n";
      setState(() {
        responseMessage = "Error: $e";
      });
    }
  }

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
        title: Text('Authenticate'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: authenticate,
              child: Text('Authenticate'),
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
