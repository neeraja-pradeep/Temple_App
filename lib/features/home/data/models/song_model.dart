class SongModel {
  final int id;
  final String title;
  final String artist;
  final String streamUrl;
  final String uploadedAt;
  final String media;
  final String homeMedia;

  SongModel({
    required this.id,
    required this.title,
    required this.artist,
    required this.streamUrl,
    required this.uploadedAt,
    required this.media,
    required this.homeMedia,
  });

  factory SongModel.fromJson(Map<String, dynamic> json) {
    return SongModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      artist: json['artist'] ?? '',
      streamUrl: json['stream_url'] ?? '',
      uploadedAt: json['uploaded_at'] ?? '',
      media: json['media'] ?? '',
      homeMedia: json['home_media'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'stream_url': streamUrl,
      'uploaded_at': uploadedAt,
      'media': media,
      'home_media': homeMedia,
    };
  }
}

class SongResponse {
  final SongModel song;

  SongResponse({required this.song});

  factory SongResponse.fromJson(Map<String, dynamic> json) {
    return SongResponse(song: SongModel.fromJson(json['song'] ?? {}));
  }

  Map<String, dynamic> toJson() {
    return {'song': song.toJson()};
  }
}
