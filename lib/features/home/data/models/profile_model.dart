class ProfileModel {
  final String name;
  final String? phone;
  final String email;
  final String dob;
  final String time;
  final Nakshatram nakshatram;
  final String malayalamDate;

  ProfileModel({
    required this.name,
    this.phone,
    required this.email,
    required this.dob,
    required this.time,
    required this.nakshatram,
    required this.malayalamDate,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      name: json['name'] ?? '',
      phone: json['phone'],
      email: json['email'] ?? '',
      dob: json['DOB'] ?? '',
      time: json['time'] ?? '',
      nakshatram: Nakshatram.fromJson(json['nakshatram'] ?? {}),
      malayalamDate: json['malayalam_date'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      'email': email,
      'DOB': dob,
      'time': time,
      'nakshatram': nakshatram.toJson(),
      'malayalam_date': malayalamDate,
    };
  }
}

class Nakshatram {
  final int id;
  final String name;

  Nakshatram({required this.id, required this.name});

  factory Nakshatram.fromJson(Map<String, dynamic> json) {
    return Nakshatram(id: json['id'] ?? 0, name: json['name'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}

class ProfileResponse {
  final ProfileModel profile;

  ProfileResponse({required this.profile});

  factory ProfileResponse.fromJson(Map<String, dynamic> json) {
    return ProfileResponse(
      profile: ProfileModel.fromJson(json['profile'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {'profile': profile.toJson()};
  }
}
