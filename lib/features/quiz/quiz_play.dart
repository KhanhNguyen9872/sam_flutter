import 'dart:async';
import 'package:flutter/material.dart';
import 'quiz.dart'; // Import the Quiz and Question models
import '../../headers/header_child_no_notification.dart';

class QuizPlayPage extends StatefulWidget {
  final Quiz quiz;
  const QuizPlayPage({Key? key, required this.quiz}) : super(key: key);

  @override
  State<QuizPlayPage> createState() => _QuizPlayPageState();
}

class _QuizPlayPageState extends State<QuizPlayPage>
    with TickerProviderStateMixin {
  int _currentQuestionIndex = 0;
  int _score = 0;
  int _correctCount = 0; // Track correct answers.
  bool _answered = false;
  int _selectedOptionIndex = -1;
  static const int questionDuration = 15; // seconds per question.
  int _remainingTime = questionDuration;
  Timer? _timer;
  AnimationController? _progressController;
  bool _timeUp = false; // Flag for timeout animation.

  @override
  void initState() {
    super.initState();
    _startTimer();
    _startProgressAnimation();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _progressController?.dispose();
    super.dispose();
  }

  void _startTimer() {
    _remainingTime = questionDuration;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime == 0) {
        _handleTimeout();
      } else {
        setState(() {
          _remainingTime--;
        });
      }
    });
  }

  void _startProgressAnimation() {
    _progressController?.dispose();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: questionDuration),
    );
    _progressController?.forward();
  }

  void _handleTimeout() {
    _timer?.cancel();
    _progressController?.stop();
    setState(() {
      _answered = true;
      _timeUp = true;
    });
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _timeUp = false;
      });
      _goToNextQuestion();
    });
  }

  void _selectOption(int index) {
    if (_answered) return;
    _timer?.cancel(); // Stop timer immediately.
    _progressController?.stop();
    setState(() {
      _answered = true;
      _selectedOptionIndex = index;
      if (index == widget.quiz.questions![_currentQuestionIndex].correctIndex) {
        _score += _remainingTime; // Add remaining time to score if correct.
        _correctCount++;
      }
    });
    Future.delayed(const Duration(seconds: 2), () {
      _goToNextQuestion();
    });
  }

  void _goToNextQuestion() {
    if (_currentQuestionIndex < widget.quiz.questions!.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _answered = false;
        _selectedOptionIndex = -1;
      });
      _startTimer();
      _startProgressAnimation();
    } else {
      _showResultDialog();
    }
  }

  void _showResultDialog() {
    _timer?.cancel();
    int totalQuestions = widget.quiz.questions!.length;
    int incorrectCount = totalQuestions - _correctCount;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Quiz Completed'),
        content: Text(
            'Your score: $_score\nCorrect: $_correctCount\nIncorrect: $incorrectCount'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog.
              Navigator.of(context).pop(); // Go back to quiz selection.
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<bool> _onWillPop() async {
    // If quiz isn't complete, show confirmation popup.
    if (_currentQuestionIndex < widget.quiz.questions!.length - 1) {
      bool? exitQuiz = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Exit Quiz?'),
          content: const Text(
              'The quiz is not complete. Do you really want to exit? Your progress will be lost.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Yes'),
            ),
          ],
        ),
      );
      return exitQuiz ?? false;
    }
    return true; // Allow pop if quiz is complete.
  }

  @override
  Widget build(BuildContext context) {
    final question = widget.quiz.questions![_currentQuestionIndex];
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    // Use original font sizes for answer buttons.
    final answerFontSize = screenWidth < 360 ? 16.0 : 20.0;
    final questionFontSize = screenWidth < 360 ? 20.0 : 26.0;
    // Revert to larger answer buttons with childAspectRatio = 0.8 (small screens) or 1.0 (large screens).
    final double childAspectRatio = screenHeight < 600 ? 0.8 : 1.0;

    // Define four colors for answer squares.
    final List<Color> answerColors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
    ];

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        // Instead of using an AppBar, we show our custom header widget at the top.
        body: SafeArea(
          child: Column(
            children: [
              // Custom header.
              const HeaderChildNoNotification(title: "Quiz Play"),
              // The rest of the quiz layout.
              // Top row: Timer on left, "Question x of y" on right.
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
                            animation: _progressController!,
                            builder: (context, child) {
                              return CircularProgressIndicator(
                                value: 1 - _progressController!.value,
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
                            '$_remainingTime',
                            key: ValueKey<int>(_remainingTime),
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      'Question ${_currentQuestionIndex + 1} of ${widget.quiz.questions!.length}',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const Divider(),
              // Reduced Question area.
              Expanded(
                flex: 1,
                child: Stack(
                  children: [
                    Center(
                      child: question.imageUrl != null
                          ? Image.network(
                              question.imageUrl!,
                              height: 150,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            )
                          : Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                question.question,
                                style: TextStyle(
                                    fontSize: questionFontSize,
                                    fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                            ),
                    ),
                    // "Time's Up!" overlay.
                    AnimatedOpacity(
                      opacity: _timeUp ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 500),
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            "Time's Up!",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: questionFontSize,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Answer options area.
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
                      childAspectRatio: childAspectRatio,
                    ),
                    itemCount: question.options.length,
                    itemBuilder: (context, index) {
                      Color btnColor =
                          answerColors[index % answerColors.length];
                      if (_answered) {
                        if (index == question.correctIndex) {
                          btnColor = Colors.green;
                        } else if (index == _selectedOptionIndex &&
                            index != question.correctIndex) {
                          btnColor = Colors.red;
                        } else {
                          btnColor = Colors.grey;
                        }
                      }
                      return GestureDetector(
                        onTap: () => _selectOption(index),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: btnColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            question.options[index],
                            style: TextStyle(
                              fontSize: answerFontSize,
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
