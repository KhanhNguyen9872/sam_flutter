import 'package:flutter/material.dart';
import '../notifications.dart';
import '../welcome.dart';
import '../api.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HeaderMain extends StatefulWidget {
  final String subtitle;

  const HeaderMain({
    Key? key,
    this.subtitle = "Welcome back",
  }) : super(key: key);

  @override
  State<HeaderMain> createState() => _HeaderMainState();
}

class _HeaderMainState extends State<HeaderMain> {
  String? firstName;

  @override
  void initState() {
    super.initState();
    _fetchUserName();
  }

  Future<void> _fetchUserName() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken');
      if (token == null) {
        throw Exception("Phiên đăng nhập hết hạn");
      }
      final userDetails = await Api.getStudentDetails(accessToken: token);
      setState(() {
        firstName = userDetails["first_name"] ?? "User";
      });
    } catch (e) {
      setState(() {
        firstName = "User";
      });
    }
  }

  Future<bool> _checkNotification() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    if (token == null) {
      throw Exception("Phiên đăng nhập hết hạn");
    }
    return Api.hasNotification(accessToken: token);
  }

  @override
  Widget build(BuildContext context) {
    final double topPadding = MediaQuery.of(context).padding.top;
    final double adjustedTopPadding = topPadding > 26 ? topPadding - 26 : 12;

    return SafeArea(
      bottom: false,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.only(
          top: adjustedTopPadding,
          left: 16,
          right: 16,
          bottom: 12,
        ),
        decoration: const BoxDecoration(
          color: Color(0xFF2F3D85),
        ),
        child: Stack(
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
                children: [
                  Text(
                    "Hey ${firstName ?? "..."},",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.subtitle,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: FutureBuilder<bool>(
                future: _checkNotification(),
                builder: (context, snapshot) {
                  if (snapshot.hasError &&
                      snapshot.error
                          .toString()
                          .contains("Phiên đăng nhập hết hạn")) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const Welcome()),
                        (route) => false,
                      );
                    });
                    return Container();
                  }
                  bool hasNotification = snapshot.data ?? false;
                  return IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NotificationPage(),
                        ),
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
      ),
    );
  }
}
