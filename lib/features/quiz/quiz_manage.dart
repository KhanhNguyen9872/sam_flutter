import 'package:flutter/material.dart';
import '../../models/quiz.dart';
import '../../headers/header_child_no_notification.dart';

class QuizManagePage extends StatefulWidget {
  const QuizManagePage({Key? key}) : super(key: key);

  @override
  State<QuizManagePage> createState() => _QuizManagePageState();
}

class _QuizManagePageState extends State<QuizManagePage> {
  List<Quiz> _danhSachQuizLocal = [];

  @override
  void initState() {
    super.initState();
    _taiQuizLocal();
  }

  Future<void> _taiQuizLocal() async {
    // Mô phỏng tải các quiz do người dùng tạo từ bộ nhớ cục bộ.
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      _danhSachQuizLocal = [
        Quiz(
          id: 'local1',
          title: 'Quiz Tùy Chỉnh Của Tôi',
          description: 'Một quiz do tôi tự tạo',
          isDefault: false,
          questions: [
            Question(
              question: 'Câu Hỏi Tùy Chỉnh 1',
              imageUrl: null,
              options: ['Lựa Chọn A', 'Lựa Chọn B', 'Lựa Chọn C', 'Lựa Chọn D'],
              correctIndex: 0,
            ),
            Question(
              question: 'Câu Hỏi Tùy Chỉnh 2',
              imageUrl: null,
              options: ['Lựa Chọn A', 'Lựa Chọn B', 'Lựa Chọn C', 'Lựa Chọn D'],
              correctIndex: 2,
            ),
          ],
        ),
      ];
    });
  }

  void _themQuiz() {
    // Để minh họa, chúng ta mô phỏng việc thêm một quiz mới.
    setState(() {
      _danhSachQuizLocal.add(
        Quiz(
          id: 'local${_danhSachQuizLocal.length + 1}',
          title: 'Quiz Tùy Chỉnh Mới',
          description: 'Một quiz vừa được tạo',
          isDefault: false,
          questions: [
            Question(
              question: 'Câu Hỏi Mới 1',
              imageUrl: null,
              options: ['A', 'B', 'C', 'D'],
              correctIndex: 1,
            ),
          ],
        ),
      );
    });
  }

  void _suaQuiz(Quiz quiz) {
    // Để minh họa, chỉ hiển thị một SnackBar.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Sửa quiz: ${quiz.title}')),
    );
  }

  void _xoaQuiz(Quiz quiz) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa Quiz'),
        content: const Text('Bạn có chắc chắn muốn xóa quiz này không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _danhSachQuizLocal.removeWhere((q) => q.id == quiz.id);
              });
              Navigator.of(context).pop();
            },
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  Widget _taoMucQuiz(Quiz quiz) {
    return Card(
      child: ListTile(
        title: Text(quiz.title),
        subtitle: Text(quiz.description),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _suaQuiz(quiz),
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _xoaQuiz(quiz),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Sử dụng tiêu đề ở trên cùng.
      body: Column(
        children: [
          const HeaderChildNoNotification(title: "Quản Lý Quiz Của Bạn"),
          Expanded(
            child: _danhSachQuizLocal.isEmpty
                ? const Center(child: Text('Không tìm thấy quiz nào.'))
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: _danhSachQuizLocal.map(_taoMucQuiz).toList(),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _themQuiz,
        child: const Icon(Icons.add),
      ),
    );
  }
}
