import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  @override
  void initState() {
    super.initState();
    _loadTokenAndLessons();
  }

  Future<void> _loadTokenAndLessons() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    if (token == null) {
      // If no token, navigate to Welcome.
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

  Widget _buildLessonCard(Map<String, String> lesson) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        title: Text(
          lesson["lessonTitle"] ?? "",
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(lesson["description"] ?? ""),
            const SizedBox(height: 4),
            Text("Duration: ${lesson["duration"] ?? ""}"),
            const SizedBox(height: 4),
            Text("Date: ${lesson["date"] ?? ""}"),
          ],
        ),
        onTap: () {
          // Optionally, navigate to a detailed lesson page.
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingToken) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      // No bottomNavigationBar here – footer is provided globally in the main layout.
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: FutureBuilder<List<Map<String, String>>>(
              future: _lessonsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(child: Text("Error loading lessons"));
                } else if (snapshot.hasData) {
                  final lessons = snapshot.data!;
                  if (lessons.isEmpty) {
                    return const Center(child: Text("No lessons available"));
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.only(top: 16),
                    itemCount: lessons.length,
                    itemBuilder: (context, index) {
                      return _buildLessonCard(lessons[index]);
                    },
                  );
                }
                return const Center(child: Text("No data"));
              },
            ),
          ),
        ],
      ),
    );
  }
}
