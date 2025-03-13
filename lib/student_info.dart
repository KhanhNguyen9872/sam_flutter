import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'welcome.dart';
import 'settings.dart';
import 'api.dart';
import 'chatbot_ai.dart';

class StudentInfoPage extends StatefulWidget {
  const StudentInfoPage({Key? key}) : super(key: key);

  @override
  State<StudentInfoPage> createState() => _StudentInfoPageState();
}

class _StudentInfoPageState extends State<StudentInfoPage> {
  bool _isLoggingOut = false;
  bool _isDarkMode = false;
  String _selectedLanguage = "English"; // Default language

  // Future lấy thông tin học viên từ API giả
  late Future<Map<String, String>> _studentDataFuture;

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
        "chatbot_ai": "Hổ trợ với AI",
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

  // Load dark mode và ngôn ngữ từ SharedPreferences.
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool("isDarkMode") ?? false;
      _selectedLanguage = prefs.getString("selectedLanguage") ?? "English";
    });
  }

  /// Lấy accessToken từ local.
  /// Nếu không có, chuyển hướng về trang Welcome.
  /// Nếu có, gọi API lấy thông tin học viên bằng accessToken đó.
  Future<Map<String, String>> _loadStudentData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    if (token == null) {
      // Nếu không có token, chuyển hướng về Welcome.
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

  Widget _buildHeader() {
    return SafeArea(
      bottom: false,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top - 26,
          left: 16,
          right: 16,
          bottom: 12,
        ),
        decoration: const BoxDecoration(
          color: Color(0xFF2F3D85),
        ),
        child: Column(
          children: [
            // Stack with logo, greeting, and notification icon.
            Stack(
              children: [
                Center(
                  child: Image.asset(
                    "assets/images/sam_edtech.png",
                    width: 70,
                    fit: BoxFit.contain,
                  ),
                ),
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "Hey Tai,",
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                      SizedBox(height: 2),
                      Text(
                        "Welcome back",
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: IconButton(
                    onPressed: () {
                      // TODO: open notification screen.
                    },
                    icon: Image.asset(
                      "assets/images/notification.png",
                      width: 20,
                      height: 20,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
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
            _buildHeader(),
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
                  // FutureBuilder lấy dữ liệu học viên.
                  FutureBuilder<Map<String, String>>(
                    future: _studentDataFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return const Center(
                            child: Text("Error loading student data"));
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
                              student["name"] ?? "",
                              style: TextStyle(
                                color: textColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              student["studentId"] ?? "",
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
                  // Hiển thị thông tin chi tiết của học viên.
                  FutureBuilder<Map<String, String>>(
                    future: _studentDataFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return const Center(
                            child: Text("Error loading student data"));
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
                                  "${_labels["email"]}: ${student["email"] ?? "student@example.com"}",
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
                                  "${_labels["fullName"]}: ${student["name"] ?? "TRƯỜNG VĂN TÀI"}",
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
                                  "${_labels["dob"]}: ${student["dob"] ?? "01/01/2000"}",
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
                                  "${_labels["phone"]}: ${student["phone"] ?? "0123456789"}",
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
                  // Button Settings.
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
                  // Button Settings.
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
                  // Button Logout.
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
