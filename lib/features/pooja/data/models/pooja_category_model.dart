import 'package:hive/hive.dart';
part 'pooja_category_model.g.dart';

@HiveType(typeId: 2)
class PoojaCategory extends HiveObject {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final int? parent;

  @HiveField(3)
  final String mediaUrl;

  @HiveField(4)
  final List<PoojaCategory> children;

  @HiveField(5)
  final bool isActive;

  PoojaCategory({
    required this.id,
    required this.name,
    required this.parent,
    required this.mediaUrl,
    required this.children,
    required this.isActive,
  });

  factory PoojaCategory.fromJson(Map<String, dynamic> json) {
    return PoojaCategory(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      parent: json['parent'],
      mediaUrl: json['media_url'] ?? '',
      children: (json['children'] as List<dynamic>?)
              ?.map((child) => PoojaCategory.fromJson(child))
              .toList() ??
          [],
      isActive: json['is_active'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'parent': parent,
      'media_url': mediaUrl,
      'children': children.map((c) => c.toJson()).toList(),
      'is_active': isActive,
    };
  }
}
