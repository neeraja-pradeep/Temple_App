class CheckoutResponse {
  final int orderId;
  final String razorpayOrderId;
  final int amount;
  final String currency;
  final String key;

  CheckoutResponse({
    required this.orderId,
    required this.razorpayOrderId,
    required this.amount,
    required this.currency,
    required this.key,
  });

  factory CheckoutResponse.fromJson(Map<String, dynamic> json) {
    return CheckoutResponse(
      orderId: json['order_id'] ?? 0,
      razorpayOrderId: json['razorpay_order_id'] ?? '',
      amount: json['amount'] ?? 0,
      currency: json['currency'] ?? 'INR',
      key: json['key'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'order_id': orderId,
      'razorpay_order_id': razorpayOrderId,
      'amount': amount,
      'currency': currency,
      'key': key,
    };
  }
}
