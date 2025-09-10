class CartItem {
  final int productVariantId;
  final int quantity;

  CartItem({required this.productVariantId, required this.quantity});

  Map<String, dynamic> toJson() {
    return {
      'product_variant_id': productVariantId.toString(),
      'quantity': quantity,
    };
  }
}

class AddToCartRequest {
  final int productVariantId;
  final int quantity;

  AddToCartRequest({required this.productVariantId, required this.quantity});

  Map<String, dynamic> toJson() {
    return {
      'product_variant_id': productVariantId.toString(),
      'quantity': quantity,
    };
  }
}
