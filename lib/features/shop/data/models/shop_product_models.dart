import 'dart:convert';

class ProductVariant {
  final int id;
  final int productId;
  final String productName;
  final String name;
  final String price;
  final String? mediaUrl;
  final int stock;

  ProductVariant({
    required this.id,
    required this.productId,
    required this.productName,
    required this.name,
    required this.price,
    required this.stock,
    this.mediaUrl,
  });

  factory ProductVariant.fromJson(Map<String, dynamic> json) {
    return ProductVariant(
      id: json['id'] as int,
      productId: json['product'] as int,
      productName: json['product_name'] as String? ?? '',
      name: json['name'] as String? ?? '',
      price: json['price']?.toString() ?? '0',
      mediaUrl: json['media_url'] as String?,
      stock: json['stock'] as int? ?? 0,
    );
  }
}

class ShopProduct {
  final int id;
  final String name;
  final String slug;
  final String? description;
  final String? categoryName;
  final List<ProductVariant> variants;

  ShopProduct({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    this.categoryName,
    required this.variants,
  });

  factory ShopProduct.fromJson(Map<String, dynamic> json) {
    return ShopProduct(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      description: json['description'] as String?,
      categoryName:
          (json['category'] as Map<String, dynamic>?)?['name'] as String?,
      variants: (json['variants'] as List<dynamic>? ?? [])
          .map((e) => ProductVariant.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  static List<ShopProduct> listFromJsonString(String body) {
    final List<dynamic> data = jsonDecode(body) as List<dynamic>;
    return data
        .map((e) => ShopProduct.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
