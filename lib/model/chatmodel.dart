class ChatMessageModel {
  String id;
  String senderId;
  String receiverId;
  String message;
  DateTime timestamp;

  ChatMessageModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.message,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'receiverId': receiverId,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['id'] ?? '',
      senderId: json['senderId'] ?? '',
      receiverId: json['receiverId'] ?? '',
      message: json['message'] ?? '',
      timestamp: json['timestamp'] != null
          ? (json['timestamp'] is String
              ? DateTime.parse(json['timestamp'])
              : DateTime.now())
          : DateTime.now(),
    );
  }
}

typedef ChatMessage = ChatMessageModel;
