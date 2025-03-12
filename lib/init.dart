import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'welcome.dart';
import 'home.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    // Khởi tạo AnimationController cho hiệu ứng fade
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();

    Timer(const Duration(seconds: 1), () async {
      // Lấy accessToken từ local storage
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString('accessToken');

      // Nếu có accessToken thì chuyển sang HomePage, nếu không thì đến Welcome Page
      Widget nextPage;
      if (accessToken != null && accessToken.isNotEmpty) {
        nextPage = const HomePage();
      } else {
        nextPage = const Welcome();
      }

      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 700),
          pageBuilder: (context, animation, secondaryAnimation) {
            return nextPage;
          },
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
      );
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: const Color(0xFF1F3D85), // nền xanh
        alignment: Alignment.center,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Image.asset(
            'assets/images/sam_academy.png',
            width: 200,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
