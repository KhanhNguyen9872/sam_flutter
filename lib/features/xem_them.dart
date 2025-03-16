import 'package:flutter/material.dart';
import '../headers/header_child.dart';
import 'thoi_khoa_bieu.dart';
import 'hoc_phi.dart';
import 'ma_qr.dart';
import 'quiz/quiz.dart';

class XemThemScreen extends StatelessWidget {
  const XemThemScreen({Key? key}) : super(key: key);

  // Danh sách các chức năng với title, image và description.
  final List<Map<String, String>> features = const [
    {
      "title": "Thời khóa biểu",
      "image": "assets/images/thoi_khoa_bieu.png",
      "description": "Xem lịch học hàng ngày của bạn"
    },
    {
      "title": "Sổ liên lạc",
      "image": "assets/images/so_lien_lac.png",
      "description": "Liên hệ với giáo viên và phụ huynh"
    },
    {
      "title": "Kết quả học tập",
      "image": "assets/images/ket_qua_hoc_tap.png",
      "description": "Xem kết quả và tiến độ học tập của bạn"
    },
    {
      "title": "Danh sách",
      "image": "assets/images/danh_sach.png",
      "description": "Danh sách học sinh, giáo viên và các lớp học"
    },
    {
      "title": "Học phí",
      "image": "assets/images/hoc_phi.png",
      "description": "Quản lý và thanh toán học phí"
    },
    {
      "title": "Mã QR",
      "image": "assets/images/ma_qr.png",
      "description": "Quét mã QR để truy cập thông tin nhanh"
    },
    {
      "title": "Thư viện ảnh",
      "image": "assets/images/thu_vien_anh.png",
      "description": "Xem và chia sẻ ảnh từ các sự kiện"
    },
    {
      "title": "Chơi Quizz",
      "image": "assets/images/quiz.png",
      "description": "Thử sức với các câu hỏi trắc nghiệm thú vị"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Sử dụng widget HeaderChild để hiển thị header.
          const HeaderChild(title: 'Danh sách chức năng'),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: features.length,
              itemBuilder: (context, index) {
                final feature = features[index];
                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(feature["image"]!),
                          fit: BoxFit.contain,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    title: Text(
                      feature["title"]!,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        feature["description"]!,
                        style: const TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      final title = feature["title"]!;
                      if (title == "Thời khóa biểu") {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ThoiKhoaBieuScreen()),
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
                      } else if (title == "Chơi Quizz") {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const QuizSelectionPage()),
                        );
                      }
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
