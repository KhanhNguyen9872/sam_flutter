import 'package:flutter/material.dart';
import 'home.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Controllers cho các TextField
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Hàm kiểm tra định dạng email hợp lệ
  bool _isValidEmail(String email) {
    return RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$")
        .hasMatch(email);
  }

  // Giả lập API call để lấy accessToken (thay thế bằng API thực tế)
  Future<String?> _simulateApiCall(String email, String password) async {
    // Giả lập độ trễ mạng
    await Future.delayed(const Duration(seconds: 2));
    // Ví dụ: nếu email là test@example.com và password là password thì trả về token
    if (email == "test@example.com" && password == "password") {
      return "dummy_access_token";
    }
    return "";
  }

  // Hàm xử lý đăng nhập: kiểm tra định dạng và gọi API
  void _handleSignIn() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    // Kiểm tra định dạng email và mật khẩu không rỗng
    if (!_isValidEmail(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid email format")),
      );
      return;
    }
    if (password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password cannot be empty")),
      );
      return;
    }

    // Gọi API để lấy accessToken
    // final accessToken = await _simulateApiCall(email, password);
    final accessToken = '1234567890';

    if (accessToken != null && accessToken.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Welcome!")),
      );
      // Sau khi hiển thị thông báo, chuyển đến trang Home
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Login failed, please check your credentials")),
      );
    }
  }

  void _handleForgotPassword() {
    debugPrint("Forgot Password pressed");
  }

  void _handleFacebookSignIn() {
    debugPrint("Facebook Sign In");
  }

  void _handleZaloSignIn() {
    debugPrint("Zalo Sign In");
  }

  void _handleSignUp() {
    debugPrint("Sign Up pressed");
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final verticalPadding = MediaQuery.of(context).padding.vertical;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    // Với padding ngang là 24 cho mỗi bên, chiều rộng của TextField là: size.width - 48
    // Nếu ở chế độ landscape, nút SIGN IN sẽ có chiều rộng bằng 1/2 tổng chiều rộng đó.
    final loginButtonWidth =
        isLandscape ? (size.width - 48) / 2 : double.infinity;

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
                height: size.height * 0.3,
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
                height: size.height * 0.25,
                color: const Color(0xFF8AB4F8),
              ),
            ),
          ),

          // Nội dung đăng nhập được căn giữa theo chiều dọc
          SafeArea(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: size.height - verticalPadding,
                ),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Logo
                        Center(
                          child: Image.asset(
                            'assets/images/sam_academy.png',
                            width: 150,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 32),

                        // TextField Email với padding left/right lớn hơn
                        TextField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            hintText: 'Email',
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 16),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: const BorderSide(color: Colors.grey),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // TextField Password với padding left/right lớn hơn
                        TextField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            hintText: 'Password',
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 16),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: const BorderSide(color: Colors.grey),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Nút SIGN IN với chữ màu trắng
                        SizedBox(
                          width: loginButtonWidth,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2F3D85),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            onPressed: _handleSignIn,
                            child: const Text(
                              'SIGN IN',
                              style:
                                  TextStyle(fontSize: 18, color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Forgot Password
                        GestureDetector(
                          onTap: _handleForgotPassword,
                          child: Text(
                            'Forgot Password?',
                            style: TextStyle(
                              color: Colors.blueGrey.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Social Sign In buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Facebook
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4267B2),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              onPressed: _handleFacebookSignIn,
                              icon: const Icon(Icons.facebook),
                              label: const Text(
                                'Sign In',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.white),
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Zalo: sử dụng image thay cho icon
                            ElevatedButton.icon(
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
                              onPressed: _handleZaloSignIn,
                              icon: Image.asset(
                                'assets/images/zalo.png',
                                width: 24,
                                height: 24,
                              ),
                              label: const Text(
                                'Zalo',
                                style: TextStyle(
                                    fontSize: 16, color: Color(0xFF2F3D85)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Sign Up
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Don't have an account? ",
                              style: TextStyle(color: Colors.grey.shade700),
                            ),
                            GestureDetector(
                              onTap: _handleSignUp,
                              child: const Text(
                                'Sign Up',
                                style: TextStyle(
                                    color: Color(0xFF2F3D85),
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

//------------------ ClipPath: DarkCloudClipper, LightCloudClipper ------------------//
class DarkCloudClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, size.height * 0.4);
    path.quadraticBezierTo(
      size.width * 0.2,
      size.height * 0.55,
      size.width * 0.4,
      size.height * 0.4,
    );
    path.quadraticBezierTo(
      size.width * 0.6,
      size.height * 0.25,
      size.width * 0.8,
      size.height * 0.4,
    );
    path.quadraticBezierTo(
      size.width * 0.9,
      size.height * 0.48,
      size.width,
      size.height * 0.4,
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
    path.moveTo(0, size.height * 0.35);
    path.quadraticBezierTo(
      size.width * 0.2,
      size.height * 0.50,
      size.width * 0.4,
      size.height * 0.35,
    );
    path.quadraticBezierTo(
      size.width * 0.6,
      size.height * 0.20,
      size.width * 0.8,
      size.height * 0.35,
    );
    path.quadraticBezierTo(
      size.width * 0.9,
      size.height * 0.43,
      size.width,
      size.height * 0.35,
    );
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(LightCloudClipper oldClipper) => false;
}
