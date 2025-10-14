import 'package:hive/hive.dart';

part 'booking_model.g.dart';

@HiveType(typeId: 20)
class Booking extends HiveObject {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final int user;

  @HiveField(2)
  final UserDetails? userDetails;

  @HiveField(3)
  final String? status;

  @HiveField(4)
  final String? statusDisplay;

  @HiveField(5)
  final String? total;

  @HiveField(6)
  final String? razorpayOrderId;

  @HiveField(7)
  final String? razorpayPaymentId;

  @HiveField(8)
  final String? refundAmount;

  @HiveField(9)
  final String? refundStatus;

  @HiveField(10)
  final String? refundStatusDisplay;

  @HiveField(11)
  final String? razorpayRefundId;

  @HiveField(12)
  final String? refundReason;

  @HiveField(13)
  final String? createdAt;

  @HiveField(14)
  final String? modifiedAt;

  @HiveField(15)
  final List<OrderLine> orderLines;

  Booking({
    required this.id,
    required this.user,
    this.userDetails,
    this.status,
    this.statusDisplay,
    this.total,
    this.razorpayOrderId,
    this.razorpayPaymentId,
    this.refundAmount,
    this.refundStatus,
    this.refundStatusDisplay,
    this.razorpayRefundId,
    this.refundReason,
    this.createdAt,
    this.modifiedAt,
    required this.orderLines,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] ?? 0,
      user: json['user'] ?? 0,
      userDetails: json['user_details'] != null
          ? UserDetails.fromJson(json['user_details'])
          : null,
      status: json['status'] ?? '',
      statusDisplay: json['status_display'] ?? '',
      total: json['total'] ?? '0',
      razorpayOrderId: json['razorpay_order_id'] ?? '',
      razorpayPaymentId: json['razorpay_payment_id'],
      refundAmount: json['refund_amount'] ?? '0',
      refundStatus: json['refund_status'] ?? '',
      refundStatusDisplay: json['refund_status_display'] ?? '',
      razorpayRefundId: json['razorpay_refund_id'],
      refundReason: json['refund_reason'],
      createdAt: json['created_at'],
      modifiedAt: json['modified_at'],
      orderLines: (json['order_lines'] as List? ?? [])
          .map((e) => OrderLine.fromJson(e))
          .toList(),
    );
  }
}

@HiveType(typeId: 21)
class UserDetails extends HiveObject {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String? email;

  @HiveField(2)
  final String? phoneNumber;

  @HiveField(3)
  final String? firstName;

  @HiveField(4)
  final String? lastName;

  UserDetails({
    required this.id,
    this.email,
    this.phoneNumber,
    this.firstName,
    this.lastName,
  });

  factory UserDetails.fromJson(Map<String, dynamic> json) {
    return UserDetails(
      id: json['id'] ?? 0,
      email: json['email'],
      phoneNumber: json['phone_number'],
      firstName: json['first_name'],
      lastName: json['last_name'],
    );
  }
}

@HiveType(typeId: 22)
class OrderLine extends HiveObject {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final int pooja;

  @HiveField(2)
  final PoojaDetails? poojaDetails;

  @HiveField(3)
  final int? specialPoojaDate;

  @HiveField(4)
  final SpecialPoojaDateDetails? specialPoojaDateDetails;

  @HiveField(5)
  final String? selectedDate;

  @HiveField(6)
  final int userList;

  @HiveField(7)
  final UserListDetails? userListDetails;

  @HiveField(8)
  final int userAttribute;

  @HiveField(9)
  final UserAttributeDetails? userAttributeDetails;

  @HiveField(10)
  final String? price;

  @HiveField(11)
  final String? effectivePrice;

  @HiveField(12)
  final String? status;

  @HiveField(13)
  final String? statusDisplay;

  @HiveField(14)
  final String? poojaStatus;

  @HiveField(15)
  final String? poojaStatusDisplay;

  @HiveField(16)
  final bool? isCancelled;

  @HiveField(17)
  final List<String> selectedDates;

  OrderLine({
    required this.id,
    required this.pooja,
    this.poojaDetails,
    this.specialPoojaDate,
    this.specialPoojaDateDetails,
    this.selectedDate,
    required this.userList,
    this.userListDetails,
    required this.userAttribute,
    this.userAttributeDetails,
    this.price,
    this.effectivePrice,
    this.status,
    this.statusDisplay,
    this.poojaStatus,
    this.poojaStatusDisplay,
    this.isCancelled,
    this.selectedDates = const [],
  });

