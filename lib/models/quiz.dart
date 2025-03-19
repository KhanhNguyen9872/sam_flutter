// lib/models/quiz.dart
class Quiz {
  final String id;
  final String title;
  final String description;
  final List<Question>? questions;
  final bool isDefault;

  Quiz({
    required this.id,
    required this.title,
    required this.description,
    this.questions,
    required this.isDefault,
  });

  factory Quiz.fromJson(Map<String, dynamic> json) {
    var questionsJson = json['questions'] as List?;
    List<Question>? questionsList =
        questionsJson?.map((q) => Question.fromJson(q)).toList();
    return Quiz(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      questions: questionsList,
      isDefault: json['isDefault'],
    );
  }
}

class Question {
  final String question;
  final String? imageUrl;
  final List<String> options;
  final int correctIndex;

  Question({
    required this.question,
    this.imageUrl,
    required this.options,
    required this.correctIndex,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      question: json['question'],
      imageUrl: json['imageUrl'],
      options: List<String>.from(json['options']),
      correctIndex: json['correctIndex'],
    );
  }
}
