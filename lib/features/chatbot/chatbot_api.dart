import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// Define your API base URL and version.
const String API_URL = 'http://127.0.0.1:3000';
const String API_VERSION = 'v1';

class ChatbotApi {
  /// Retrieves the chatbot history messages.
  /// The returned data is an array of objects with the following keys:
  /// - message: The text of the message.
  /// - isBot: 0 for user message, 1 for bot message.
  /// - created_at: The message timestamp.
  static Future<dynamic> getHistoryChatBot() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('accessToken') ?? '';
      final url = Uri.parse('$API_URL/api/$API_VERSION/chatbot/history');
      final response = await http.get(url, headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      });

      if (response.statusCode != 200) {
        throw Exception("Failed to fetch chatbot history");
      }

      final data = json.decode(response.body);
      return data;
    } catch (error) {
      print("Error fetching chatbot history: $error");
      return null;
    }
  }

  /// Sends a message to the chatbot and returns the reply content.
  /// The API endpoint is `/api/v1/chatbot/message` and expects a payload:
  /// { "message": "Hello World!" }
  /// It returns a response with a "content" field.
  static Future<dynamic> sendMessageToChatBot(String message) async {
    if (message.isEmpty) {
      return null;
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('accessToken') ?? '';
      final url = Uri.parse('$API_URL/api/$API_VERSION/chatbot/message');
      final body = json.encode({
        'message': message,
      });

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: body,
      );

      if (response.statusCode != 200) {
        throw Exception("Failed to send message to chatbot");
      }

      final data = json.decode(response.body);
      if (data['content'] != null) {
        return data['content'];
      }
      return null;
    } catch (error) {
      print("Error sending message to chatbot: $error");
      return null;
    }
  }

  /// Clears the chatbot history messages.
  /// Uses the DELETE method on the `/api/v1/chatbot/history` endpoint.
  static Future<dynamic> clearHistoryChatBot() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('accessToken') ?? '';
      final url = Uri.parse('$API_URL/api/$API_VERSION/chatbot/history');
      final response = await http.delete(url, headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      });

      if (response.statusCode != 200) {
        throw Exception("Failed to clear chatbot history");
      }

      final data = json.decode(response.body);
      return data;
    } catch (error) {
      print("Error clearing chatbot history: $error");
      return null;
    }
  }
}
