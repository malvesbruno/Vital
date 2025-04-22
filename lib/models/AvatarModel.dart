class AvatarModel {
  final String name;
  final String imagePath;
  final int price;
  final int requiredLevel;
  bool owned;

  AvatarModel({
    required this.name,
    required this.imagePath,
    required this.price,
    required this.requiredLevel,
    this.owned = false,
  });
}