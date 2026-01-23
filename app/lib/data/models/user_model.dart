import 'package:json_annotation/json_annotation.dart';

// O nome deste arquivo deve ser igual ao nome do arquivo .dart, trocando por .g.dart
part 'user_model.g.dart'; 

@JsonSerializable()
class UserModel {
  final int id;
  final String name;
  final String email;
  
  // O PHP manda 'avatar_url', mas no Flutter usamos camelCase (avatarUrl)
  @JsonKey(name: 'avatar_url') 
  final String? avatarUrl;
  
  // O PHP manda 'weight_lost', mapeamos aqui
  @JsonKey(name: 'weight_lost')
  final dynamic weightLost; // Dynamic porque pode vir como número ou texto do banco

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    this.weightLost,
  });

  // Estas funções serão criadas automaticamente no passo seguinte
  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);
  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}