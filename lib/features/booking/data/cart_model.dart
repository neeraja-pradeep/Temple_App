class CartResponse {
  final List<CartItem> cart;

  CartResponse({required this.cart});

  factory CartResponse.fromJson(Map<String, dynamic> json) {
    return CartResponse(
      cart: (json['cart'] as List<dynamic>)
          .map((item) => CartItem.fromJson(item))
          .toList(),
    );
  }
}

class CartItem {
  final int id;
  final int pooja;
  final PoojaDetails poojaDetails;
  final int? specialPoojaDate;
  final SpecialPoojaDateDetails? specialPoojaDateDetails;
  final String? selectedDate;
  final int userList;
  final UserListDetails userListDetails;
  final String effectivePrice;
  final String additionalCharges;
  final bool status;
  final int? agent;
  final Map<String, dynamic>? agentDetails;

  CartItem({
    required this.id,
    required this.pooja,
    required this.poojaDetails,
    this.specialPoojaDate,
    this.specialPoojaDateDetails,
    this.selectedDate,
    required this.userList,
    required this.userListDetails,
    required this.effectivePrice,
    required this.additionalCharges,
    required this.status,
    this.agent,
    this.agentDetails,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] ?? 0,
      pooja: json['pooja'] ?? 0,
      poojaDetails: PoojaDetails.fromJson(json['pooja_details'] ?? {}),
      specialPoojaDate: json['special_pooja_date'],
      specialPoojaDateDetails: json['special_pooja_date_details'] != null
          ? SpecialPoojaDateDetails.fromJson(json['special_pooja_date_details'])
          : null,
      selectedDate: json['selected_date'],
      userList: json['user_list'] ?? 0,
      userListDetails: UserListDetails.fromJson(
        json['user_list_details'] ?? {},
      ),
      effectivePrice: json['effective_price'] ?? '0.00',
      additionalCharges: json['additional_charges'] ?? '0.00',
      status: json['status'] ?? false,
      agent: json['agent'],
      agentDetails: json['agent_details'],
    );
  }
}

class PoojaDetails {
  final int id;
  final String name;
  final int category;
  final String categoryName;
  final String price;
  final bool status;
  final String bannerDesc;
  final String cardDesc;
  final String captionsDesc;
  final bool specialPooja;
  final List<SpecialPoojaDate> specialPoojaDates;
  final String mediaUrl;
  final String bannerUrl;

  PoojaDetails({
    required this.id,
    required this.name,
    required this.category,
    required this.categoryName,
    required this.price,
    required this.status,
    required this.bannerDesc,
    required this.cardDesc,
    required this.captionsDesc,
    required this.specialPooja,
    required this.specialPoojaDates,
    required this.mediaUrl,
    required this.bannerUrl,
  });

  factory PoojaDetails.fromJson(Map<String, dynamic> json) {
    return PoojaDetails(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      category: json['category'] ?? 0,
      categoryName: json['category_name'] ?? '',
      price: json['price'] ?? '0.00',
      status: json['status'] ?? false,
      bannerDesc: json['banner_desc'] ?? '',
      cardDesc: json['card_desc'] ?? '',
      captionsDesc: json['captions_desc'] ?? '',
      specialPooja: json['special_pooja'] ?? false,
      specialPoojaDates:
          (json['special_pooja_dates'] as List<dynamic>?)
              ?.map((date) => SpecialPoojaDate.fromJson(date))
              .toList() ??
          [],
      mediaUrl: json['media_url'] ?? '',
      bannerUrl: json['banner_url'] ?? '',
    );
  }
}

class SpecialPoojaDate {
  final int id;
  final int pooja;
  final String poojaName;
  final String date;
  final String malayalamDate;
  final String? time;
  final String price;
  final bool status;
  final bool banner;
  final String createdAt;
  final String modifiedAt;
  final int linkedOrdersCount;

  SpecialPoojaDate({
    required this.id,
    required this.pooja,
    required this.poojaName,
    required this.date,
    required this.malayalamDate,
    this.time,
    required this.price,
    required this.status,
    required this.banner,
    required this.createdAt,
    required this.modifiedAt,
    required this.linkedOrdersCount,
  });

  factory SpecialPoojaDate.fromJson(Map<String, dynamic> json) {
    return SpecialPoojaDate(
      id: json['id'] ?? 0,
      pooja: json['pooja'] ?? 0,
      poojaName: json['pooja_name'] ?? '',
      date: json['date'] ?? '',
      malayalamDate: json['malayalam_date'] ?? '',
      time: json['time'],
      price: json['price'] ?? '0.00',
      status: json['status'] ?? false,
      banner: json['banner'] ?? false,
      createdAt: json['created_at'] ?? '',
      modifiedAt: json['modified_at'] ?? '',
      linkedOrdersCount: json['linked_orders_count'] ?? 0,
    );
  }
}

class SpecialPoojaDateDetails {
  final int id;
  final int pooja;
  final String poojaName;
  final String date;
  final String malayalamDate;
  final String? time;
  final String price;
  final bool status;
  final bool banner;
  final String createdAt;
  final String modifiedAt;
  final int linkedOrdersCount;

  SpecialPoojaDateDetails({
    required this.id,
    required this.pooja,
    required this.poojaName,
    required this.date,
    required this.malayalamDate,
    this.time,
    required this.price,
    required this.status,
    required this.banner,
    required this.createdAt,
    required this.modifiedAt,
    required this.linkedOrdersCount,
  });

  factory SpecialPoojaDateDetails.fromJson(Map<String, dynamic> json) {
    return SpecialPoojaDateDetails(
      id: json['id'] ?? 0,
      pooja: json['pooja'] ?? 0,
      poojaName: json['pooja_name'] ?? '',
      date: json['date'] ?? '',
      malayalamDate: json['malayalam_date'] ?? '',
      time: json['time'],
      price: json['price'] ?? '0.00',
      status: json['status'] ?? false,
      banner: json['banner'] ?? false,
      createdAt: json['created_at'] ?? '',
      modifiedAt: json['modified_at'] ?? '',
      linkedOrdersCount: json['linked_orders_count'] ?? 0,
    );
  }
}

class UserListDetails {
  final int id;
  final String name;
  final int user;
  final List<UserAttribute> attributes;

  UserListDetails({
    required this.id,
    required this.name,
    required this.user,
    required this.attributes,
  });

  factory UserListDetails.fromJson(Map<String, dynamic> json) {
    return UserListDetails(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      user: json['user'] ?? 0,
      attributes:
          (json['attributes'] as List<dynamic>?)
              ?.map((attr) => UserAttribute.fromJson(attr))
              .toList() ??
          [],
    );
  }
}

class UserAttribute {
  final int id;
  final int userList;
  final int nakshatram;
  final String nakshatramName;

  UserAttribute({
    required this.id,
    required this.userList,
    required this.nakshatram,
    required this.nakshatramName,
  });

  factory UserAttribute.fromJson(Map<String, dynamic> json) {
    return UserAttribute(
      id: json['id'] ?? 0,
      userList: json['user_list'] ?? 0,
      nakshatram: json['nakshatram'] ?? 0,
      nakshatramName: json['nakshatram_name'] ?? '',
    );
  }
}
