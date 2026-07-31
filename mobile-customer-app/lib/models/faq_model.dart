class FaqModel {
  final String question;
  final String answer;
  final String category;

  FaqModel({required this.question, required this.answer, required this.category});

  factory FaqModel.fromJson(Map<String, dynamic> json) {
    return FaqModel(
      question: json['question'] as String,
      answer: json['answer'] as String,
      category: json['category'] as String? ?? 'general',
    );
  }
}
