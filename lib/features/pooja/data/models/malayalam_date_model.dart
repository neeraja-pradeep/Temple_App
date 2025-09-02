import 'package:hive/hive.dart';

part 'malayalam_date_model.g.dart';

@HiveType(typeId: 4)
class MalayalamDateModel extends HiveObject {
  @HiveField(0)
  final int id;
  @HiveField(1)
  final String gregorianDate;
  @HiveField(2)
  final String malayalamDate;

  MalayalamDateModel({
    required this.id,
    required this.gregorianDate,
    required this.malayalamDate,
  });

  factory MalayalamDateModel.fromJson(Map<String, dynamic> json) =>
      MalayalamDateModel(
        id: json['id'] ?? 0,
        gregorianDate: json['gregorian_date'] ?? '',
        malayalamDate: json['malayalam_date'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'gregorian_date': gregorianDate,
        'malayalam_date': malayalamDate,
      };
}
