import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../api.dart';
import 'quiz_play.dart';
import '../../headers/header_child_no_notification.dart';
import 'quiz_manage.dart';
import '../../models/quiz.dart'; // Nhập các mô hình dùng chung

class QuizSelectionPage extends StatefulWidget {
  const QuizSelectionPage({Key? key}) : super(key: key);

  @override
  State<QuizSelectionPage> createState() => _TrangThaiTrangChonQuiz();
}

class _TrangThaiTrangChonQuiz extends State<QuizSelectionPage> {
  List<Quiz> _danhSachQuizMacDinh = [];
  List<Quiz> _danhSachQuizLocal = [];
  bool _dangTai = true;
  String? _thongBaoLoi;

  @override
  void initState() {
    super.initState();
    _taiDuLieu();
  }

  Future<String?> _layToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('accessToken');
  }

  Future<void> _taiDuLieu() async {
    await Future.wait([
      _taiQuizMacDinh(),
      _taiQuizLocal(),
    ]);
  }

  Future<void> _taiQuizMacDinh() async {
    setState(() {
      _dangTai = true;
      _thongBaoLoi = null;
    });
    try {
      final token = await _layToken();
      if (token == null) {
        throw Exception('Không tìm thấy token. Vui lòng đăng nhập.');
      }
      final quizzes = await Api.getDefaultQuizzes(accessToken: token);
      setState(() {
        _danhSachQuizMacDinh = quizzes;
        _dangTai = false;
      });
    } catch (e) {
      setState(() {
        _dangTai = false;
        _thongBaoLoi = e.toString();
      });
      if (e.toString().contains('Phiên đăng nhập hết hạn')) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushReplacementNamed(context, '/welcome');
        });
      }
    }
  }

  Future<void> _taiQuizLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final String? quizzesJson = prefs.getString('local_quizzes');
    if (quizzesJson != null) {
      final List<dynamic> decoded = jsonDecode(quizzesJson);
      setState(() {
        _danhSachQuizLocal = decoded.map((q) => Quiz.fromJson(q)).toList();
      });
    } else {
      // Quiz local mặc định nếu chưa có
      _danhSachQuizLocal = [
        Quiz(
          id: 'local1',
          title: 'Quiz Đầu Tiên Của Tôi',
          description: 'Một quiz mẫu được tạo cục bộ',
          isDefault: false,
          questions: [
            Question(
              question: '2 + 2 là bao nhiêu?',
              imageUrl: null,
              options: ['3', '4', '5', '6'],
              correctIndex: 1,
            ),
          ],
        ),
      ];
      _luuQuizLocal();
    }
  }

  Future<void> _luuQuizLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final String jsonString = jsonEncode(_danhSachQuizLocal
        .map((q) => {
              'id': q.id,
              'title': q.title,
              'description': q.description,
              'questions': q.questions
                  ?.map((q) => {
                        'question': q.question,
                        'imageUrl': q.imageUrl,
                        'options': q.options,
                        'correctIndex': q.correctIndex,
                      })
                  .toList(),
              'isDefault': q.isDefault,
            })
        .toList());
    await prefs.setString('local_quizzes', jsonString);
  }

  void _chuyenDenTrangChoiQuiz(Quiz quiz) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizPlayPage(quiz: quiz),
      ),
    );
  }

  void _chuyenDenTrangQuanLyQuiz() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const QuizManagePage(),
      ),
    ).then(
        (_) => _taiQuizLocal()); // Làm mới danh sách quiz local sau khi quản lý
  }

  Widget _taoTheQuiz(Quiz quiz) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(
          quiz.title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(quiz.description),
        ),
        trailing: const Icon(Icons.play_arrow, color: Colors.blueAccent),
        onTap: () => _chuyenDenTrangChoiQuiz(quiz),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          const HeaderChildNoNotification(title: "Chọn Một Quiz"),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _taiDuLieu,
              child: _dangTai
                  ? const Center(child: CircularProgressIndicator())
                  : _thongBaoLoi != null
                      ? SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _thongBaoLoi!,
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontSize: 16,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: _taiDuLieu,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blueAccent,
                                  ),
                                  child: const Text('Thử lại'),
                                ),
                              ],
                            ),
                          ),
                        )
                      : _danhSachQuizMacDinh.isEmpty &&
                              _danhSachQuizLocal.isEmpty
                          ? SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              child: const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Text(
                                    'Không có quiz nào. Tạo một quiz ngay bây giờ!',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                              ),
                            )
                          : SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Quiz Mặc Định',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blueAccent,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    if (_danhSachQuizMacDinh.isEmpty)
                                      const Padding(
                                        padding: EdgeInsets.only(left: 8),
                                        child: Text(
                                          'Không có quiz mặc định nào.',
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                      )
                                    else
                                      ..._danhSachQuizMacDinh.map(_taoTheQuiz),
                                    const SizedBox(height: 20),
                                    const Text(
                                      'Quiz Của Tôi',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blueAccent,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    if (_danhSachQuizLocal.isEmpty)
                                      const Padding(
                                        padding: EdgeInsets.only(left: 8),
                                        child: Text(
                                          'Chưa có quiz local nào.',
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                      )
                                    else
                                      ..._danhSachQuizLocal.map(_taoTheQuiz),
                                  ],
                                ),
                              ),
                            ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _chuyenDenTrangQuanLyQuiz,
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add),
      ),
    );
  }
}
