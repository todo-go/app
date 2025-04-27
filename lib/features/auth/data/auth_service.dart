import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final String? baseUrl = dotenv.env['API_URL'];

  Future<void> registerUser(String phoneNumber, String name) async {
    if (baseUrl == null) {
      throw Exception('API_URL is not defined in .env file');
    }

    final url = Uri.parse('$baseUrl/api/users');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phoneNumber': phoneNumber, 'name': name}),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final uuid = data['uuid'];
        final id = data['id'].toString();

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('uuid', uuid);
        await prefs.setString('id', id);
      } else {
        throw Exception('Failed to register user: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error during API call: $e');
    }
  }

  Future<String?> getSavedUuid() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('uuid');
  }
}
