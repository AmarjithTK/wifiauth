import 'dart:io';
import 'package:http/http.dart' as http;

class HostelWifiAuth {
  // Base URL for the authentication server
  final String _baseUrl = "http://172.20.28.1:8002";
  final String _zone = "hostelzone";
  final String _redirUrl = "google.co.in";

  // Variables to store login and logout details
  String? _logoutId;

  /// Logs in to the Hostel WiFi network.
  ///
  /// [username]: The username for authentication.
  /// [password]: The password for authentication.
  Future<void> login(String username, String password) async {
    final String url = "$_baseUrl/index.php?zone=$_zone&redirurl=$_redirUrl";

    try {
      // Send the login POST request
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
        },
        body: {
          "auth_user": username,
          "auth_pass": password,
          "redirurl": _redirUrl,
          "accept": "login",
        },
      );

      if (response.statusCode == 200) {
        print("Login successful.");
        _extractLogoutId(response.body); // Extract logout_id from the response
      } else {
        print("Login failed. Status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error during login: $e");
    }
  }

  /// Logs out from the Hostel WiFi network.
  Future<void> logout() async {
    if (_logoutId == null) {
      print("No logout ID found. Please login first.");
      return;
    }

    final String url = "$_baseUrl/index.php";

    try {
      // Send the logout POST request
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
        },
        body: {
          "logout_id": _logoutId!,
          "zone": _zone,
          "logout": "Logout",
        },
      );

      if (response.statusCode == 200) {
        print("Logout successful.");
      } else {
        print("Logout failed. Status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error during logout: $e");
    }
  }

  /// Extracts the `logout_id` from the login response HTML.
  ///
  /// [html]: The HTML response body from the login request.
  void _extractLogoutId(String html) {
    // Regex to extract the logout_id from the HTML response
    RegExp regex = RegExp(r'name="logout_id" type="hidden" value="([^"]+)"');
    Match? match = regex.firstMatch(html);

    if (match != null) {
      _logoutId = match.group(1);
      print("Logout ID extracted: $_logoutId");
    } else {
      print("Failed to extract logout ID from the response.");
    }
  }
}
