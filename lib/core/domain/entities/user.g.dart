// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_User _$UserFromJson(Map<String, dynamic> json) => _User(
      login: json['login'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      surname: json['surname'] as String,
      password: json['password'] as String,
    );

Map<String, dynamic> _$UserToJson(_User instance) => <String, dynamic>{
      'login': instance.login,
      'email': instance.email,
      'name': instance.name,
      'surname': instance.surname,
      'password': instance.password,
    };
