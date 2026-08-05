class BannerModel {
  final String id;
  final String title;
  final String imageUrl;
  final String? linkUrl;

  BannerModel({required this.id, required this.title, required this.imageUrl, this.linkUrl});

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['_id'] as String,
      title: json['title'] as String,
      imageUrl: json['imageUrl'] as String,
      linkUrl: json['linkUrl'] as String?,
    );
  }
}
