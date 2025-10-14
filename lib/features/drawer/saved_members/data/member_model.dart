import 'package:hive/hive.dart';

part 'member_model.g.dart';

@HiveType(typeId: 27)
class MemberModel {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final int user;

  @HiveField(3)
  final String? dob;

  @HiveField(4)
  final String? time;

  @HiveField(5)
  final bool personal;

  @HiveField(6)
  final List<MemberAttribute> attributes;

  MemberModel({
    required this.id,
    required this.name,
    required this.user,
    this.dob,
    this.time,
    required this.personal,
    required this.attributes,
  });

  factory MemberModel.fromJson(Map<String, dynamic> json) {
    return MemberModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      user: json['user'] ?? 0,
      dob: json['DOB'],
      time: json['time'],
      personal: json['personal'] ?? false,
      attributes: (json['attributes'] as List<dynamic>? ?? [])
          .map((e) => MemberAttribute.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'user': user,
      'DOB': dob,
      'time': time,
      'personal': personal,
      'attributes': attributes.map((e) => e.toJson()).toList(),
    };
  }
}

@HiveType(typeId: 28)
class MemberAttribute {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final int userListId;

  @HiveField(2)
  final int nakshatram;

  @HiveField(3)
  final String nakshatramName;

  @HiveField(4)
  final bool status;

  MemberAttribute({
    required this.id,
    required this.userListId,
    required this.nakshatram,
    required this.nakshatramName,
    required this.status,
  });

  factory MemberAttribute.fromJson(Map<String, dynamic> json) {
    return MemberAttribute(
      id: json['id'] ?? 0,
      userListId: json['user_list'] ?? 0,
      nakshatram: json['nakshatram'] ?? 0,
      nakshatramName: json['nakshatram_name'] ?? '',
      status: json['status'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_list': userListId,
      'nakshatram': nakshatram,
      'nakshatram_name': nakshatramName,
      'status': status,
    };
  }
}
