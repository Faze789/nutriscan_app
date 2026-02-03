class VideoRecommendation {
  final String id;
  final String title;
  final String channelName;
  final String youtubeUrl;
  final String thumbnailUrl;
  final String category;
  final String targetGoal;
  final int durationSeconds;
  final DateTime addedAt;

  VideoRecommendation({
    required this.id,
    required this.title,
    required this.channelName,
    required this.youtubeUrl,
    required this.thumbnailUrl,
    required this.category,
    required this.targetGoal,
    required this.durationSeconds,
    DateTime? addedAt,
  }) : addedAt = addedAt ?? DateTime.now();

  String get durationFormatted {
    final m = durationSeconds ~/ 60;
    final s = durationSeconds % 60;
    return '${m}m ${s.toString().padLeft(2, '0')}s';
  }

  /// Extract video ID from YouTube URL for embedding
  String? get videoId {
    final uri = Uri.tryParse(youtubeUrl);
    if (uri == null) return null;
    if (uri.queryParameters.containsKey('v')) {
      return uri.queryParameters['v'];
    }
    if (uri.host.contains('youtu.be') && uri.pathSegments.isNotEmpty) {
      return uri.pathSegments.first;
    }
    return null;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'channelName': channelName,
        'youtubeUrl': youtubeUrl,
        'thumbnailUrl': thumbnailUrl,
        'category': category,
        'targetGoal': targetGoal,
        'durationSeconds': durationSeconds,
        'addedAt': addedAt.toIso8601String(),
      };

  factory VideoRecommendation.fromJson(Map<String, dynamic> json) =>
      VideoRecommendation(
        id: json['id'] as String,
        title: json['title'] as String,
        channelName: json['channelName'] as String,
        youtubeUrl: json['youtubeUrl'] as String,
        thumbnailUrl: json['thumbnailUrl'] as String,
        category: json['category'] as String,
        targetGoal: json['targetGoal'] as String,
        durationSeconds: json['durationSeconds'] as int,
        addedAt: DateTime.parse(json['addedAt'] as String),
      );
}
