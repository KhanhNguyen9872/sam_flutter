import 'package:flutter/material.dart';
import '../notifications.dart';
import '../welcome.dart';
import '../api.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HeaderChild extends StatelessWidget {
  final String title;
  final VoidCallback? onBack;
  final List<Widget>? actions;

  const HeaderChild({
    Key? key,
    required this.title,
    this.onBack,
    this.actions,
  }) : super(key: key);

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
    return Container(
      color: const Color(0xFF2F3D85),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack ?? () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          if (actions != null) ...actions!,
          FutureBuilder<bool>(
            future: _checkNotification(),
            builder: (context, snapshot) {
              if (snapshot.hasError &&
                  snapshot.error
                      .toString()
                      .contains("Phiên đăng nhập hết hạn")) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const Welcome()),
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
        ],
      ),
    );
  }
}
