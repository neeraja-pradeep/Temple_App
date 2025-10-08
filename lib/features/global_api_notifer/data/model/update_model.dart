class GlobalUpdateModel {
  final String lastUpdated;

  GlobalUpdateModel({required this.lastUpdated});

  factory GlobalUpdateModel.fromJson(Map<String, dynamic> json) {
    return GlobalUpdateModel(lastUpdated: json['last_updated']);
  }
}
