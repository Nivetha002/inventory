class CategoryModel {
  final String id;
  final String name;
  final String description;
  final bool isActive;

  CategoryModel({
    required this.id,
    required this.name,
    required this.description,
    required this.isActive,
  });

  factory CategoryModel.fromMap(
    Map<String, dynamic> map,
  ) {
    return CategoryModel(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      description:
          map['description']?.toString() ?? '',
      isActive: map['is_active'] == true,
    );
  }
}