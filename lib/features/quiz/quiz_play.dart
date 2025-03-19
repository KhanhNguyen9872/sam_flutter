import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/quiz.dart';
import '../../headers/header_child_no_notification.dart';

class QuizPlayPage extends StatefulWidget {
  final Quiz quiz;
  const QuizPlayPage({Key? key, required this.quiz}) : super(key: key);

  @override
  State<QuizPlayPage> createState() => _QuizPlayPageState();
}

class _QuizPlayPageState extends State<QuizPlayPage>
    with TickerProviderStateMixin {
  int _chiSoCauHoiHienTai = 0;
  int _diemSo = 0;
  int _soCauDung = 0; // Theo dõi số câu trả lời đúng.
  bool _daTraLoi = false;
  int _chiSoLuaChon = -1;
  static const int thoiGianMoiCau = 15; // giây cho mỗi câu hỏi.
  int _thoiGianConLai = thoiGianMoiCau;
  Timer? _boDemThoiGian;
  AnimationController? _boDieuKhienTienTrinh;
  bool _hetThoiGian = false; // Cờ cho hoạt hình hết thời gian.

  @override
  void initState() {
    super.initState();
    _batDauDemThoiGian();
    _batDauHoatHinhTienTrinh();
  }

  @override
  void dispose() {
    _boDemThoiGian?.cancel();
    _boDieuKhienTienTrinh?.dispose();
    super.dispose();
  }

  void _batDauDemThoiGian() {
    _thoiGianConLai = thoiGianMoiCau;
    _boDemThoiGian?.cancel();
    _boDemThoiGian = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_thoiGianConLai == 0) {
        _xuLyHetThoiGian();
      } else {
        setState(() {
          _thoiGianConLai--;
        });
      }
    });
  }

  void _batDauHoatHinhTienTrinh() {
    _boDieuKhienTienTrinh?.dispose();
    _boDieuKhienTienTrinh = AnimationController(
      vsync: this,
      duration: const Duration(seconds: thoiGianMoiCau),
    );
    _boDieuKhienTienTrinh?.forward();
  }

  void _xuLyHetThoiGian() {
    _boDemThoiGian?.cancel();
    _boDieuKhienTienTrinh?.stop();
    setState(() {
      _daTraLoi = true;
      _hetThoiGian = true;
    });
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _hetThoiGian = false;
      });
      _chuyenDenCauTiepTheo();
    });
  }

  void _chonLuaChon(int chiSo) {
    if (_daTraLoi) return;
    _boDemThoiGian?.cancel(); // Dừng bộ đếm thời gian ngay lập tức.
    _boDieuKhienTienTrinh?.stop();
    setState(() {
      _daTraLoi = true;
      _chiSoLuaChon = chiSo;
      if (chiSo == widget.quiz.questions![_chiSoCauHoiHienTai].correctIndex) {
        _diemSo += _thoiGianConLai; // Cộng thời gian còn lại vào điểm nếu đúng.
        _soCauDung++;
      }
    });
    Future.delayed(const Duration(seconds: 2), () {
      _chuyenDenCauTiepTheo();
    });
  }

  void _chuyenDenCauTiepTheo() {
    if (_chiSoCauHoiHienTai < widget.quiz.questions!.length - 1) {
      setState(() {
        _chiSoCauHoiHienTai++;
        _daTraLoi = false;
        _chiSoLuaChon = -1;
      });
      _batDauDemThoiGian();
      _batDauHoatHinhTienTrinh();
    } else {
      _hienThiKetQua();
    }
  }

  void _hienThiKetQua() {
    _boDemThoiGian?.cancel();
    int tongSoCau = widget.quiz.questions!.length;
    int soCauSai = tongSoCau - _soCauDung;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Quiz Hoàn Thành'),
        content:
            Text('Điểm của bạn: $_diemSo\nĐúng: $_soCauDung\nSai: $soCauSai'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Đóng hộp thoại.
              Navigator.of(context).pop(); // Quay lại trang chọn quiz.
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<bool> _khiQuayLai() async {
    // Nếu quiz chưa hoàn thành, hiển thị hộp thoại xác nhận.
    if (_chiSoCauHoiHienTai < widget.quiz.questions!.length - 1) {
      bool? thoatQuiz = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Thoát Quiz?'),
          content: const Text(
              'Quiz chưa hoàn thành. Bạn có thực sự muốn thoát không? Tiến trình của bạn sẽ bị mất.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Không'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Có'),
            ),
          ],
        ),
      );
      return thoatQuiz ?? false;
    }
    return true; // Cho phép quay lại nếu quiz đã hoàn thành.
  }

  @override
  Widget build(BuildContext context) {
    final cauHoi = widget.quiz.questions![_chiSoCauHoiHienTai];
    final chieuRongManHinh = MediaQuery.of(context).size.width;
    final chieuCaoManHinh = MediaQuery.of(context).size.height;
    // Sử dụng kích thước chữ gốc cho các nút trả lời.
    final kichThuocChuTraLoi = chieuRongManHinh < 360 ? 16.0 : 20.0;
    final kichThuocChuCauHoi = chieuRongManHinh < 360 ? 20.0 : 26.0;
    // Quay lại nút trả lời lớn hơn với childAspectRatio = 0.8 (màn hình nhỏ) hoặc 1.0 (màn hình lớn).
    final double tyLeCon = chieuCaoManHinh < 600 ? 0.8 : 1.0;

    // Xác định bốn màu cho các ô trả lời.
    final List<Color> mauTraLoi = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
    ];

    return WillPopScope(
      onWillPop: _khiQuayLai,
      child: Scaffold(
        // Thay vì dùng AppBar, chúng ta hiển thị widget tiêu đề tùy chỉnh ở trên cùng.
        body: SafeArea(
          child: Column(
            children: [
              // Tiêu đề tùy chỉnh.
              const HeaderChildNoNotification(title: "Chơi Quiz"),
              // Phần còn lại của bố cục quiz.
              // Hàng trên cùng: Bộ đếm thời gian bên trái, "Câu hỏi x của y" bên phải.
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 40,
                          height: 40,
                          child: AnimatedBuilder(
                            animation: _boDieuKhienTienTrinh!,
                            builder: (context, child) {
                              return CircularProgressIndicator(
                                value: 1 - _boDieuKhienTienTrinh!.value,
                                strokeWidth: 3,
                                backgroundColor: Colors.grey.shade300,
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                    Colors.blue),
                              );
                            },
                          ),
                        ),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 500),
                          transitionBuilder: (child, animation) =>
                              ScaleTransition(scale: animation, child: child),
                          child: Text(
                            '$_thoiGianConLai',
                            key: ValueKey<int>(_thoiGianConLai),
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      'Câu hỏi ${_chiSoCauHoiHienTai + 1} / ${widget.quiz.questions!.length}',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const Divider(),
              // Khu vực câu hỏi thu nhỏ.
              Expanded(
                flex: 1,
                child: Stack(
                  children: [
                    Center(
                      child: cauHoi.imageUrl != null
                          ? Image.network(
                              cauHoi.imageUrl!,
                              height: 150,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            )
                          : Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                cauHoi.question,
                                style: TextStyle(
                                    fontSize: kichThuocChuCauHoi,
                                    fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                            ),
                    ),
                    // Lớp phủ "Hết thời gian!".
                    AnimatedOpacity(
                      opacity: _hetThoiGian ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 500),
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            "Hết Thời Gian!",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: kichThuocChuCauHoi,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Khu vực lựa chọn đáp án.
              Expanded(
                flex: 3,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: GridView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.all(16),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: tyLeCon,
                    ),
                    itemCount: cauHoi.options.length,
                    itemBuilder: (context, index) {
                      Color mauNut = mauTraLoi[index % mauTraLoi.length];
                      if (_daTraLoi) {
                        if (index == cauHoi.correctIndex) {
                          mauNut = Colors.green;
                        } else if (index == _chiSoLuaChon &&
                            index != cauHoi.correctIndex) {
                          mauNut = Colors.red;
                        } else {
                          mauNut = Colors.grey;
                        }
                      }
                      return GestureDetector(
                        onTap: () => _chonLuaChon(index),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: mauNut,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            cauHoi.options[index],
                            style: TextStyle(
                              fontSize: kichThuocChuTraLoi,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
