class GlobalUpdateDetailModel {
  final int id;
  final String modelName;
  final String lastUpdated;
  final bool globalUser;

  GlobalUpdateDetailModel({
    required this.id,
    required this.modelName,
    required this.lastUpdated,
    required this.globalUser,
  });

  factory GlobalUpdateDetailModel.fromJson(Map<String, dynamic> json) {
    return GlobalUpdateDetailModel(
      id: json['id'] ?? 0,
      modelName: json['model_name'] ?? '',
      lastUpdated: json['last_updated'] ?? '',
      globalUser: json['global_user'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'model_name': modelName,
      'last_updated': lastUpdated,
      'global_user': globalUser,
    };
  }
}
