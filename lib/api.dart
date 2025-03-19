import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // Import intl package
import './models/quiz.dart';

class Api {
  static const String _apiUrl = "http://127.0.0.1:3000/api/v1";

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
        'first_name': data['first_name'] ?? '',
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

  /// API call to get timetable data (requires valid accessToken).
  static Future<List<Map<String, String>>> getTimetable({
    required String accessToken,
  }) async {
    if (!await _isTokenValid(accessToken)) {
      throw Exception("Phiên đăng nhập hết hạn, vui lòng đăng nhập lại!");
    }

    final response = await http.get(
      Uri.parse('$_apiUrl/timetables'),
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);

      return data.map((item) {
        return {
          'title': item['title']?.toString() ?? '',
          'session': item['topic']?.toString() ?? '',
          'time_start': item['time_start']?.toString() ?? '',
          'time_stop': item['time_stop']?.toString() ?? '',
          'timeRange': (item['time_start']?.toString() ?? '') +
              ' - ' +
              (item['time_stop']?.toString() ?? ''),
          'date': item['date']?.toString() ?? '',
          'teacher': item['teacher']?.toString() ?? '',
          'room': item['room']?.toString() ?? '',
          'class': item['class']?.toString() ?? '',
          'status': item['status']?.toString() ?? '',
        };
      }).toList();
    } else {
      throw Exception("Không thể lấy thông tin lịch học. Vui lòng thử lại!");
    }
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

  static Future<List<Map<String, String>>> getScheduleClasses({
    required String accessToken,
  }) async {
    if (!await _isTokenValid(accessToken)) {
      throw Exception("Phiên đăng nhập hết hạn, vui lòng đăng nhập lại!");
    }

    final response = await http.get(
      Uri.parse('$_apiUrl/timetables'),
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);

      return data.map((item) {
        // Date Conversion: Parse and Format
        String formattedDate = '';
        try {
          final DateFormat inputFormat = DateFormat('dd/MM/yyyy');
          final DateTime parsedDate =
              inputFormat.parse(item['date']?.toString() ?? '');
          formattedDate = DateFormat('yyyy-MM-dd').format(parsedDate);
        } catch (e) {
          // Handle parsing errors, e.g., if 'date' is null or invalid
          try {
            //If dd/MM/yyyy fails, attempt parsing with yyyy-MM-dd
            final DateTime parsedDate =
                DateTime.parse(item['date']?.toString() ?? '');
            formattedDate = DateFormat('yyyy-MM-dd').format(parsedDate);
          } catch (e) {
            // Handle parsing errors, e.g., if 'date' is null or invalid
            formattedDate = ''; // Or some default value, or log the error
            print("Date parsing error: $e");
          }
        }

        return {
          'startTime': item['time_start']?.toString() ?? '',
          'endTime': item['time_stop']?.toString() ?? '',
          'title': item['title']?.toString() ?? '',
          'topic': item['topic']?.toString() ?? '',
          'teacher': item['teacher']?.toString() ?? '',
          'room': item['room']?.toString() ?? '',
          'date': formattedDate, // Use the formatted date
        };
      }).toList();
    } else {
      print('getScheduleClasses response status: ${response.statusCode}');
      print('getScheduleClasses response body: ${response.body}');
      throw Exception(
          "Không thể lấy thông tin lịch học. Vui lòng thử lại! Status code: ${response.statusCode}");
    }
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

  // Fake implementation of getAcademicResults
  static Future<List<dynamic>> getAcademicResults(
      {required String accessToken}) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    // Check token validity
    if (accessToken.isEmpty || accessToken == 'expired_token') {
      throw Exception('Phiên đăng nhập hết hạn');
    }

    // Generate fake academic results
    final List<Map<String, dynamic>> fakeResults = [
      {
        'subject': 'Mathematics',
        'score': 85.5,
        'semester': 'Fall 2023',
      },
      {
        'subject': 'Physics',
        'score': 78.0,
        'semester': 'Fall 2023',
      },
      {
        'subject': 'Chemistry',
        'score': 92.0,
        'semester': 'Fall 2023',
      },
      {
        'subject': 'History',
        'score': 65.5,
        'semester': 'Spring 2023',
      },
      {
        'subject': 'Literature',
        'score': 88.0,
        'semester': 'Spring 2023',
      },
      {
        'subject': 'Computer Science',
        'score': 95.0,
        'semester': 'Fall 2024',
      },
      {
        'subject': 'Biology',
        'score': 73.5,
        'semester': 'Fall 2024',
      },
    ];

    // Shuffle the list to simulate dynamic data
    fakeResults.shuffle(Random());

    // Return a random subset of results (3 to 7 items) for variety
    final int resultCount = 3 + Random().nextInt(5); // Between 3 and 7
    return fakeResults.take(resultCount).toList();
  }

  static Future<List<Quiz>> getDefaultQuizzes(
      {required String accessToken}) async {
    await Future.delayed(const Duration(seconds: 1));
    if (accessToken.isEmpty || accessToken == 'expired_token') {
      throw Exception('Phiên đăng nhập hết hạn');
    }

    final List<Quiz> fakeQuizzes = [
      Quiz(
        id: 'default1',
        title: 'General Knowledge',
        description: 'A quiz on general knowledge',
        isDefault: true,
        questions: [
          Question(
            question: 'What is the capital of France?',
            imageUrl: null,
            options: ['Berlin', 'London', 'Paris', 'Rome'],
            correctIndex: 2,
          ),
          Question(
            question: 'Which planet is known as the Red Planet?',
            imageUrl: null,
            options: ['Earth', 'Mars', 'Jupiter', 'Saturn'],
            correctIndex: 1,
          ),
        ],
      ),
      Quiz(
        id: 'default2',
        title: 'Science Quiz',
        description: 'Test your science knowledge',
        isDefault: true,
        questions: [
          Question(
            question: 'Who developed the theory of relativity?',
            imageUrl: null,
            options: ['Newton', 'Einstein', 'Galileo', 'Tesla'],
            correctIndex: 1,
          ),
          Question(
            question: 'What is the chemical symbol for water?',
            imageUrl: null,
            options: ['H2O', 'CO2', 'NaCl', 'O2'],
            correctIndex: 0,
          ),
        ],
      ),
      Quiz(
        id: 'default3',
        title: 'History Trivia',
        description: 'Explore historical facts',
        isDefault: true,
        questions: [
          Question(
            question: 'Who was the first President of the United States?',
            imageUrl: null,
            options: ['Lincoln', 'Washington', 'Jefferson', 'Adams'],
            correctIndex: 1,
          ),
          Question(
            question: 'In which year did World War II end?',
            imageUrl: null,
            options: ['1945', '1918', '1939', '1941'],
            correctIndex: 0,
          ),
        ],
      ),
    ];

    fakeQuizzes.shuffle(Random());
    final int quizCount = 1 + Random().nextInt(3);
    return fakeQuizzes.take(quizCount).toList();
  }
}
