import 'package:json_annotation/json_annotation.dart';
import 'package:plot_pixie/src/ai/model/node.dart';

part 'work.g.dart';

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class Work {
  Work([this.idea, this.characters = const [], this.acts = const []]);

  Node? idea;
  List<Node> characters;
  List<Node> acts;

  factory Work.fromJson(Map<String, dynamic> json) => _$WorkFromJson(json);

  Map<String, dynamic> toJson() => _$WorkToJson(this);
}
