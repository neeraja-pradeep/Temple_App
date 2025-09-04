class HomePoojaCategory {
  final int id;
  final String name;
  final int? parent;
  final String mediaUrl;
  final String mediaPublicId;
  final String homeMediaUrl;
  final String homeMediaPublicId;
  final List<dynamic> children;
  final bool isActive;

  HomePoojaCategory({
    required this.id,
    required this.name,
    this.parent,
    required this.mediaUrl,
    required this.mediaPublicId,
    required this.homeMediaUrl,
    required this.homeMediaPublicId,
    required this.children,
    required this.isActive,
  });

  factory HomePoojaCategory.fromJson(Map<String, dynamic> json) =>
      HomePoojaCategory(
        id: json['id'] ?? 0,
        name: json['name'] ?? '',
        parent: json['parent'],
        mediaUrl: json['media_url'] ?? '',
        mediaPublicId: json['media_public_id'] ?? '',
        homeMediaUrl: json['home_media_url'] ?? '',
        homeMediaPublicId: json['home_media_public_id'] ?? '',
        children: json['children'] ?? [],
        isActive: json['is_active'] ?? false,
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'parent': parent,
    'media_url': mediaUrl,
    'media_public_id': mediaPublicId,
    'home_media_url': homeMediaUrl,
    'home_media_public_id': homeMediaPublicId,
    'children': children,
    'is_active': isActive,
  };
}

class HomePoojaCategoryResponse {
  final int count;
  final List<HomePoojaCategory> results;

  HomePoojaCategoryResponse({required this.count, required this.results});

  factory HomePoojaCategoryResponse.fromJson(Map<String, dynamic> json) =>
      HomePoojaCategoryResponse(
        count: json['count'] ?? 0,
        results:
            (json['results'] as List<dynamic>?)
                ?.map((item) => HomePoojaCategory.fromJson(item))
                .toList() ??
            [],
      );

  Map<String, dynamic> toJson() => {
    'count': count,
    'results': results.map((item) => item.toJson()).toList(),
  };
}
