class SpecialPooja {
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

  SpecialPooja({
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

  factory SpecialPooja.fromJson(Map<String, dynamic> json) {
    return SpecialPooja(
      id: json['id'],
      name: json['name'],
      category: json['category'],
      categoryName: json['category_name'],
      price: json['price'],
      status: json['status'],
      bannerDesc: json['banner_desc'] ?? '',
      cardDesc: json['card_desc'] ?? '',
      captionsDesc: json['captions_desc'] ?? '',
      specialPooja: json['special_pooja'],
      specialPoojaDates:
          (json['special_pooja_dates'] as List<dynamic>?)
              ?.map((e) => SpecialPoojaDate.fromJson(e))
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
    required this.time,
    required this.price,
    required this.status,
    required this.banner,
    required this.createdAt,
    required this.modifiedAt,
    required this.linkedOrdersCount,
  });

  factory SpecialPoojaDate.fromJson(Map<String, dynamic> json) {
    return SpecialPoojaDate(
      id: json['id'],
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
