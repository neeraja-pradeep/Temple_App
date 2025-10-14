import 'package:hive_flutter/hive_flutter.dart';

part 'song_model.g.dart';

@HiveType(typeId: 13)
class Song {
  @HiveField(0)
  final int id;
  @HiveField(1)
  final String title;
  @HiveField(2)
  final String artist;
  @HiveField(3)
  final String streamUrl;
  @HiveField(4)
  final String uploadedAt;

  Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.streamUrl,
    required this.uploadedAt,
  });

  factory Song.fromJson(Map<String, dynamic> json) {
    final songData = json['song'] ?? json;
    return Song(
      id: songData['id'],
      title: songData['title'],
      artist: songData['artist'],
      streamUrl: songData['stream_url'],
      uploadedAt: songData['uploaded_at'],
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "artist": artist,
        "stream_url": streamUrl,
        "uploaded_at": uploadedAt,
      };
}
