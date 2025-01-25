import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './wifiauthscreen.dart'; // Import the WiFiAuthScreen

class FirstTimeLoginScreen extends StatefulWidget {
  @override
  _FirstTimeLoginScreenState createState() => _FirstTimeLoginScreenState();
}

class _FirstTimeLoginScreenState extends State<FirstTimeLoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _secretCodeController = TextEditingController();

  Future<void> _saveCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', _usernameController.text);
    await prefs.setString('password', _passwordController.text);
    await prefs.setString('secretCode', _secretCodeController.text);

    // Navigate to the WiFiAuthScreen after saving credentials
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => WiFiAuthScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('First Time Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            TextField(
              controller: _secretCodeController,
              decoration: InputDecoration(labelText: 'Secret Access Code'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveCredentials,
              child: Text('Save Credentials'),
            ),
            SizedBox(height: 20),
            Text(
              "Made by Amarjith TK",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
