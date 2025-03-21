import 'package:flutter/material.dart';
import 'login.dart'; // Import file login.dart

class Welcome extends StatelessWidget {
  const Welcome({Key? key}) : super(key: key);

  // Helper method to create animated route
  Route _createRoute(Widget page) {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 700),
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0); // Start from right
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Nền trắng
          Container(color: Colors.white),
          // Đám mây xanh đậm ở dưới
          Positioned(
            bottom: 0,
            child: ClipPath(
              clipper: DarkCloudClipper(),
              child: Container(
                width: size.width,
                height: size.height * 0.5,
                color: const Color(0xFF2F3D85),
              ),
            ),
          ),
          // Đám mây xanh nhạt phủ lên
          Positioned(
            bottom: 0,
            child: ClipPath(
              clipper: LightCloudClipper(),
              child: Container(
                width: size.width,
                height: size.height * 0.45,
                color: const Color(0xFF8AB4F8),
              ),
            ),
          ),
          // Nội dung (HELLO !!, logo, nút)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Transform.rotate(
                    angle: -0.1,
                    child: const Text(
                      'HELLO !!',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Center(
                    child: Column(
                      children: [
                        Image.asset(
                          "assets/images/sam_academy.png",
                          width: 180,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                  const Spacer(),
                  // Nút SIGN IN with animation
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2F3D85),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          _createRoute(const LoginPage()),
                        );
                      },
                      child: const Text(
                        'SIGN IN',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Nút SIGN UP with animation
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        side: const BorderSide(
                          color: Color(0xFF2F3D85),
                          width: 2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: () {
                        // Navigator.push(
                        //   context,
                        // _createRoute(const SignUpPage()),
                        // );
                      },
                      child: const Text(
                        'SIGN UP',
                        style: TextStyle(
                          color: Color(0xFF2F3D85),
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

//------------- ClipPath: DarkCloudClipper, LightCloudClipper ------------//
class DarkCloudClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, size.height * 0.3);
    path.quadraticBezierTo(
      size.width * 0.2,
      size.height * 0.45,
      size.width * 0.4,
      size.height * 0.3,
    );
    path.quadraticBezierTo(
      size.width * 0.6,
      size.height * 0.15,
      size.width * 0.8,
      size.height * 0.3,
    );
    path.quadraticBezierTo(
      size.width * 0.9,
      size.height * 0.38,
      size.width,
      size.height * 0.3,
    );
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(DarkCloudClipper oldClipper) => false;
}

class LightCloudClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, size.height * 0.25);
    path.quadraticBezierTo(
      size.width * 0.2,
      size.height * 0.40,
      size.width * 0.4,
      size.height * 0.25,
    );
    path.quadraticBezierTo(
      size.width * 0.6,
      size.height * 0.10,
      size.width * 0.8,
      size.height * 0.25,
    );
    path.quadraticBezierTo(
      size.width * 0.9,
      size.height * 0.33,
      size.width,
      size.height * 0.25,
    );
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(LightCloudClipper oldClipper) => false;
}
