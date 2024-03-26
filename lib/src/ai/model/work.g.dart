// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'work.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Work _$WorkFromJson(Map<String, dynamic> json) => Work(
      json['idea'] == null
          ? null
          : Node.fromJson(json['idea'] as Map<String, dynamic>),
      (json['characters'] as List<dynamic>?)
              ?.map((e) => Node.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      (json['acts'] as List<dynamic>?)
              ?.map((e) => Node.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$WorkToJson(Work instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('idea', instance.idea?.toJson());
  val['characters'] = instance.characters.map((e) => e.toJson()).toList();
  val['acts'] = instance.acts.map((e) => e.toJson()).toList();
  return val;
}
