class CategoryModel {
  final String id;
  final String title;
  final String type;
  final List<TemplateModel> templates;

  CategoryModel({
    required this.id,
    required this.title,
    required this.type,
    required this.templates,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json["id"] ?? "",
      title: json["title"] ?? "",
      type: json["type"] ?? "",
      templates: (json["templates"] as List?)
          ?.map((e) => TemplateModel.fromJson(e))
          .toList() ??
          [],
    );
  }
}

class TemplateModel {
  final String image;
  final String? prompt;
  String? imageUrl;

  TemplateModel({
    required this.image,
    this.prompt,
    this.imageUrl,
  });

  factory TemplateModel.fromJson(Map<String, dynamic> json) {
    return TemplateModel(
      image: json["image"] ?? "",
      prompt: json["prompt"],
    );
  }
}