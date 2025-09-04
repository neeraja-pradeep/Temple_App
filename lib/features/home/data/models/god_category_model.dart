class GodCategory {
  final int id;
  final String name;
  final String? homemediaUrl;
  final bool isActive;

  GodCategory({
    required this.id,
    required this.name,
    required this.homemediaUrl,
    required this.isActive,
  });

  factory GodCategory.fromJson(Map<String, dynamic> json) {
    return GodCategory(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      homemediaUrl: json['home_media_url'],
      isActive: json['is_active'] ?? false,
    );
  }

}
