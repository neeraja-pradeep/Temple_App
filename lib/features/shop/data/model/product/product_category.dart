import 'package:hive/hive.dart';
part 'product_category.g.dart';

@HiveType(typeId: 6) // must be unique across all models
class CategoryProductModel extends HiveObject {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String slug;

  @HiveField(3)
  final String? description; //  made nullable (API might return null)

  @HiveField(4)
  final CategoryModel category;

  @HiveField(5)
  final List<VariantModel> variants;

  CategoryProductModel({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    required this.category,
    required this.variants,
  });

  factory CategoryProductModel.fromJson(Map<String, dynamic> json) {
    return CategoryProductModel(
      id: json['id'] ?? 0,
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      description: json['description']?.toString(),
      category: CategoryModel.fromJson(json['category'] ?? {}),
      variants: (json['variants'] as List? ?? [])
          .map((v) => VariantModel.fromJson(v))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "slug": slug,
      "description": description,
      "category": category.toJson(),
      "variants": variants.map((v) => v.toJson()).toList(),
    };
  }
}

@HiveType(typeId: 7)
class CategoryModel extends HiveObject {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String? parent;

  @HiveField(3)
  final String? mediaUrl; // nullable

  @HiveField(4)
  final String? mediaPublicId; //  nullable

  @HiveField(5)
  final List<dynamic> children;

  CategoryModel({
    required this.id,
    required this.name,
    this.parent,
    this.mediaUrl,
    this.mediaPublicId,
    required this.children,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] ?? 0,
      name: json['name']?.toString() ?? '',
      parent: json['parent']?.toString(),
      mediaUrl: json['media_url']?.toString(), //  null-safe
      mediaPublicId: json['media_public_id']?.toString(),
      children: json['children'] ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "parent": parent,
      "media_url": mediaUrl,
      "media_public_id": mediaPublicId,
      "children": children,
    };
  }
}

@HiveType(typeId: 8)
class VariantModel extends HiveObject {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final int product;

  @HiveField(2)
  final String productName;

  @HiveField(3)
  final String sku;

  @HiveField(4)
  final String name;

  @HiveField(5)
  final String price;

  @HiveField(6)
  final String? mediaUrl; //  nullable

  @HiveField(7)
  final int stock;

  VariantModel({
    required this.id,
    required this.product,
    required this.productName,
    required this.sku,
    required this.name,
    required this.price,
    this.mediaUrl,
    required this.stock,
  });

  factory VariantModel.fromJson(Map<String, dynamic> json) {
    return VariantModel(
      id: json['id'] ?? 0,
      product: json['product'] ?? 0,
      productName: json['product_name']?.toString() ?? '',
      sku: json['sku']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      price: json['price']?.toString() ?? '0',
      mediaUrl: json['media_url']?.toString(), // handles null correctly
      stock: json['stock'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "product": product,
      "product_name": productName,
      "sku": sku,
      "name": name,
      "price": price,
      "media_url": mediaUrl,
      "stock": stock,
    };
  }
}
