/// Central source for every backend endpoint used by the app.
class ApiConstants {
  ApiConstants._();

  /// Root of the REST API.
  static const String base = 'http://templerun.click/api';

  /// Legacy alias maintained for backward compatibility.
  static const String baseUrl = base;

  /// Booking module base.
  static const String bookingBase = '$base/booking';

  /// Ecommerce module base.
  static const String ecommerceBase = '$base/ecommerce';

  // ----------------------------- Booking ---------------------------------- //

  static const String globalUpdate = '$bookingBase/global-update/';
  static const String globalUpdateDetails =
      '$bookingBase/global-update-details/';
  static const String poojaList = '$bookingBase/pooja/list/';
  static const String poojaCategories = '$bookingBase/pooja/categories/';

  // ---------------------------- Ecommerce --------------------------------- //

  static const String shopProducts = '$ecommerceBase/shop-products/';
  static const String storeCategories = '$ecommerceBase/category/';

  static const String cart = '$ecommerceBase/cart/';
  static const String cartRemove = '$ecommerceBase/cart/remove/';
  static const String checkout = '$ecommerceBase/checkout/';
  static const String pay = '$ecommerceBase/pay/';
  static const String orders = '$ecommerceBase/orders/';
  static const String addresses = '$ecommerceBase/address/';

  // ---------------------------- Home Screen -------------------------------- //
  static const String profile = '$baseUrl/user/profile/';
  static String song(int songId) => '$baseUrl/song/songs/$songId/';
  static const String godCategories = '$bookingBase/poojacategory/';

  /// Details for a specific cart item.
  static String cartItem(int cartId) => '$cart$cartId/';

  /// Products scoped to a specific category.
  static String shopProductsByCategory(int categoryId) =>
      '$shopProducts?category=$categoryId';

  /// Details for a specific order.
  static String orderById(dynamic orderId) => '$orders$orderId';

  /// Address resource by identifier.
  static String addressById(dynamic addressId) => '$addresses$addressId/';
}
