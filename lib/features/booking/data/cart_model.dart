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
  final List<String> selectedDates;
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
    this.selectedDates = const [],
    required this.userList,
    required this.userListDetails,
    required this.effectivePrice,
    required this.additionalCharges,
    required this.status,
    this.agent,
    this.agentDetails,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    final dynamic rawSelectedDates = json['selected_dates'];
    List<String> selectedDates = const [];
    if (rawSelectedDates is List) {
      selectedDates = rawSelectedDates.map((e) => e.toString()).toList();
    } else if (rawSelectedDates is String) {
      selectedDates = [rawSelectedDates];
    }

    String? selectedDate = json['selected_date'];
    if (selectedDate == null && selectedDates.isNotEmpty) {
      selectedDate = selectedDates.first;
    }

    final poojaRaw = json['pooja_details'] ?? json['pooja'];
    final poojaId = _extractInt(json['pooja'], fallback: _extractInt(poojaRaw));

    final userListRaw = json['user_list_details'] ?? json['user_list'];
    final userListId = _extractInt(
      json['user_list'],
      fallback: _extractInt(userListRaw),
    );

    final specialDateDetailsRaw =
        json['special_pooja_date_details'] ?? json['selected_special_date'];

    return CartItem(
      id: _extractInt(json['id']),
      pooja: poojaId,
      poojaDetails: PoojaDetails.fromJson(_normalizePoojaDetails(poojaRaw)),
      specialPoojaDate: _extractNullableInt(json['special_pooja_date']),
      specialPoojaDateDetails: specialDateDetailsRaw != null
          ? SpecialPoojaDateDetails.fromJson(_ensureMap(specialDateDetailsRaw))
          : null,
      selectedDate: selectedDate,
      selectedDates: selectedDates,
      userList: userListId,
      userListDetails: UserListDetails.fromJson(
        _normalizeUserList(userListRaw, json['user_attribute']),
      ),
      effectivePrice: _extractString(json['effective_price'], fallback: '0.00'),
      additionalCharges: _extractString(
        json['additional_charges'],
        fallback: '0.00',
      ),
      status: _extractBool(json['status']),
      agent: _extractNullableInt(json['agent']),
      agentDetails: json['agent_details'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(json['agent_details'])
          : null,
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
    if (json.isEmpty) {
      return PoojaDetails(
        id: 0,
        name: '',
        category: 0,
        categoryName: '',
        price: '0.00',
        status: false,
        bannerDesc: '',
        cardDesc: '',
        captionsDesc: '',
        specialPooja: false,
        specialPoojaDates: const [],
        mediaUrl: '',
        bannerUrl: '',
      );
    }

    final categoryData = json['category'];
    final categoryId = _extractInt(
      categoryData,
      fallback: _extractInt(json['category']),
    );
    final categoryName = categoryData is Map<String, dynamic>
        ? categoryData['name']?.toString() ??
              json['category_name']?.toString() ??
              ''
        : json['category_name']?.toString() ?? '';

    final specialPoojaDatesRaw = json['special_pooja_dates'];

    return PoojaDetails(
      id: _extractInt(json['id']),
      name: _extractString(json['name']),
      category: categoryId,
      categoryName: categoryName,
      price: _extractString(json['price'], fallback: '0.00'),
      status: _extractBool(json['status']),
      bannerDesc: _extractString(json['banner_desc']),
      cardDesc: _extractString(json['card_desc']),
      captionsDesc: _extractString(json['captions_desc']),
      specialPooja: _extractBool(json['special_pooja']),
      specialPoojaDates: specialPoojaDatesRaw is List
          ? specialPoojaDatesRaw
                .map((date) => SpecialPoojaDate.fromJson(_ensureMap(date)))
                .toList()
          : const [],
      mediaUrl: _extractString(
        json['media_url'],
        fallback: _extractString(json['banner_url']),
      ),
      bannerUrl: _extractString(json['banner_url']),
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
      id: _extractInt(json['id']),
      pooja: _extractInt(json['pooja']),
      poojaName: _extractString(json['pooja_name']),
      date: _extractString(json['date']),
      malayalamDate: _extractString(json['malayalam_date']),
      time: json['time'],
      price: _extractString(json['price'], fallback: '0.00'),
      status: _extractBool(json['status']),
      banner: _extractBool(json['banner']),
      createdAt: _extractString(json['created_at']),
      modifiedAt: _extractString(json['modified_at']),
      linkedOrdersCount: _extractInt(json['linked_orders_count']),
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
      id: _extractInt(json['id']),
      pooja: _extractInt(json['pooja']),
      poojaName: _extractString(json['pooja_name']),
      date: _extractString(json['date']),
      malayalamDate: _extractString(json['malayalam_date']),
      time: json['time'],
      price: _extractString(json['price'], fallback: '0.00'),
      status: _extractBool(json['status']),
      banner: _extractBool(json['banner']),
      createdAt: _extractString(json['created_at']),
      modifiedAt: _extractString(json['modified_at']),
      linkedOrdersCount: _extractInt(json['linked_orders_count']),
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
    final data = _ensureMap(json);

    final attributesRaw = data['attributes'];
    final attributes = attributesRaw is List
        ? attributesRaw
              .map((attr) => UserAttribute.fromJson(_ensureMap(attr)))
              .toList()
        : const <UserAttribute>[];

    return UserListDetails(
      id: _extractInt(data['id']),
      name: _extractString(data['name']),
      user: _extractInt(data['user'], fallback: _extractInt(data['user_id'])),
      attributes: attributes,
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
    final nakshatramData = json['nakshatram'];
    final nakshatramId = _extractInt(
      nakshatramData,
      fallback: _extractInt(json['nakshatram']),
    );
    final nakshatramName = nakshatramData is Map<String, dynamic>
        ? nakshatramData['name']?.toString() ??
              json['nakshatram_name']?.toString() ??
              ''
        : json['nakshatram_name']?.toString() ?? '';

    return UserAttribute(
      id: _extractInt(json['id']),
      userList: _extractInt(json['user_list']),
      nakshatram: nakshatramId,
      nakshatramName: nakshatramName,
    );
  }
}

int _extractInt(dynamic value, {int fallback = 0}) {
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.tryParse(value) ?? fallback;
  if (value is Map<String, dynamic>) {
    return _extractInt(value['id'], fallback: fallback);
  }
  return fallback;
}

int? _extractNullableInt(dynamic value) {
  if (value == null) return null;
  return _extractInt(value);
}

String _extractString(dynamic value, {String fallback = ''}) {
  if (value == null) return fallback;
  return value.toString();
}

bool _extractBool(dynamic value, {bool fallback = false}) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    final v = value.toLowerCase();
    if (v == 'true') return true;
    if (v == 'false') return false;
  }
  return fallback;
}

