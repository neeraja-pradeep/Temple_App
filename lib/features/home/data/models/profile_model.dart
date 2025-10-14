import 'package:hive_flutter/hive_flutter.dart';

part 'profile_model.g.dart';

@HiveType(typeId: 14)
class Profile extends HiveObject {
  @HiveField(0)
  final String name;
  @HiveField(1)
  final String? phone;
  @HiveField(2)
  final String email;
  @HiveField(3)
  final String dob;
  @HiveField(4)
  final String time;
  @HiveField(5)
  final String nakshatram;
  @HiveField(6)
  final String malayalamDate;
  

  Profile({
    required this.name,
    required this.phone,
    required this.email,
    required this.dob,
    required this.time,
    required this.nakshatram,
    required this.malayalamDate,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      name: json['name'] ?? '',
      phone: json['phone'],
      email: json['email'] ?? '',
      dob: json['DOB'] ?? '',
      time: json['time'] ?? '',
      nakshatram: json['nakshatram']?['name'] ?? '',
      malayalamDate: json['malayalam_date'] ?? '',
    );
  }
}
