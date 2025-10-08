class MemberModel {
  final int id;
  final String name;
  final int user;
  final String? dob;
  final String? time;
  final bool personal;
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
      id: json['id'],
      name: json['name'],
      user: json['user'],
      dob: json['DOB'],
      time: json['time'],
      personal: json['personal'] ?? false,
      attributes: (json['attributes'] as List<dynamic>?)
              ?.map((e) => MemberAttribute.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class MemberAttribute {
  final int id;
  final int userListId;
  final int nakshatram;
  final String nakshatramName;
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
      id: json['id'],
      userListId: json['user_list'],
      nakshatram: json['nakshatram'],
      nakshatramName: json['nakshatram_name'],
      status: json['status'],
    );
  }
}
