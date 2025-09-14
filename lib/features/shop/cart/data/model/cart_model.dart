class CartItem {
  final int id;
  final String productVariantId;
  final String name;
  final String sku;
  final String price;
  final int quantity;

  CartItem({
    required this.id,
    required this.productVariantId,
    required this.name,
    required this.sku,
    required this.price,
    required this.quantity,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'],
      productVariantId: json['product_variant']['id'].toString(),
      name: json['product_variant']['name'],
      sku: json['product_variant']['sku'],
      price: json['product_variant']['price'],
      quantity: json['quantity'],
    );
  }
}
