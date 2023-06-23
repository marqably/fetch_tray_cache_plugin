class Post {
  final int id;
  final String title;
  final String body;
  final int userId;
  final List<String> tags;
  final int reactions;

  Post({
    required this.id,
    required this.title,
    required this.body,
    required this.userId,
    this.tags = const [],
    this.reactions = 0,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      title: json['title'],
      body: json['body'],
      userId: json['userId'],
      tags: json['tags'] != null ? List<String>.from(json['tags']) : [],
      reactions: json['reactions'] ?? 0,
    );
  }
}
