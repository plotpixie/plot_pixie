import 'package:json_annotation/json_annotation.dart';

part 'Trait.g.dart';

@JsonSerializable(explicitToJson: true)
class Trait {
  Trait(this.type, this.description);

  String type;
  String description;

  factory Trait.fromJson(Map<String, dynamic> json) => _$TraitFromJson(json);

  Map<String, dynamic> toJson() => _$TraitToJson(this);
}
