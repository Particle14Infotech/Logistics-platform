class ChatMessage {
  final String id;
  final String bookingId;
  final String senderId;
  final String senderRole; // 'customer' | 'driver'
  final String text;
  final DateTime createdAt;

  ChatMessage({
    required this.id,
    required this.bookingId,
    required this.senderId,
    required this.senderRole,
    required this.text,
    required this.createdAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['_id'] as String? ?? json['id'] as String,
      bookingId: json['bookingId'] as String,
      senderId: json['senderId'] as String,
      senderRole: json['senderRole'] as String,
      text: json['text'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
