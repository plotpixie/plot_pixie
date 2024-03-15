// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Node.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Node _$NodeFromJson(Map<String, dynamic> json) => Node(
      json['type'] as String,
      json['title'] as String,
      json['description'] as String,
      (json['nodes'] as List<dynamic>?)
              ?.map((e) =>
                  e == null ? null : Node.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$NodeToJson(Node instance) => <String, dynamic>{
      'type': instance.type,
      'title': instance.title,
      'description': instance.description,
      'nodes': instance.nodes.map((e) => e?.toJson()).toList(),
    };
