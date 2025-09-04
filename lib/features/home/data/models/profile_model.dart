class Profile {
  final String name;
  final String? phone;
  final String email;
  final String dob;
  final String time;
  final String nakshatram;
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
