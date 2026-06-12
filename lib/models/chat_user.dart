class ChatUser {
  final String uid;
  final String name;
  final String email;
  final String role;

  ChatUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
  });

  factory ChatUser.fromFirestore(String uid, Map<String, dynamic> data) {
    return ChatUser(
      uid: uid,
      name: (data['name'] ?? '').toString().isNotEmpty
          ? data['name']
          : (data['email'] ?? 'Unknown User'),
      email: data['email'] ?? '',
      role: data['role'] ?? 'user',
    );
  }
}