  factory OrderLine.fromJson(Map<String, dynamic> json) {
    final selectedDates = (json['selected_dates'] as List? ?? [])
        .map((e) => e.toString())
        .toList();
    return OrderLine(
      id: json['id'] ?? 0,
      pooja: json['pooja'] ?? 0,
      poojaDetails: json['pooja_details'] != null
          ? PoojaDetails.fromJson(json['pooja_details'])
          : null,
      specialPoojaDate: json['special_pooja_date'],
      specialPoojaDateDetails: json['special_pooja_date_details'] != null
          ? SpecialPoojaDateDetails.fromJson(json['special_pooja_date_details'])
          : null,
      selectedDates: selectedDates,
      selectedDate:
          json['selected_date'] ?? (selectedDates.isNotEmpty ? selectedDates.first : null),
      userList: json['user_list'] ?? 0,
      userListDetails: json['user_list_details'] != null
          ? UserListDetails.fromJson(json['user_list_details'])
          : null,
      userAttribute: json['user_attribute'] ?? 0,
      userAttributeDetails: json['user_attribute_details'] != null
          ? UserAttributeDetails.fromJson(json['user_attribute_details'])
          : null,
      price: json['price'],
      effectivePrice: json['effective_price'],
      status: json['status'],
      statusDisplay: json['status_display'],
      poojaStatus: json['pooja_status'],
      poojaStatusDisplay: json['pooja_status_display'],
      isCancelled: json['is_cancelled'] ?? false,
    );
  }
}

// Repeat HiveType/Field for nested classes
@HiveType(typeId: 23)
class PoojaDetails extends HiveObject {
  @HiveField(0)
  final int id;
  @HiveField(1)
  final String? name;
  @HiveField(2)
  final int? category;
  @HiveField(3)
  final String? categoryName;
  @HiveField(4)
  final String? price;
  @HiveField(5)
  final bool? status;
  @HiveField(6)
  final bool? specialPooja;
  @HiveField(7)
  final List<SpecialPoojaDateDetails> specialPoojaDates;
  @HiveField(8)
  final String? mediaUrl;
  @HiveField(9)
  final String? bannerUrl;

  PoojaDetails({
    required this.id,
    this.name,
    this.category,
    this.categoryName,
    this.price,
    this.status,
    this.specialPooja,
    this.specialPoojaDates = const [],
    this.mediaUrl,
    this.bannerUrl,
  });

  factory PoojaDetails.fromJson(Map<String, dynamic> json) {
    return PoojaDetails(
      id: json['id'] ?? 0,
      name: json['name'],
      category: json['category'],
      categoryName: json['category_name'],
      price: json['price'],
      status: json['status'],
      specialPooja: json['special_pooja'],
      specialPoojaDates: (json['special_pooja_dates'] as List? ?? [])
          .map((e) => SpecialPoojaDateDetails.fromJson(e))
          .toList(),
      mediaUrl: json['media_url'],
      bannerUrl: json['banner_url'],
    );
  }
}

@HiveType(typeId: 24)
class SpecialPoojaDateDetails extends HiveObject {
  @HiveField(0)
  final int id;
  @HiveField(1)
  final int? pooja;
  @HiveField(2)
  final String? poojaName;
  @HiveField(3)
  final String? date;
  @HiveField(4)
  final String? malayalamDate;
  @HiveField(5)
  final String? time;
  @HiveField(6)
  final String? price;
  @HiveField(7)
  final bool? status;
  @HiveField(8)
  final bool? banner;
  @HiveField(9)
  final String? createdAt;
  @HiveField(10)
  final String? modifiedAt;
  @HiveField(11)
  final int? linkedOrdersCount;

  SpecialPoojaDateDetails({
    required this.id,
    this.pooja,
    this.poojaName,
    this.date,
    this.malayalamDate,
    this.time,
    this.price,
    this.status,
    this.banner,
    this.createdAt,
    this.modifiedAt,
    this.linkedOrdersCount,
  });

  factory SpecialPoojaDateDetails.fromJson(Map<String, dynamic> json) {
    return SpecialPoojaDateDetails(
      id: json['id'] ?? 0,
      pooja: json['pooja'],
      poojaName: json['pooja_name'],
      date: json['date'],
      malayalamDate: json['malayalam_date'],
      time: json['time'],
      price: json['price'],
      status: json['status'],
      banner: json['banner'],
      createdAt: json['created_at'],
      modifiedAt: json['modified_at'],
      linkedOrdersCount: json['linked_orders_count'],
    );
  }
}

@HiveType(typeId: 25)
class UserListDetails extends HiveObject {
  @HiveField(0)
  final int id;
  @HiveField(1)
  final String? name;
  @HiveField(2)
  final int? user;
  @HiveField(3)
  final List<UserAttributeDetails> attributes;

  UserListDetails({
    required this.id,
    this.name,
    this.user,
    this.attributes = const [],
  });

  factory UserListDetails.fromJson(Map<String, dynamic> json) {
    return UserListDetails(
      id: json['id'] ?? 0,
      name: json['name'],
      user: json['user'],
      attributes: (json['attributes'] as List? ?? [])
          .map((e) => UserAttributeDetails.fromJson(e))
          .toList(),
    );
  }
}

@HiveType(typeId: 26)
class UserAttributeDetails extends HiveObject {
  @HiveField(0)
  final int id;
  @HiveField(1)
  final int? nakshatram;
  @HiveField(2)
  final String? nakshatramName;

  UserAttributeDetails({
    required this.id,
    this.nakshatram,
    this.nakshatramName,
  });

  factory UserAttributeDetails.fromJson(Map<String, dynamic> json) {
    return UserAttributeDetails(
      id: json['id'] ?? 0,
      nakshatram: json['nakshatram'],
      nakshatramName: json['nakshatram_name'],
    );
  }
}
