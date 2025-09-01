
//modelo de avatar
class AvatarModel {
  final String name;
  final String imagePath;
  final int price;
  final int requiredLevel;
  bool owned;
  final bool exclusive;

  AvatarModel({
    required this.name,
    required this.imagePath,
    required this.price,
    required this.requiredLevel,
    this.owned = false,
    required this.exclusive
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'imagePath': imagePath,
      'price': price,
      'requiredLevel': requiredLevel,
      'exclusive': exclusive,
      'owned': owned,
    };
  }

  factory AvatarModel.fromJson(Map<String, dynamic> json) {
    return AvatarModel(
      name: json['name'],
      imagePath: json['imagePath'],
      price: json['price'],
      requiredLevel: json['requiredLevel'],
      exclusive: json['exclusive'],
      owned: json['owned']
    );
  }

}