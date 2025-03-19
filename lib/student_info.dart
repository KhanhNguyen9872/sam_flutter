import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'welcome.dart';
import 'settings.dart';
import 'api.dart';
import 'features/chatbot/chatbot_ai.dart';
import 'headers/header_main.dart';

class StudentInfoPage extends StatefulWidget {
  const StudentInfoPage({Key? key}) : super(key: key);

  @override
  State<StudentInfoPage> createState() => _StudentInfoPageState();
}

class _StudentInfoPageState extends State<StudentInfoPage> {
  bool _isLoggingOut = false;
  bool _isDarkMode = false;
  String _selectedLanguage = "English"; // Default language

  // Future to fetch student details.
  late Future<Map<String, dynamic>> _studentDataFuture;

  // Instance variable to store adjusted top padding.
  double _adjustedTopPadding = 12;

  // A simple language dictionary for labels.
  Map<String, String> get _labels {
    if (_selectedLanguage == "Tiếng Việt") {
      return {
        "title": "Thông tin học viên",
        "email": "Email",
        "fullName": "Họ và tên",
        "dob": "Ngày sinh",
        "phone": "Số điện thoại",
        "settings": "Cài đặt",
        "chatbot_ai": "Trợ lý AI",
        "logout": "Đăng xuất",
      };
    } else {
      return {
        "title": "Student Information",
        "email": "Email",
        "fullName": "Full Name",
        "dob": "Date of Birth",
        "phone": "Phone Number",
        "settings": "Settings",
        "chatbot_ai": "Support with AI",
        "logout": "Logout",
      };
    }
  }

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _studentDataFuture = _loadStudentData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Retrieve top padding from MediaQuery.
    final double topPadding = MediaQuery.of(context).padding.top;
    // If topPadding > 26, subtract 26; otherwise default to 12.
    setState(() {
      _adjustedTopPadding = topPadding > 26 ? topPadding - 26 : 12;
    });
  }

  // Load dark mode and language settings from SharedPreferences.
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool("isDarkMode") ?? false;
      _selectedLanguage = prefs.getString("selectedLanguage") ?? "English";
    });
  }

  /// Fetches the student's details using the access token.
  /// If no token exists, navigates to the Welcome screen.
  Future<Map<String, dynamic>> _loadStudentData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    if (token == null) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const Welcome()),
        (route) => false,
      );
      throw Exception("Access token không tồn tại");
    }
    try {
      return await Api.getStudentDetails(accessToken: token);
    } catch (e) {
      print("Error in _loadStudentData: $e");
      if (e.toString().contains("Phiên đăng nhập hết hạn")) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text("Phiên đăng nhập đã hết hạn, vui lòng đăng nhập lại!")),
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const Welcome()),
          (route) => false,
        );
      }
      rethrow;
    }
  }

  Future<void> _handleLogout() async {
    setState(() {
      _isLoggingOut = true;
    });
    await Future.delayed(const Duration(seconds: 2));
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('accessToken');
    setState(() {
      _isLoggingOut = false;
    });
    Navigator.pushAndRemoveUntil(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 700),
        pageBuilder: (context, animation, secondaryAnimation) =>
            const Welcome(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          final slideTween = Tween(begin: begin, end: end)
              .chain(CurveTween(curve: Curves.easeInOut));
          final fadeTween = Tween<double>(begin: 0.0, end: 1.0)
              .chain(CurveTween(curve: Curves.easeIn));
          return SlideTransition(
            position: animation.drive(slideTween),
            child: FadeTransition(
              opacity: animation.drive(fadeTween),
              child: child,
            ),
          );
        },
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = _isDarkMode ? Colors.grey[850] : Colors.white;
    final textColor = _isDarkMode ? Colors.white : Colors.black;
    final iconColor = _isDarkMode ? Colors.white70 : Colors.blueAccent;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const HeaderMain(userName: "Tai"),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Page title.
                  Text(
                    _labels["title"]!,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(color: textColor),
                  ),
                  const SizedBox(height: 16),
                  // FutureBuilder to load student data summary.
                  FutureBuilder<Map<String, dynamic>>(
                    future: _studentDataFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        print("Summary FutureBuilder error: ${snapshot.error}");
                        return Center(
                            child: Text(
                                "Error loading student data: ${snapshot.error}"));
                      } else if (snapshot.hasData) {
                        final student = snapshot.data!;
                        return Card(
                          color: _isDarkMode ? Colors.grey[800] : Colors.white,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundImage: const AssetImage(
                                  "assets/images/student_avatar.png"),
                              backgroundColor: _isDarkMode
                                  ? Colors.grey[700]
                                  : Colors.grey.shade300,
                            ),
                            title: Text(
                              (student["name"] ?? "").toString(),
                              style: TextStyle(
                                color: textColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              "MSHV: " +
                                  (student["studentId"]?.toString() ?? ""),
                              style:
                                  TextStyle(color: textColor.withOpacity(0.7)),
                            ),
                          ),
                        );
                      }
                      return const SizedBox();
                    },
                  ),
                  const SizedBox(height: 16),
                  // FutureBuilder to display detailed student information.
                  FutureBuilder<Map<String, dynamic>>(
                    future: _studentDataFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        print("Details FutureBuilder error: ${snapshot.error}");
                        return Center(
                            child: Text(
                                "Error loading student data: ${snapshot.error}"));
                      } else if (snapshot.hasData) {
                        final student = snapshot.data!;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.email, color: iconColor),
                                const SizedBox(width: 8),
                                Text(
                                  "${_labels["email"]}: ${(student["email"] ?? "").toString()}",
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(color: textColor),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.person, color: iconColor),
                                const SizedBox(width: 8),
                                Text(
                                  "${_labels["fullName"]}: ${(student["name"] ?? "").toString()}",
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(color: textColor),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.cake, color: iconColor),
                                const SizedBox(width: 8),
                                Text(
                                  "${_labels["dob"]}: ${(student["dob"] ?? "").toString()}",
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(color: textColor),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.phone, color: iconColor),
                                const SizedBox(width: 8),
                                Text(
                                  "${_labels["phone"]}: ${(student["phone"] ?? "").toString()}",
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(color: textColor),
                                ),
                              ],
                            ),
                          ],
                        );
                      }
                      return const SizedBox();
                    },
                  ),
                  const SizedBox(height: 32),
                  // Settings Button.
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2F3D85),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SettingsPage()),
                        );
                        _loadSettings();
                      },
                      icon: const Icon(Icons.settings, color: Colors.white),
                      label: Text(
                        _labels["settings"]!,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  // Chatbot Button.
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(80, 110, 59, 0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ChatbotPage()),
                        );
                        _loadSettings();
                      },
                      icon: const Icon(Icons.settings, color: Colors.white),
                      label: Text(
                        _labels["chatbot_ai"]!,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Logout Button.
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: _isLoggingOut ? null : _handleLogout,
                      icon: _isLoggingOut
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.logout, color: Colors.white),
                      label: Text(
                        _labels["logout"]!,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
