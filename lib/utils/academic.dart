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

      // Check if the response is a redirect (status code 3xx)
      if (response.statusCode >= 300 && response.statusCode < 400) {
        // Extract the redirect URL from the 'Location' header
        String? redirectUrl = response.headers['location'];
        if (redirectUrl != null) {
          // Fetch the redirect URL to get the login page
          var redirectResponse = await http.get(Uri.parse(redirectUrl));
          if (redirectResponse.statusCode == 200) {
            // Extract webAddress and secureKey from the redirect response
            webAddress = extractWebAddress(redirectResponse.body);
            secureKey = extractSecureKey(redirectResponse.body);
            return (
              isLoggedIn: false,
              log: "Not logged in. Redirected to login page."
            );
          } else {
            return (
              isLoggedIn: false,
              log:
                  "Failed to fetch redirect page. Status code: ${redirectResponse.statusCode}"
            );
          }
        } else {
          return (isLoggedIn: false, log: "Redirect location header missing.");
        }
      } else if (response.statusCode == 204) {
        return (isLoggedIn: true, log: "Already logged in.");
      } else {
        return (
          isLoggedIn: false,
          log: "Not logged in. Status code: ${response.statusCode}"
        );
      }
    } catch (e) {
      // Handle network errors (e.g., gstatic.com unreachable)
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

    if (webAddress.isEmpty || secureKey.isEmpty) {
      return "Failed to extract necessary information for login.";
    }

    try {
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
    } catch (e) {
      return "Error during login: $e";
    }
  }

  /// Logs out from the academic network.
  ///
  /// Returns a log message describing the result.
  Future<String> logout() async {
    if (webAddress.isEmpty || secureKey.isEmpty) {
      return "No login details found. Please login first.";
    }

    try {
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
    } catch (e) {
      return "Error during logout: $e";
    }
  }

  /// Extracts the web address from the HTML response.
  String extractWebAddress(String body) {
    // Regex to extract the web address from the HTML response
    // Example: <a href="http://172.20.28.1/fgtauth?0d080d000a135b5c">
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
    // Example: <a href="http://172.20.28.1/fgtauth?0d080d000a135b5c">
    RegExp regex = RegExp(r'fgtauth\?([^"]+)"');
    Match? match = regex.firstMatch(body);
    if (match != null) {
      return match.group(1)!; // Extract the secure key
    }
    return '';
  }
}
