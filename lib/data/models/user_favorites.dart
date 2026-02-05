class UserFavorites {
  final String userUid;
  final List<String> articleIds;
  final List<String> videoIds;

  UserFavorites({
    required this.userUid,
    this.articleIds = const [],
    this.videoIds = const [],
  });

  UserFavorites copyWith({
    List<String>? articleIds,
    List<String>? videoIds,
  }) {
    return UserFavorites(
      userUid: userUid,
      articleIds: articleIds ?? this.articleIds,
      videoIds: videoIds ?? this.videoIds,
    );
  }

  Map<String, dynamic> toJson() => {
        'userUid': userUid,
        'articleIds': articleIds,
        'videoIds': videoIds,
      };

  factory UserFavorites.fromJson(Map<String, dynamic> json) => UserFavorites(
        userUid: json['userUid'] as String,
        articleIds: (json['articleIds'] as List?)?.cast<String>() ?? [],
        videoIds: (json['videoIds'] as List?)?.cast<String>() ?? [],
      );

  Map<String, dynamic> toSupabase() => {
        'user_id': userUid,
        'article_ids': articleIds,
        'video_ids': videoIds,
      };

  factory UserFavorites.fromSupabase(Map<String, dynamic> json) => UserFavorites(
        userUid: json['user_id'] as String,
        articleIds: (json['article_ids'] as List?)?.cast<String>() ?? [],
        videoIds: (json['video_ids'] as List?)?.cast<String>() ?? [],
      );
}
