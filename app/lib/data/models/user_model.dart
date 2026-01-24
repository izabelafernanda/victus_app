import 'package:json_annotation/json_annotation.dart';

// O nome deste arquivo deve ser igual ao nome do arquivo .dart, trocando por .g.dart
part 'user_model.g.dart'; 

@JsonSerializable()
class UserModel {
  final int id;
  final String name;
  final String email;
  
  @JsonKey(name: 'avatar_url') 
  final String? avatarUrl;
  
  @JsonKey(name: 'weight_lost')
  final dynamic weightLost; 

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    this.weightLost,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);
  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}