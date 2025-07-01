class AmigoModel {
  String nome;
  String avatar;
  int level;
  final String id;

  AmigoModel({
    required this.nome,
    required this.avatar,
    required this.level,
    required this.id,
  });


  factory AmigoModel.fromJson(Map<String, dynamic> json) {
    return AmigoModel(
      nome: json['nome'],
      avatar: json['avatar'],
      level: json['level'],
      id: json['id']
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
      'avatar': avatar,
      'level': level,
      'id': id
    };
  }
}
