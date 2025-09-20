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
  final String description;

  @HiveField(4)
  final CategoryModel category;

  @HiveField(5)
  final List<VariantModel> variants;

  CategoryProductModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    required this.category,
    required this.variants,
  });

  factory CategoryProductModel.fromJson(Map<String, dynamic> json) {
    return CategoryProductModel(
      id: json['id'],
      name: json['name'],
      slug: json['slug'],
      description: json['description'],
      category: CategoryModel.fromJson(json['category']),
      variants: (json['variants'] as List)
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
  final String mediaUrl;

  @HiveField(4)
  final String mediaPublicId;

  @HiveField(5)
  final List<dynamic> children;

  CategoryModel({
    required this.id,
    required this.name,
    required this.parent,
    required this.mediaUrl,
    required this.mediaPublicId,
    required this.children,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'],
      name: json['name'],
      parent: json['parent'],
      mediaUrl: json['media_url'],
      mediaPublicId: json['media_public_id'],
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
  final String mediaUrl;

  @HiveField(7)
  final int stock;

  VariantModel({
    required this.id,
    required this.product,
    required this.productName,
    required this.sku,
    required this.name,
    required this.price,
    required this.mediaUrl,
    required this.stock,
  });

  factory VariantModel.fromJson(Map<String, dynamic> json) {
    return VariantModel(
      id: json['id'],
      product: json['product'],
      productName: json['product_name'],
      sku: json['sku'],
      name: json['name'],
      price: json['price'],
      mediaUrl: json['media_url'],
      stock: json['stock'],
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
