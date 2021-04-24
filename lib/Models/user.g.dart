// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) {
  return User(
      id: json['id'] as String,
      Name: json['Name'] as String,
      email: json['email'] as String,
      userid:json['userid'] as String,
      password: json['password'] as String);
}

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'id': instance.id,
      'Name':instance.Name,
      'email': instance.email,
      'userid': instance.userid,
      'password': instance.password
    };
