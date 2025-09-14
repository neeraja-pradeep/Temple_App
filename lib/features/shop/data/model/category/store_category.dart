class StoreCategory {
  final int id;
  final String name;
  final String mediaUrl;

  StoreCategory({
    required this.id,
    required this.name,
    required this.mediaUrl,
  });

  factory StoreCategory.fromJson(Map<String, dynamic> json) {
    return StoreCategory(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      mediaUrl: json['media_url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'media_url': mediaUrl,
    };
  }
}
