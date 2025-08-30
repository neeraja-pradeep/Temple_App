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

class BookingPooja {
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

  BookingPooja({
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

  factory BookingPooja.fromJson(Map<String, dynamic> json) {
    return BookingPooja(
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'category_name': categoryName,
      'price': price,
      'status': status,
      'banner_desc': bannerDesc,
      'card_desc': cardDesc,
      'captions_desc': captionsDesc,
      'special_pooja': specialPooja,
      'special_pooja_dates': specialPoojaDates,
      'media_url': mediaUrl,
      'banner_url': bannerUrl,
    };
  }
}
