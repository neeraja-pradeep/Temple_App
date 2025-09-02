import 'package:hive/hive.dart';

part 'pooja_model.g.dart';

@HiveType(typeId: 3)
class Pooja extends HiveObject {
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
  final List<dynamic> specialPoojaDates;
  @HiveField(11)
  final String mediaUrl;
  @HiveField(12)
  final String bannerUrl;

  Pooja({
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

  factory Pooja.fromJson(Map<String, dynamic> json) => Pooja(
        id: json['id'] ?? 0,
        name: json['name'] ?? '',
        category: json['category'] ?? 0,
        categoryName: json['category_name'] ?? '',
        price: json['price'] ?? '',
        status: json['status'] ?? false,
        bannerDesc: json['banner_desc'] ?? '',
        cardDesc: json['card_desc'] ?? '',
        captionsDesc: json['captions_desc'] ?? '',
        specialPooja: json['special_pooja'] ?? false,
        specialPoojaDates: json['special_pooja_dates'] ?? [],
        mediaUrl: json['media_url'] ?? '',
        bannerUrl: json['banner_url'] ?? '',
      );

  Map<String, dynamic> toJson() => {
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
