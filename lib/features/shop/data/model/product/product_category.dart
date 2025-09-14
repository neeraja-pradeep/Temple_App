class CategoryProductModel {
  final int id;
  final String name;
  final String slug;
  final String description;
  final CategoryModel category;
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

class CategoryModel {
  final int id;
  final String name;
  final String? parent;
  final String mediaUrl;
  final String mediaPublicId;
  final List<dynamic> children; // can later change to List<CategoryModel> if nested

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

class VariantModel {
  final int id;
  final int product;
  final String productName;
  final String sku;
  final String name;
  final String price;
  final String mediaUrl;
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
