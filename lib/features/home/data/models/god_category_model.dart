import 'package:hive/hive.dart';

part 'god_category_model.g.dart';

@HiveType(typeId: 12)
class GodCategory extends HiveObject {
  @HiveField(0)
  final int id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String? homemediaUrl;
  @HiveField(3)
  final bool isActive;

  GodCategory({
    required this.id,
    required this.name,
    required this.homemediaUrl,
    required this.isActive,
  });

  factory GodCategory.fromJson(Map<String, dynamic> json) => GodCategory(
        id: json['id'] ?? 0,
        name: json['name'] ?? '',
        homemediaUrl: json['home_media_url'],
        isActive: json['is_active'] ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'home_media_url': homemediaUrl,
        'is_active': isActive,
      };
}
