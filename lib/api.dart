import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Api {
  static const String _apiUrl = "http://127.0.0.1:3000";

  /// Save accessToken and its expiry to SharedPreferences.
  static Future<void> _saveToken(String token, DateTime expiry) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('accessToken', token);
    await prefs.setString('expiresAt', expiry.toIso8601String());
  }

  /// Retrieve accessToken from SharedPreferences.
  static Future<String?> _getLocalToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('accessToken');
  }

  /// Retrieve token expiry from SharedPreferences.
  static Future<DateTime?> _getLocalTokenExpiry() async {
    final prefs = await SharedPreferences.getInstance();
    final expiryStr = prefs.getString('expiresAt');
    if (expiryStr != null) {
      return DateTime.parse(expiryStr);
    }
    return null;
  }

  /// Check whether the current token is valid based on local storage.
  static Future<bool> _isTokenValid(String accessToken) async {
    final localToken = await _getLocalToken();
    final expiry = await _getLocalTokenExpiry();
    if (localToken == null || expiry == null) return false;
    return (localToken == accessToken && DateTime.now().isBefore(expiry));
  }

  /// API login using POST /students/login.
  /// On success, saves accessToken and sets an expiry (60 minutes).
  static Future<String?> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$_apiUrl/students/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['accessToken'] as String;
      final now = DateTime.now();
      final expiry = now.add(const Duration(minutes: 60));
      await _saveToken(token, expiry);
      return token;
    }
    return null;
  }

  /// Registers a new student.
  /// Sends a POST request to $_apiUrl/students/register with the following fields:
  /// firstName, lastName, dob, email, password, and gender.
  /// Gender is mapped as follows: "Male" -> 0, "Female" -> 1, "Other" -> 2.
  /// On success, returns the access token.
  static Future<String?> register({
    required String firstName,
    required String lastName,
    required String dob,
    required String email,
    required String password,
    required String gender,
  }) async {
    // Parse the date to SQL-compatible format.
    // final parsedDob = parseDate(dob);

    // Map gender string to an integer.
    int genderValue;
    if (gender == "Male") {
      genderValue = 0;
    } else if (gender == "Female") {
      genderValue = 1;
    } else {
      genderValue = 2;
    }

    final response = await http.post(
      Uri.parse('$_apiUrl/students/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'firstName': firstName,
        'lastName': lastName,
        'dob': dob,
        'email': email,
        'password': password,
        'gender': genderValue,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      final token = data['accessToken']?.toString();
      return token;
    }
    return null;
  }

  /// API call to get detailed student info using GET /students/info.
  /// Debug prints have been added for console logging.
  static Future<Map<String, String>> getStudentDetails({
    required String accessToken,
  }) async {
    final response = await http.get(
      Uri.parse('$_apiUrl/students/info'),
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    print('getStudentDetails response status: ${response.statusCode}');
    print('getStudentDetails response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return {
        'name': data['name'] ?? '',
        'studentId': data['studentId']?.toString() ?? '',
        'email': data['email'] ?? '',
        'dob': data['dob'] ?? '',
        'phone': data['phone'] ?? '',
      };
    } else {
      throw Exception("Phiên đăng nhập hết hạn, vui lòng đăng nhập lại!");
    }
  }

  /// Simulated API call to get class list for home page (requires valid accessToken).
  static Future<List<Map<String, String>>> getClasses({
    required String accessToken,
  }) async {
    if (!await _isTokenValid(accessToken)) {
      throw Exception("Phiên đăng nhập hết hạn, vui lòng đăng nhập lại!");
    }
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      {
        "title": "LUYỆN THI TOEIC",
        "session": "Buổi 1: Present Tenses",
        "timeRange": "9:00 - 10:30",
        "date": "Thứ 6, 2/3/2025",
        "teacher": "Thầy John Smith",
        "room": "E303",
        "status": "Đang diễn ra"
      },
      {
        "title": "LUYỆN THI IELTS",
        "session": "Buổi 2: Future Tenses",
        "timeRange": "10:45 - 12:00",
        "date": "Thứ 6, 2/3/2025",
        "teacher": "Cô Anna",
        "room": "E305",
        "status": "Sắp diễn ra"
      },
    ];
  }

  /// Simulated API call to get detailed student info (requires valid accessToken).
  /// This function is kept for legacy use (if no dedicated route exists).
  static Future<Map<String, String>> getStudentExtraDetails({
    required String accessToken,
  }) async {
    if (!await _isTokenValid(accessToken)) {
      throw Exception("Phiên đăng nhập hết hạn, vui lòng đăng nhập lại!");
    }
    await Future.delayed(const Duration(milliseconds: 500));
    return {
      "name": "TRƯỜNG VĂN TÀI",
      "studentId": "MSHV: G16-001",
      "email": "student@example.com",
      "dob": "01/01/2000",
      "phone": "0123456789",
    };
  }

  /// Simulated API call to check for new notifications (requires valid accessToken).
  static Future<bool> hasNotification({
    required String accessToken,
  }) async {
    if (!await _isTokenValid(accessToken)) {
      throw Exception("Phiên đăng nhập hết hạn, vui lòng đăng nhập lại!");
    }
    await Future.delayed(const Duration(milliseconds: 500));
    return false;
  }

  /// ---------------------------
  /// Schedule classes API simulation
  /// ---------------------------
  static Future<List<Map<String, String>>> getScheduleClasses({
    required String accessToken,
  }) async {
    if (!await _isTokenValid(accessToken)) {
      throw Exception("Phiên đăng nhập hết hạn, vui lòng đăng nhập lại!");
    }
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      {
        "startTime": "07:00",
        "endTime": "08:30",
        "title": "LUYỆN THI TOEIC",
        "topic": "Buổi 5: Topic 5 Present Tenses",
        "teacher": "Name Teacher A",
        "room": "E303",
        "date": "2025-03-17",
      },
      {
        "startTime": "08:30",
        "endTime": "09:30",
        "title": "LUYỆN THI TOEIC",
        "topic": "Buổi 6: Topic 6 Future Tenses",
        "teacher": "Name Teacher A",
        "room": "E303",
        "date": "2025-03-18",
      },
      {
        "startTime": "09:30",
        "endTime": "10:30",
        "title": "LUYỆN THI IELTS",
        "topic": "Buổi 2: Writing Skills",
        "teacher": "Name Teacher B",
        "room": "E304",
        "date": "2025-03-18",
      },
      {
        "startTime": "07:00",
        "endTime": "08:30",
        "title": "LUYỆN THI TOEIC",
        "topic": "Buổi 1: Grammar Basics",
        "teacher": "Name Teacher A",
        "room": "E303",
        "date": "2025-04-05",
      },
      {
        "startTime": "08:30",
        "endTime": "09:30",
        "title": "LUYỆN THI IELTS",
        "topic": "Buổi 3: Listening",
        "teacher": "Name Teacher B",
        "room": "E304",
        "date": "2025-04-07",
      },
      // Additional classes for 13/03/2025
      {
        "startTime": "06:30",
        "endTime": "08:00",
        "title": "LUYỆN THI TOEIC",
        "topic": "Buổi 2: Vocabulary Building",
        "teacher": "Name Teacher C",
        "room": "E305",
        "date": "2025-03-13",
      },
      {
        "startTime": "08:15",
        "endTime": "09:45",
        "title": "LUYỆN THI IELTS",
        "topic": "Buổi 4: Reading Comprehension",
        "teacher": "Name Teacher D",
        "room": "E306",
        "date": "2025-03-13",
      },
      // Additional classes for 14/03/2025
      {
        "startTime": "07:30",
        "endTime": "09:00",
        "title": "LUYỆN THI TOEIC",
        "topic": "Buổi 3: Listening & Speaking",
        "teacher": "Name Teacher C",
        "room": "E305",
        "date": "2025-03-14",
      },
      {
        "startTime": "09:00",
        "endTime": "10:30",
        "title": "LUYỆN THI IELTS",
        "topic": "Buổi 5: Essay Writing",
        "teacher": "Name Teacher D",
        "room": "E306",
        "date": "2025-03-14",
      },
      // More sample classes for variety
      {
        "startTime": "10:45",
        "endTime": "12:15",
        "title": "LUYỆN THI TOEIC",
        "topic": "Buổi 7: Advanced Grammar",
        "teacher": "Name Teacher A",
        "room": "E303",
        "date": "2025-03-19",
      },
      {
        "startTime": "13:00",
        "endTime": "14:30",
        "title": "LUYỆN THI IELTS",
        "topic": "Buổi 6: Listening Practice",
        "teacher": "Name Teacher B",
        "room": "E304",
        "date": "2025-03-19",
      },
    ];
  }

  /// ---------------------------
  /// New: Simulated API call to get lesson data for bai_hoc.dart (requires valid accessToken).
  /// ---------------------------
  static Future<List<Map<String, String>>> getLessons({
    required String accessToken,
  }) async {
    if (!await _isTokenValid(accessToken)) {
      throw Exception("Phiên đăng nhập hết hạn, vui lòng đăng nhập lại!");
    }
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      {
        "lessonTitle": "Bài học 1: Giới thiệu",
        "description":
            "Giới thiệu về khóa học, nội dung và mục tiêu của bài học.",
        "duration": "30 phút",
        "date": "2025-03-10",
      },
      {
        "lessonTitle": "Bài học 2: Nội dung chính",
        "description": "Phân tích chi tiết các nội dung chính của bài học.",
        "duration": "45 phút",
        "date": "2025-03-11",
      },
      {
        "lessonTitle": "Bài học 3: Thực hành",
        "description": "Các bài tập thực hành nhằm củng cố kiến thức.",
        "duration": "40 phút",
        "date": "2025-03-12",
      },
      {
        "lessonTitle": "Bài học 4: Bài tập về nhà",
        "description": "Bài tập về nhà giúp học viên ôn tập kiến thức.",
        "duration": "20 phút",
        "date": "2025-03-13",
      },
      {
        "lessonTitle": "Bài học 5: Tổng kết",
        "description": "Ôn tập và tổng kết lại toàn bộ kiến thức của bài học.",
        "duration": "30 phút",
        "date": "2025-03-14",
      },
    ];
  }

  /// ---------------------------
  /// New: Simulated API call to get transaction data for hoc_phi.dart (requires valid accessToken).
  /// ---------------------------
  static Future<List<Map<String, String>>> getTransactions({
    required String accessToken,
  }) async {
    if (!await _isTokenValid(accessToken)) {
      throw Exception("Phiên đăng nhập hết hạn, vui lòng đăng nhập lại!");
    }
    await Future.delayed(const Duration(seconds: 1));
    return [
      {
        "id": "#16221550",
        "status": "Chưa thanh toán",
        "description": "Học phí chính Khóa tháng 03/2025",
        "amount": "3.500.000đ",
        "paymentDate": "",
      },
      {
        "id": "#16221551",
        "status": "Đã thanh toán",
        "description": "Học phí chính Khóa tháng 02/2025",
        "amount": "3.500.000đ",
        "paymentDate": "10/02/2025",
      },
      {
        "id": "#16221552",
        "status": "Đã thanh toán",
        "description": "Học phí chính Khóa tháng 01/2025",
        "amount": "3.500.000đ",
        "paymentDate": "15/01/2025",
      },
      {
        "id": "#16221553",
        "status": "Chưa thanh toán",
        "description": "Học phí phụ đạo tháng 03/2025",
        "amount": "1.200.000đ",
        "paymentDate": "",
      },
      {
        "id": "#16221554",
        "status": "Đã thanh toán",
        "description": "Học phí chính Khóa tháng 12/2024",
        "amount": "3.500.000đ",
        "paymentDate": "20/12/2024",
      },
      {
        "id": "#16221555",
        "status": "Chưa thanh toán",
        "description": "Học phí chính Khóa tháng 04/2025",
        "amount": "3.500.000đ",
        "paymentDate": "",
      },
    ];
  }

  /// ---------------------------
  /// New: Simulated API call to get notifications data (requires valid accessToken).
  /// ---------------------------
  static Future<List<Map<String, dynamic>>> getNotifications({
    required String accessToken,
  }) async {
    if (!await _isTokenValid(accessToken)) {
      throw Exception("Phiên đăng nhập hết hạn, vui lòng đăng nhập lại!");
    }
    await Future.delayed(const Duration(seconds: 1));
    return [
      {
        "title": "Welcome!",
        "message": "Thank you for joining our platform.",
        "dateTime": DateTime.now()
            .subtract(const Duration(minutes: 5))
            .toIso8601String(),
        "icon": "star",
        "iconColor": 0xFFFFC107,
      },
      {
        "title": "New Class Available",
        "message": "Check out our new TOEIC preparation class.",
        "dateTime": DateTime.now()
            .subtract(const Duration(hours: 1, minutes: 20))
            .toIso8601String(),
        "icon": "school",
        "iconColor": 0xFF2196F3,
      },
      {
        "title": "Payment Successful",
        "message": "Your tuition fee payment has been received.",
        "dateTime":
            DateTime.now().subtract(const Duration(hours: 3)).toIso8601String(),
        "icon": "payment",
        "iconColor": 0xFF4CAF50,
      },
      {
        "title": "Reminder",
        "message": "Don’t forget to complete your daily exercises.",
        "dateTime": DateTime.now()
            .subtract(const Duration(days: 1, hours: 2))
            .toIso8601String(),
        "icon": "alarm",
        "iconColor": 0xFFF44336,
      },
      {
        "title": "Event Update",
        "message": "Our upcoming event has been rescheduled. Check details.",
        "dateTime":
            DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
        "icon": "event",
        "iconColor": 0xFF9C27B0,
      },
      {
        "title": "Maintenance Notice",
        "message": "Our system will undergo maintenance at midnight.",
        "dateTime": DateTime.now()
            .subtract(const Duration(days: 3, hours: 4))
            .toIso8601String(),
        "icon": "build",
        "iconColor": 0xFF607D8B,
      },
      {
        "title": "Survey Invitation",
        "message": "Please participate in our quick survey for better service.",
        "dateTime": DateTime.now()
            .subtract(const Duration(days: 4, hours: 2))
            .toIso8601String(),
        "icon": "question_answer",
        "iconColor": 0xFF795548,
      },
    ];
  }

  /// Simulated API call to retrieve conversation history.
  static Future<List<Map<String, dynamic>>> getHistoryMessage() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      {
        "text": "Chào bạn! Tôi có thể giúp gì cho bạn?",
        "isUser": false,
        "timestamp": DateTime.now()
            .subtract(const Duration(minutes: 10))
            .toIso8601String(),
      },
      {
        "text": "Tôi cần trợ giúp về đơn hàng của tôi.",
        "isUser": true,
        "timestamp": DateTime.now()
            .subtract(const Duration(minutes: 8))
            .toIso8601String(),
      },
    ];
  }

  /// Simulated API call to clear conversation history.
  static Future<void> clearMessage() async {
    await Future.delayed(const Duration(milliseconds: 300));
  }

  /// Simulated API call for chatbot reply.
  static Future<String> getChatbotReply(String message) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return "Fake reply to: $message";
  }
}
