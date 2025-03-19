import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'headers/header_main.dart';
import 'api.dart';
import 'welcome.dart';

class BaiHocPage extends StatefulWidget {
  const BaiHocPage({Key? key}) : super(key: key);

  @override
  State<BaiHocPage> createState() => _BaiHocPageState();
}

class _BaiHocPageState extends State<BaiHocPage> {
  late Future<List<Map<String, String>>> _lessonsFuture;
  bool _isLoadingToken = true;
  String? _accessToken;

  // Biến lưu trữ khoảng padding trên đã điều chỉnh.
  double _adjustedTopPadding = 12;

  // Labels cho trang.
  final Map<String, String> _labels = {"title": "Bài Học"};
  final Color textColor = Colors.black;

  @override
  void initState() {
    super.initState();
    _loadTokenAndLessons();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Lấy padding trên từ MediaQuery.
    final double topPadding = MediaQuery.of(context).padding.top;
    setState(() {
      _adjustedTopPadding = topPadding > 26 ? topPadding - 26 : 12;
    });
  }

  Future<void> _loadTokenAndLessons() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    if (token == null) {
      // Nếu không có token, chuyển hướng về trang Welcome.
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const Welcome()),
        (route) => false,
      );
      return;
    } else {
      setState(() {
        _accessToken = token;
        _lessonsFuture = Api.getLessons(accessToken: token);
        _isLoadingToken = false;
      });
    }
  }

  Widget _buildLessonCard(Map<String, String> lesson) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          // Tùy chọn: Điều hướng đến trang chi tiết bài học.
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [Colors.white, Colors.grey.shade100],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                lesson["lessonTitle"] ?? "",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                lesson["description"] ?? "",
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.access_time, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    "Thời lượng: ${lesson["duration"] ?? ""}",
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Icon(Icons.date_range, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    "Ngày: ${lesson["date"] ?? ""}",
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _refreshLessons() async {
    if (_accessToken != null) {
      setState(() {
        _lessonsFuture = Api.getLessons(accessToken: _accessToken!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingToken) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      body: Column(
        children: [
          // HeaderMain hiển thị phần đầu trang.
          const HeaderMain(),
          // Tiêu đề trang.
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                _labels["title"]!,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(color: textColor),
                textAlign: TextAlign.left,
              ),
            ),
          ),

          Expanded(
            child: FutureBuilder<List<Map<String, String>>>(
              future: _lessonsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(
                      child: Text("Có lỗi xảy ra khi tải bài học"));
                } else if (snapshot.hasData) {
                  final lessons = snapshot.data!;
                  if (lessons.isEmpty) {
                    return const Center(child: Text("Không có bài học nào"));
                  }
                  return RefreshIndicator(
                    onRefresh: _refreshLessons,
                    child: ListView.builder(
                      padding: const EdgeInsets.only(top: 16, bottom: 16),
                      itemCount: lessons.length,
                      itemBuilder: (context, index) {
                        return _buildLessonCard(lessons[index]);
                      },
                    ),
                  );
                }
                return const Center(child: Text("Không có dữ liệu"));
              },
            ),
          ),
        ],
      ),
    );
  }
}
