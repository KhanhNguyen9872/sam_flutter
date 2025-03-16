import 'package:flutter/material.dart';
import '../../api.dart'; // Simulated API methods can be added here if needed.
import 'quiz_play.dart'; // Navigate to the quiz play page
import '../../headers/header_child_no_notification.dart';
import 'quiz_manage.dart'; // Navigate to the quiz management page

/// Model for a quiz.
class Quiz {
  final String id;
  final String title;
  final String description;
  final List<Question>?
      questions; // Provided for default quizzes (from API) or user-created ones.
  final bool isDefault; // True if it's a default quiz from API.

  Quiz({
    required this.id,
    required this.title,
    required this.description,
    this.questions,
    required this.isDefault,
  });
}

/// Model for a question in a quiz.
class Question {
  final String question;
  final String? imageUrl; // Optional image for the question.
  final List<String> options;
  final int correctIndex;

  Question({
    required this.question,
    this.imageUrl,
    required this.options,
    required this.correctIndex,
  });
}

class QuizSelectionPage extends StatefulWidget {
  const QuizSelectionPage({Key? key}) : super(key: key);

  @override
  State<QuizSelectionPage> createState() => _QuizSelectionPageState();
}

class _QuizSelectionPageState extends State<QuizSelectionPage> {
  List<Quiz> _defaultQuizzes = [];
  List<Quiz> _localQuizzes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDefaultQuizzes();
    _loadLocalQuizzes();
  }

  Future<void> _loadDefaultQuizzes() async {
    // Simulate fetching default quizzes from an API.
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _defaultQuizzes = [
        Quiz(
          id: 'default1',
          title: 'General Knowledge',
          description: 'A quiz on general knowledge',
          isDefault: true,
          questions: [
            Question(
              question: 'What is the capital of France?',
              imageUrl: null,
              options: ['Berlin', 'London', 'Paris', 'Rome'],
              correctIndex: 2,
            ),
            Question(
              question: 'Which planet is known as the Red Planet?',
              imageUrl: null,
              options: ['Earth', 'Mars', 'Jupiter', 'Saturn'],
              correctIndex: 1,
            ),
          ],
        ),
        Quiz(
          id: 'default2',
          title: 'Science Quiz',
          description: 'Test your science knowledge',
          isDefault: true,
          questions: [
            Question(
              question: 'Who developed the theory of relativity?',
              imageUrl: null,
              options: ['Newton', 'Einstein', 'Galileo', 'Tesla'],
              correctIndex: 1,
            ),
            Question(
              question: 'What is the chemical symbol for water?',
              imageUrl: null,
              options: ['H2O', 'CO2', 'NaCl', 'O2'],
              correctIndex: 0,
            ),
          ],
        ),
      ];
      _isLoading = false;
    });
  }

  Future<void> _loadLocalQuizzes() async {
    // Simulate loading user-created quizzes from local storage.
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      // For demonstration, we simulate one local quiz.
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

  void _navigateToQuizPlay(Quiz quiz) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizPlayPage(quiz: quiz),
      ),
    );
  }

  void _navigateToQuizManage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const QuizManagePage(),
      ),
    );
  }

  Widget _buildQuizCard(Quiz quiz) {
    return Card(
      child: ListTile(
        title: Text(quiz.title),
        subtitle: Text(quiz.description),
        trailing: const Icon(Icons.play_arrow),
        onTap: () => _navigateToQuizPlay(quiz),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Show custom header at the top.
      body: Column(
        children: [
          const HeaderChildNoNotification(title: "Select a Quiz"),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Default Quizzes',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          ..._defaultQuizzes.map(_buildQuizCard).toList(),
                          const SizedBox(height: 20),
                          const Text(
                            'My Quizzes',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          ..._localQuizzes.map(_buildQuizCard).toList(),
                          const SizedBox(height: 20),
                          Center(
                            child: ElevatedButton(
                              onPressed: _navigateToQuizManage,
                              child: const Text('Manage Your Own Quiz'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
