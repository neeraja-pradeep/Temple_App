class Booking {
  final int id;
  final int user;
  final UserDetails? userDetails;
  final String? status;
  final String? statusDisplay;
  final String? total;
  final String? razorpayOrderId;
  final String? razorpayPaymentId;
  final String? refundAmount;
  final String? refundStatus;
  final String? refundStatusDisplay;
  final String? razorpayRefundId;
  final String? refundReason;
  final String? createdAt;
  final String? modifiedAt;
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

class UserDetails {
  final int id;
  final String? email;
  final String? phoneNumber;
  final String? firstName;
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

class OrderLine {
  final int id;
  final int pooja;
  final PoojaDetails? poojaDetails;
  final int? specialPoojaDate;
  final SpecialPoojaDateDetails? specialPoojaDateDetails;
  final String? selectedDate;
  final int userList;
  final UserListDetails? userListDetails;
  final int userAttribute;
  final UserAttributeDetails? userAttributeDetails;
  final String? price;
  final String? effectivePrice;
  final String? status;
  final String? statusDisplay;
  final String? poojaStatus;
  final String? poojaStatusDisplay;
  final bool? isCancelled;

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
  });

  factory OrderLine.fromJson(Map<String, dynamic> json) {
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
      selectedDate: json['selected_date'],
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

class PoojaDetails {
  final int id;
  final String? name;
  final int? category;
  final String? categoryName;
  final String? price;
  final bool? status;
  final bool? specialPooja;
  final List<SpecialPoojaDateDetails> specialPoojaDates;
  final String? mediaUrl;
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

class SpecialPoojaDateDetails {
  final int id;
  final int? pooja;
  final String? poojaName;
  final String? date;
  final String? malayalamDate;
  final String? time;
  final String? price;
  final bool? status;
  final bool? banner;
  final String? createdAt;
  final String? modifiedAt;
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

class UserListDetails {
  final int id;
  final String? name;
  final int? user;
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

class UserAttributeDetails {
  final int id;
  final int? nakshatram;
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
