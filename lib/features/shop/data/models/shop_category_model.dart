import 'dart:convert';

class ShopCategory {
  final int id;
  final String name;
  final int? parent;
  final String? mediaUrl;
  final String? mediaPublicId;
  final List<ShopCategory> children;

  ShopCategory({
    required this.id,
    required this.name,
    this.parent,
    this.mediaUrl,
    this.mediaPublicId,
    this.children = const [],
  });

  factory ShopCategory.fromJson(Map<String, dynamic> json) {
    return ShopCategory(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      parent: json['parent'] as int?,
      mediaUrl: json['media_url'] as String?,
      mediaPublicId: json['media_public_id'] as String?,
      children: (json['children'] as List<dynamic>? ?? [])
          .map((e) => ShopCategory.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  static List<ShopCategory> listFromJsonString(String body) {
    final List<dynamic> data = jsonDecode(body) as List<dynamic>;
    return data
        .map((e) => ShopCategory.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
