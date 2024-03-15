import 'package:json_annotation/json_annotation.dart';

import 'Trait.dart';

part 'Character.g.dart';

@JsonSerializable(explicitToJson: true)
class Character {
  Character(this.name, this.description, this.age, this.looks, this.traits);

  String name;
  String description;
  String age;
  String looks;
  List<Trait> traits;

  factory Character.fromJson(Map<String, dynamic> json) =>
      _$CharacterFromJson(json);

  Map<String, dynamic> toJson() => _$CharacterToJson(this);
}
