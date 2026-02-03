List<String> _parseTags(dynamic raw) {
  if (raw is List) return raw.map((t) => t.toString()).toList();
  if (raw is String) return raw.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty).toList();
  return [];
}

class HealthArticle {
  final String id;
  final String title;
  final String summary;
  final String content;
  final String category;
  final List<String> tags;
  final String? imageUrl;
  final DateTime generatedAt;
  final bool isFavorite;

  HealthArticle({
    required this.id,
    required this.title,
    required this.summary,
    required this.content,
    required this.category,
    this.tags = const [],
    this.imageUrl,
    DateTime? generatedAt,
    this.isFavorite = false,
  }) : generatedAt = generatedAt ?? DateTime.now();

  HealthArticle copyWith({bool? isFavorite}) {
    return HealthArticle(
      id: id,
      title: title,
      summary: summary,
      content: content,
      category: category,
      tags: tags,
      imageUrl: imageUrl,
      generatedAt: generatedAt,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'summary': summary,
        'content': content,
        'category': category,
        'tags': tags,
        'imageUrl': imageUrl,
        'generatedAt': generatedAt.toIso8601String(),
        'isFavorite': isFavorite,
      };

  factory HealthArticle.fromJson(Map<String, dynamic> json) => HealthArticle(
        id: json['id'] as String,
        title: json['title'] as String,
        summary: json['summary'] as String,
        content: json['content'] as String,
        category: json['category'] as String,
        tags: _parseTags(json['tags']),
        imageUrl: json['imageUrl'] as String?,
        generatedAt: DateTime.parse(json['generatedAt'] as String),
        isFavorite: json['isFavorite'] as bool? ?? false,
      );
}