Map<String, dynamic> _ensureMap(dynamic value) {
  if (value is Map<String, dynamic>) {
    return value;
  }
  return <String, dynamic>{};
}

Map<String, dynamic> _normalizePoojaDetails(dynamic value) {
  final map = _ensureMap(value);
  if (map.isEmpty) {
    return <String, dynamic>{};
  }

  final normalized = Map<String, dynamic>.from(map);

  final category = normalized['category'];
  if (category is Map<String, dynamic>) {
    normalized['category'] = category['id'];
    normalized['category_name'] =
        category['name'] ?? normalized['category_name'];
  }

  normalized['price'] = _extractString(normalized['price'], fallback: '0.00');

  return normalized;
}

Map<String, dynamic> _normalizeUserList(
  dynamic value,
  dynamic fallbackAttribute,
) {
  final map = _ensureMap(value);

  final normalized = Map<String, dynamic>.from(map);

  final attributes =
      (normalized['attributes'] as List<dynamic>?)
          ?.map((attr) => _normalizeUserAttribute(attr))
          .where((attr) => attr.isNotEmpty)
          .toList() ??
      <Map<String, dynamic>>[];

  if (fallbackAttribute != null) {
    final attr = _normalizeUserAttribute(fallbackAttribute);
    if (attr.isNotEmpty) {
      attributes.add(attr);
    }
  }

  normalized['attributes'] = attributes;
  normalized['id'] = _extractInt(normalized['id']);
  normalized['name'] = _extractString(normalized['name']);
  normalized['user'] = _extractInt(
    normalized['user'],
    fallback: _extractInt(normalized['user_id']),
  );

  return normalized;
}

Map<String, dynamic> _normalizeUserAttribute(dynamic value) {
  final map = _ensureMap(value);
  if (map.isEmpty) {
    return map;
  }

  final normalized = Map<String, dynamic>.from(map);
  final nakshatram = normalized['nakshatram'];
  if (nakshatram is Map<String, dynamic>) {
    normalized['nakshatram'] = nakshatram['id'];
    normalized['nakshatram_name'] =
        nakshatram['name'] ?? normalized['nakshatram_name'];
  }
  return normalized;
}
