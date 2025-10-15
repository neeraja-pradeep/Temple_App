class UserList {
  final int id;
  final String name;
  final int user;
  final String dob;
  final String time;
  final bool personal;
  final List<UserAttribute> attributes;

  UserList({
    required this.id,
    required this.name,
    required this.user,
    required this.dob,
    required this.time,
    required this.personal,
    required this.attributes,
  });

  factory UserList.fromJson(Map<String, dynamic> json) {
    return UserList(
      id: json['id'],
      name: json['name'],
      user: json['user'],
      dob: (json['DOB'] ?? '') as String,
      time: (json['time'] ?? '') as String,
      personal: (json['personal'] ?? false) as bool,
      attributes: (json['attributes'] as List)
          .map((attr) => UserAttribute.fromJson(attr))
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
      'attributes': attributes.map((attr) => attr.toJson()).toList(),
    };
  }
}

class UserAttribute {
  final int id;
  final int userList;
  final int nakshatram;
  final String nakshatramName;
  final bool status;

  UserAttribute({
    required this.id,
    required this.userList,
    required this.nakshatram,
    required this.nakshatramName,
    required this.status,
  });

  factory UserAttribute.fromJson(Map<String, dynamic> json) {
    return UserAttribute(
      id: json['id'],
      userList: json['user_list'],
      nakshatram: json['nakshatram'],
      nakshatramName: (json['nakshatram_name'] ?? '') as String,
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_list': userList,
      'nakshatram': nakshatram,
      'nakshatram_name': nakshatramName,
      'status': status,
    };
  }
}
