import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math' as math;
import 'footer_menu.dart';
import 'student_info.dart';
import 'api.dart';
import 'welcome.dart'; // Assumes Welcome screen exists
import 'features/thoi_khoa_bieu.dart';
import 'features/ma_qr.dart';
import 'features/xem_them.dart';
import 'features/hoc_phi.dart';
import 'features/danh_sach.dart';
import 'features/ket_qua_hoc_tap.dart';
import 'bai_hoc.dart';
import 'notifications.dart';

// Sample new screen to display feature details.
class FeatureDetailScreen extends StatelessWidget {
  final String title;

  const FeatureDetailScreen({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: const Color(0xFF2F3D85),
      ),
      body: Center(
        child: Text(
          "Details for $title",
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  // Futures for API calls (which require an accessToken)
  late Future<List<Map<String, String>>> _featuresFuture;
  late Future<List<Map<String, String>>> _classesFuture;
  late Future<Map<String, String>> _studentInfoFuture;
  late Future<bool> _hasNotificationFuture;

  // List of pages (widgets)
  final List<Widget> _pages = [];

  // Access token retrieved from SharedPreferences
  String? _accessToken;
  bool _isLoadingToken = true;

  // Instance variable for adjusted top padding.
  double _adjustedTopPadding = 12;

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final double topPadding = MediaQuery.of(context).padding.top;
    setState(() {
      _adjustedTopPadding = topPadding > 26 ? topPadding - 26 : 12;
    });
  }

  /// Helper: Remove token from local storage, display error message, and navigate to Welcome screen.
  Future<void> _handleTokenExpiry() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('accessToken');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text("Phiên đăng nhập đã hết hạn, vui lòng đăng nhập lại!")),
    );
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const Welcome()),
      (route) => false,
    );
  }

  /// Load the accessToken from local storage. If not found, navigate to Welcome.
  /// If found, initialize API calls with that token.
  Future<void> _loadToken() async {
    setState(() {
      _featuresFuture = Future.value([
        {
          "title": "Thời khóa biểu",
          "image": "assets/images/thoi_khoa_bieu.png",
        },
        {
          "title": "Sổ liên lạc",
          "image": "assets/images/so_lien_lac.png",
        },
        {
          "title": "Kết quả học tập",
          "image": "assets/images/ket_qua_hoc_tap.png",
        },
        {
          "title": "Danh sách",
          "image": "assets/images/danh_sach.png",
        },
        {
          "title": "Học phí",
          "image": "assets/images/hoc_phi.png",
        },
        {
          "title": "Mã QR",
          "image": "assets/images/ma_qr.png",
        },
        {
          "title": "Thư viện ảnh",
          "image": "assets/images/thu_vien_anh.png",
        },
        {
          "title": "Xem thêm",
          "image": "assets/images/xem_them.png",
        },
      ]);
    });

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    if (token == null) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const Welcome()),
        (route) => false,
      );
    } else {
      setState(() {
        _accessToken = token;
        _classesFuture = Api.getTimetable(accessToken: token);
        _studentInfoFuture = Api.getStudentDetails(accessToken: token);
        _hasNotificationFuture = Api.hasNotification(accessToken: token);
        _pages.add(_buildHomeContent());
        _pages.add(const BaiHocPage());
        _pages.add(const StudentInfoPage());
        _isLoadingToken = false;
      });
    }
  }

  /// Helper function to remove diacritics (accent marks) from a string.
  String _removeDiacritics(String input) {
    const withDia =
        "ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖØÙÚÛÜÝŸàáâãäåæçèéêëìíîïðñòóôõöøùúûüýÿ";
    const withoutDia =
        "AAAAAAACEEEEIIIIDNOOOOOOUUUUYYaAAAAAAACEEEEIIIIDNOOOOOOUUUUYy";
    for (int i = 0; i < withDia.length; i++) {
      input = input.replaceAll(withDia[i], withoutDia[i]);
    }
    return input;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingToken) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: FooterMenu(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }

  // Home content that uses FutureBuilders to fetch API data.
  Widget _buildHomeContent() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildHeader(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Tính năng nổi bật",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
            ),
          ),
          _buildFeatureGrid(),
          _buildWeekTitle(),
          _buildClassList(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: _adjustedTopPadding,
        left: 16,
        right: 16,
        bottom: 12,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF2F3D85),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Stack with logo, dynamic greeting, and notification icon.
          Stack(
            children: [
              Center(
                child: Image.asset(
                  "assets/images/sam_edtech.png",
                  width: 70,
                  fit: BoxFit.contain,
                ),
              ),
              // Dynamic greeting using student's first_name converted to ASCII.
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: FutureBuilder<Map<String, String>>(
                  future: _studentInfoFuture,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final student = snapshot.data!;
                      String firstName = student["first_name"] ?? "User";
                      String asciiName = _removeDiacritics(firstName);
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Hey $asciiName,",
                            style: const TextStyle(
                                color: Colors.white, fontSize: 14),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            "Welcome back",
                            style:
                                TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      );
                    } else {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            "Hey,",
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                          SizedBox(height: 2),
                          Text(
                            "Welcome back",
                            style:
                                TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      );
                    }
                  },
                ),
              ),
              // Notification icon.
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                child: FutureBuilder<bool>(
                  future: _hasNotificationFuture,
                  builder: (context, snapshot) {
                    if (snapshot.hasError &&
                        snapshot.error
                            .toString()
                            .contains("Phiên đăng nhập hết hạn")) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _handleTokenExpiry();
                      });
                      return Container();
                    }
                    bool hasNotification = snapshot.data ?? false;
                    return IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const NotificationPage()),
                        );
                      },
                      icon: Image.asset(
                        hasNotification
                            ? "assets/images/have_notification.png"
                            : "assets/images/notification.png",
                        width: 20,
                        height: 20,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Student info card.
          FutureBuilder<Map<String, String>>(
            future: _studentInfoFuture,
            builder: (context, snapshot) {
              if (snapshot.hasError &&
                  snapshot.error
                      .toString()
                      .contains("Phiên đăng nhập hết hạn")) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _handleTokenExpiry();
                });
                return Container();
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasData) {
                final student = snapshot.data!;
                return InkWell(
                  onTap: () {
                    // Navigate to student info page if needed.
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.grey.shade300,
                          child: Icon(
                            Icons.person,
                            size: 24,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              student["name"] ?? "",
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "MSHV: " +
                                  (student["studentId"]?.toString() ?? ""),
                              style: const TextStyle(
                                color: Colors.black54,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              } else {
                return const CircularProgressIndicator();
              }
            },
          ),
        ],
      ),
    );
  }

  // Grid of features with navigation.
  Widget _buildFeatureGrid() {
    return FutureBuilder<List<Map<String, String>>>(
      future: _featuresFuture,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final features = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: features.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisExtent: 80,
                  ),
                  itemBuilder: (context, index) {
                    final item = features[index];
                    return InkWell(
                      onTap: () {
                        final title = item["title"]!;
                        if (title == "Thời khóa biểu") {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const ThoiKhoaBieuScreen()),
                          );
                        } else if (title == "Học phí") {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const TransactionPage()),
                          );
                        } else if (title == "Mã QR") {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const MaQRScreen()),
                          );
                        } else if (title == "Danh sách") {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const DanhSach()),
                          );
                        } else if (title == "Kết quả học tập") {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const KetQuaHocTap()),
                          );
                        } else if (title == "Xem thêm") {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const XemThemScreen()),
                          );
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  FeatureDetailScreen(title: title),
                            ),
                          );
                        }
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 40,
                            height: 40,
                            child: Image.asset(
                              item["image"]!,
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            item["title"]!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade800,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        } else if (snapshot.hasError) {
          return const Center(child: Text("Error loading features"));
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  // Week title widget.
  Widget _buildWeekTitle() {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final sunday = now.add(Duration(days: 7 - now.weekday));

    String formatDate(DateTime date) {
      return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}";
    }

    final weekRange = "${formatDate(monday)} - ${formatDate(sunday)}";

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Text(
            "Các buổi trong tuần",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const Spacer(),
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: 1),
            duration: const Duration(seconds: 1),
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: child,
              );
            },
            child: Text(
              weekRange,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Class list widget using API data.
  Widget _buildClassList() {
    return FutureBuilder<List<Map<String, String>>>(
      future: _classesFuture,
      builder: (context, snapshot) {
        if (snapshot.hasError &&
            snapshot.error.toString().contains("Phiên đăng nhập hết hạn")) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _handleTokenExpiry();
          });
          return Container();
        }
        if (snapshot.hasData) {
          final classes = snapshot.data!;
          return ListView.builder(
            itemCount: classes.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final item = classes[index];
              final status = item["status"] ?? "";
              final Color statusColor =
                  status == "Đang diễn ra" ? Colors.green : Colors.orange;

              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 1.5,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item["title"] ?? "",
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item["session"] ?? "",
                          style: const TextStyle(
                            color: Colors.orange,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.access_time,
                                size: 16, color: Colors.grey.shade600),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                item["timeRange"] ?? "",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.date_range,
                                size: 16, color: Colors.grey.shade600),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                item["date"] ?? "",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.person_outline,
                                size: 16, color: Colors.grey.shade600),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                item["teacher"] ?? "",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.meeting_room,
                                size: 16, color: Colors.grey.shade600),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                item["room"] ?? "",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              status,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        } else if (snapshot.hasError) {
          return const Center(child: Text("Error loading classes"));
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
