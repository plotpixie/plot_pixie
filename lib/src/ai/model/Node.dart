import 'package:json_annotation/json_annotation.dart';

part 'Node.g.dart';

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class Node {
  Node(this.type, this.title, this.description, [this.nodes = const []]);

  String type;
  String title;
  String description;
  List<Node?> nodes;

  factory Node.fromJson(Map<String, dynamic> json) => _$NodeFromJson(json);

  Map<String, dynamic> toJson() => _$NodeToJson(this);
}
