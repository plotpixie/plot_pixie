// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Character.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Character _$CharacterFromJson(Map<String, dynamic> json) => Character(
      json['name'] as String,
      json['description'] as String,
      json['age'] as String,
      json['looks'] as String,
      (json['traits'] as List<dynamic>)
          .map((e) => Trait.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$CharacterToJson(Character instance) => <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'age': instance.age,
      'looks': instance.looks,
      'traits': instance.traits.map((e) => e.toJson()).toList(),
    };
