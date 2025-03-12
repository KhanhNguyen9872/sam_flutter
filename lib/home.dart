import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0; // chỉ số cho BottomNavigationBar

  // Biến kiểm tra có thông báo hay không
  bool hasNotification = false;

  // Danh sách tính năng nổi bật
  final List<Map<String, String>> _features = [
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
  ];

  // Danh sách buổi học (demo)
  final List<Map<String, String>> _classes = [
    {
      "title": "LUYỆN THI TOEIC",
      "session": "Buổi 1: Present Tenses",
      "timeRange": "9:00 - 10:30",
      "date": "Thứ 6, 2/3/2025",
      "teacher": "Thầy John Smith",
      "room": "E303",
      "status": "Đang diễn ra"
    },
    {
      "title": "LUYỆN THI IELTS",
      "session": "Buổi 2: Future Tenses",
      "timeRange": "10:45 - 12:00",
      "date": "Thứ 6, 2/3/2025",
      "teacher": "Cô Anna",
      "room": "E305",
      "status": "Sắp diễn ra"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // HEADER
            _buildHeader(),

            // TÍNH NĂNG NỔI BẬT (tiêu đề căn trái, chữ lớn và đậm)
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

            // CÁC BUỔI TRONG TUẦN (tiêu đề căn trái, chữ lớn và đậm + hiển thị ngày đầu và cuối tuần)
            _buildWeekTitle(),

            _buildClassList(),
            const SizedBox(height: 16),
          ],
        ),
      ),

      // BOTTOM NAVIGATION
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          // TODO: chuyển trang tương ứng nếu cần
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Trang chủ",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book),
            label: "Bài học",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Cá nhân",
          ),
        ],
      ),
    );
  }

  // ------------------- HEADER ------------------- //
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 20, left: 16, right: 16, bottom: 16),
      decoration: const BoxDecoration(
        color: Color(0xFF2F3D85),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Dùng Stack để đặt logo ở giữa, bên trái lời chào, bên phải nút thông báo
          Stack(
            children: [
              // Logo SAM EDTECH ở giữa
              Center(
                child: Image.asset(
                  "assets/images/sam_edtech.png",
                  width: 90,
                  fit: BoxFit.contain,
                ),
              ),
              // Lời chào bên trái
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
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Welcome back",
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),
              // Nút thông báo bên phải: hiển thị ảnh tùy theo có thông báo hay không
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                child: IconButton(
                  onPressed: () {
                    // TODO: mở trang thông báo
                  },
                  icon: Image.asset(
                    hasNotification
                        ? "assets/images/have_notification.png"
                        : "assets/images/notification.png",
                    width: 24,
                    height: 24,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Thông tin user: avatar + tên + MSHV, background màu trắng
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.grey.shade300,
                  child: Icon(
                    Icons.person,
                    size: 28,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "TRƯỜNG VĂN TÀI",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "MSHV: G16-001",
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ------------------- GRID TÍNH NĂNG ------------------- //
  Widget _buildFeatureGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _features.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4, // 4 tính năng trên 1 dòng
              mainAxisExtent: 80,
            ),
            itemBuilder: (context, index) {
              final item = _features[index];
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Hình ảnh tính năng
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: Image.asset(
                      item["image"]!,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Tiêu đề tính năng
                  Text(
                    item["title"]!,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade800),
                    textAlign: TextAlign.center,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // ------------------- TIÊU ĐỀ "CÁC BUỔI TRONG TUẦN" VÀ WEEK RANGE ------------------- //
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
              style: TextStyle(
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

  // ------------------- DANH SÁCH BUỔI HỌC ------------------- //
  Widget _buildClassList() {
    return ListView.builder(
      itemCount: _classes.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final item = _classes[index];
        final status = item["status"] ?? "";
        final Color statusColor =
            status == "Đang diễn ra" ? Colors.green : Colors.orange;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 1.5,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tên khoá học
                  Text(
                    item["title"] ?? "",
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Dòng session (toàn bộ in màu cam)
                  Text(
                    item["session"] ?? "",
                    style: const TextStyle(
                      color: Colors.orange,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Thời gian học
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
                  // Ngày học
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
                  // Giáo viên
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
                  // Phòng
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
                  // Trạng thái
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
  }
}
