import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class Api {
  /// Lưu accessToken và thời hạn của nó vào SharedPreferences
  static Future<void> _saveToken(String token, DateTime expiry) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('accessToken', token);
    await prefs.setString('expiresAt', expiry.toIso8601String());
  }

  /// Lấy accessToken từ SharedPreferences
  static Future<String?> _getLocalToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('accessToken');
  }

  /// Lấy thời hạn token từ SharedPreferences
  static Future<DateTime?> _getLocalTokenExpiry() async {
    final prefs = await SharedPreferences.getInstance();
    final expiryStr = prefs.getString('expiresAt');
    if (expiryStr != null) {
      return DateTime.parse(expiryStr);
    }
    return null;
  }

  /// Kiểm tra xem token hiện tại có hợp lệ không dựa vào dữ liệu lưu trong SharedPreferences
  static Future<bool> _isTokenValid(String accessToken) async {
    final localToken = await _getLocalToken();
    final expiry = await _getLocalTokenExpiry();
    if (localToken == null || expiry == null) return false;
    return (localToken == accessToken && DateTime.now().isBefore(expiry));
  }

  /// Giả lập API đăng nhập, không cần token
  /// Nếu đăng nhập thành công, lưu accessToken và thiết lập thời hạn 5 phút vào local
  static Future<String?> login(String email, String password) async {
    // Giả lập độ trễ của mạng (2 giây)
    await Future.delayed(const Duration(seconds: 2));
    if (email == "test@example.com" && password == "password") {
      final now = DateTime.now();
      // Token có hiệu lực trong 5 phút kể từ thời điểm đăng nhập
      final expiry = now.add(const Duration(minutes: 5));
      final token = "dummy_access_token";
      await _saveToken(token, expiry);
      return token;
    }
    return null;
  }

  /// Lấy danh sách các lớp học cho trang chủ (yêu cầu accessToken)
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

  /// Lấy thông tin học viên cho trang Home (yêu cầu accessToken)
  static Future<Map<String, String>> getStudentInfo({
    required String accessToken,
  }) async {
    if (!await _isTokenValid(accessToken)) {
      throw Exception("Phiên đăng nhập hết hạn, vui lòng đăng nhập lại!");
    }
    await Future.delayed(const Duration(milliseconds: 500));
    return {
      "name": "TRƯỜNG VĂN TÀI",
      "studentId": "MSHV: G16-001",
    };
  }

  /// Lấy chi tiết thông tin học viên cho trang StudentInfoPage (yêu cầu accessToken)
  static Future<Map<String, String>> getStudentDetails({
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

  /// Hàm giả kiểm tra có thông báo mới hay không (yêu cầu accessToken)
  static Future<bool> hasNotification({
    required String accessToken,
  }) async {
    if (!await _isTokenValid(accessToken)) {
      throw Exception("Phiên đăng nhập hết hạn, vui lòng đăng nhập lại!");
    }
    await Future.delayed(const Duration(milliseconds: 500));
    return false;
  }
}
