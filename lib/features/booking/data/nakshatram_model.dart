class NakshatramOption {
  final int id;
  final String name;

  NakshatramOption({required this.id, required this.name});

  factory NakshatramOption.fromJson(Map<String, dynamic> json) {
    return NakshatramOption(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }
}

