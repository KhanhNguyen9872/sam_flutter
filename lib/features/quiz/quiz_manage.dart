import 'package:flutter/material.dart';
import 'quiz.dart'; // Reuse the Quiz and Question models from quiz.dart
import '../../headers/header_child_no_notification.dart';

class QuizManagePage extends StatefulWidget {
  const QuizManagePage({Key? key}) : super(key: key);

  @override
  State<QuizManagePage> createState() => _QuizManagePageState();
}

class _QuizManagePageState extends State<QuizManagePage> {
  List<Quiz> _localQuizzes = [];

  @override
  void initState() {
    super.initState();
    _loadLocalQuizzes();
  }

  Future<void> _loadLocalQuizzes() async {
    // Simulate loading user-created quizzes from local storage.
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      _localQuizzes = [
        Quiz(
          id: 'local1',
          title: 'My Custom Quiz',
          description: 'A quiz I created myself',
          isDefault: false,
          questions: [
            Question(
              question: 'Custom Question 1',
              imageUrl: null,
              options: ['Option A', 'Option B', 'Option C', 'Option D'],
              correctIndex: 0,
            ),
            Question(
              question: 'Custom Question 2',
              imageUrl: null,
              options: ['Option A', 'Option B', 'Option C', 'Option D'],
              correctIndex: 2,
            ),
          ],
        ),
      ];
    });
  }

  void _addQuiz() {
    // For demonstration, we simulate adding a new quiz.
    setState(() {
      _localQuizzes.add(
        Quiz(
          id: 'local${_localQuizzes.length + 1}',
          title: 'New Custom Quiz',
          description: 'A newly created quiz',
          isDefault: false,
          questions: [
            Question(
              question: 'New Question 1',
              imageUrl: null,
              options: ['A', 'B', 'C', 'D'],
              correctIndex: 1,
            ),
          ],
        ),
      );
    });
  }

  void _editQuiz(Quiz quiz) {
    // For demonstration, just show a Snackbar.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Edit quiz: ${quiz.title}')),
    );
  }

  void _deleteQuiz(Quiz quiz) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Quiz'),
        content: const Text('Are you sure you want to delete this quiz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _localQuizzes.removeWhere((q) => q.id == quiz.id);
              });
              Navigator.of(context).pop();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizItem(Quiz quiz) {
    return Card(
      child: ListTile(
        title: Text(quiz.title),
        subtitle: Text(quiz.description),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _editQuiz(quiz),
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _deleteQuiz(quiz),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Use the header at the top.
      body: Column(
        children: [
          const HeaderChildNoNotification(title: "Manage Your Own Quiz"),
          Expanded(
            child: _localQuizzes.isEmpty
                ? const Center(child: Text('No quizzes found.'))
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: _localQuizzes.map(_buildQuizItem).toList(),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addQuiz,
        child: const Icon(Icons.add),
      ),
    );
  }
}
