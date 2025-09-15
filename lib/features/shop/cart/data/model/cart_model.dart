import 'package:hive/hive.dart';



@HiveType(typeId: 10) // must be unique across your app
class CartItem extends HiveObject {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String productVariantId;

  @HiveField(2)
  final String name;

  @HiveField(3)
  final String sku;

  @HiveField(4)
  final String price;

  @HiveField(5)
  final int quantity;

  @HiveField(6)
  final String productimage;

  CartItem({
    required this.id,
    required this.productVariantId,
    required this.name,
    required this.sku,
    required this.price,
    required this.quantity,
    required this.productimage,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'],
      productVariantId: json['product_variant']['id'].toString(),
      name: json['product_variant']['name'],
      sku: json['product_variant']['sku'],
      price: json['product_variant']['price'],
      quantity: json['quantity'],
      productimage: json['product_image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "product_variant_id": productVariantId,
      "name": name,
      "sku": sku,
      "price": price,
      "quantity": quantity,
      "product_image": productimage,
    };
  }
}
