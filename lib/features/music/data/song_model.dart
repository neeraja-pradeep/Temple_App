class SongItem {
  final int id;
  final String title;
  final String artist;
  final String streamUrl;
  final String duration;
  final String uploadedAt;
  final String? media;
  final String? homeMedia;

  SongItem({
    required this.id,
    required this.title,
    required this.artist,
    required this.streamUrl,
    required this.duration,
    required this.uploadedAt,
    this.media,
    this.homeMedia,
  });

  factory SongItem.fromJson(Map<String, dynamic> json) {
    final songData = json['song'] ?? json;

    // Helper function to add https:// protocol if missing
    String? _addProtocol(String? url) {
      if (url == null || url.isEmpty) return url;
      if (url.startsWith('http://') || url.startsWith('https://')) {
        return url;
      }
      final fixedUrl = 'https://$url';
      print('=== FIXING IMAGE URL ===');
      print('Original: $url');
      print('Fixed: $fixedUrl');
      print('=== END URL FIX ===');
      return fixedUrl;
    }

    return SongItem(
      id: songData['id'],
      title: songData['title'],
      artist: songData['artist'],
      streamUrl: songData['stream_url'],
      duration: songData['duration'],
      uploadedAt: songData['uploaded_at'],
      media: _addProtocol(songData['media']),
      homeMedia: _addProtocol(songData['home_media']),
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "artist": artist,
    "stream_url": streamUrl,
    "duration": duration,
    "uploaded_at": uploadedAt,
    "media": media,
    "home_media": homeMedia,
  };
}
