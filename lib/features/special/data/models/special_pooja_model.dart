import 'package:hive/hive.dart';


@HiveType(typeId: 0) // unique id for this model
class SpecialPooja {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final int category;

  @HiveField(3)
  final String categoryName;

  @HiveField(4)
  final String price;

  @HiveField(5)
  final bool status;

  @HiveField(6)
  final String bannerDesc;

  @HiveField(7)
  final String cardDesc;

  @HiveField(8)
  final String captionsDesc;

  @HiveField(9)
  final bool specialPooja;

  @HiveField(10)
  final List<SpecialPoojaDate> specialPoojaDates;

  @HiveField(11)
  final String mediaUrl;

  @HiveField(12)
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
      specialPoojaDates: (json['special_pooja_dates'] as List<dynamic>?)
              ?.map((e) => SpecialPoojaDate.fromJson(e))
              .toList() ??
          [],
      mediaUrl: json['media_url'] ?? '',
      bannerUrl: json['banner_url'] ?? '',
    );
  }
}


@HiveType(typeId: 1)  // another unique id
class SpecialPoojaDate {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final int pooja;

  @HiveField(2)
  final String poojaName;

  @HiveField(3)
  final String date;

  @HiveField(4)
  final String malayalamDate;

  @HiveField(5)
  final String? time;

  @HiveField(6)
  final String price;

  @HiveField(7)
  final bool status;

  @HiveField(8)
  final bool banner;

  @HiveField(9)
  final String createdAt;

  @HiveField(10)
  final String modifiedAt;

  @HiveField(11)
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
