import 'package:http/http.dart' as http;

class AcademicAuth {
  final String loginUrl = 'http://www.gstatic.com/generate_204';
  String webAddress = '';
  String secureKey = '';

  /// Checks if the user is already logged in.
  ///
  /// Returns a tuple containing:
  /// - A boolean indicating whether the user is logged in.
  /// - A log message describing the result.
  Future<({bool isLoggedIn, String log})> checkLoginStatus() async {
    try {
      var response = await http.get(Uri.parse(loginUrl));
      if (response.statusCode == 204) {
        return (isLoggedIn: true, log: "Already logged in.");
      }
      return (isLoggedIn: false, log: "Not logged in.");
    } catch (e) {
      return (isLoggedIn: false, log: "Error checking login status: $e");
    }
  }

  /// Logs in to the academic network.
  ///
  /// [username]: The username for authentication.
  /// [password]: The password for authentication.
  ///
  /// Returns a log message describing the result.
  Future<String> login(String username, String password) async {
    var loginStatus = await checkLoginStatus();
    if (loginStatus.isLoggedIn) {
      return loginStatus.log; // Return log if already logged in
    }

    var response = await http.get(Uri.parse(loginUrl));
    if (response.statusCode != 200) {
      return "Failed to fetch login page. Status code: ${response.statusCode}";
    }

    var body = response.body;
    webAddress = extractWebAddress(body);
    secureKey = extractSecureKey(body);

    if (webAddress.isEmpty || secureKey.isEmpty) {
      return "Failed to extract necessary information for login.";
    }

    var loginResponse = await http.post(
      Uri.parse('$webAddress/fgtauth?$secureKey'),
      body: {
        '4Tredir': 'http://www.gstatic.com/generate_204',
        'magic': secureKey,
        'username': username,
        'password': password,
      },
    );

    if (loginResponse.statusCode == 200) {
      return "Login successful.";
    } else {
      return "Login failed. Status code: ${loginResponse.statusCode}";
    }
  }

  /// Logs out from the academic network.
  ///
  /// Returns a log message describing the result.
  Future<String> logout() async {
    if (webAddress.isEmpty || secureKey.isEmpty) {
      return "No login details found. Please login first.";
    }

    var logoutResponse = await http.get(
      Uri.parse('$webAddress/logout?$secureKey'),
      headers: {
        'Referer': '$webAddress/keepalive?$secureKey',
      },
    );

    if (logoutResponse.statusCode == 200) {
      return "Logout successful.";
    } else {
      return "Logout failed. Status code: ${logoutResponse.statusCode}";
    }
  }

  /// Extracts the web address from the HTML response.
  String extractWebAddress(String body) {
    // Regex to extract the web address from the HTML response
    // Example: <a href="http://192.168.102.1:1000/fgtauth?0d080d000a135b5c">
    RegExp regex = RegExp(r'href="(http://[^"]+fgtauth\?[^"]+)"');
    Match? match = regex.firstMatch(body);
    if (match != null) {
      return match.group(1)!.split('fgtauth')[0]; // Extract the base URL
    }
    return '';
  }

  /// Extracts the secure key from the HTML response.
  String extractSecureKey(String body) {
    // Regex to extract the secure key from the HTML response
    // Example: <a href="http://192.168.102.1:1000/fgtauth?0d080d000a135b5c">
    RegExp regex = RegExp(r'fgtauth\?([^"]+)"');
    Match? match = regex.firstMatch(body);
    if (match != null) {
      return match.group(1)!; // Extract the secure key
    }
    return '';
  }
}
