import 'package:hive/hive.dart';

part 'store_category.g.dart';

@HiveType(typeId: 9) // ensure unique typeId across all Hive models
class StoreCategory extends HiveObject {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String name;

  @HiveField(2)
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
