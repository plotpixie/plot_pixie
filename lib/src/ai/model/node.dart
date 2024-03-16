import 'package:json_annotation/json_annotation.dart';
import 'package:plot_pixie/src/ai/model/trait.dart';

part 'node.g.dart';

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class Node {
  Node(this.type, this.title, this.description, [this.nodes = const [], this.traits = const[]]);

  String type;
  String title;
  String description;
  List<Node?> nodes;
  List<Trait?> traits;

  factory Node.fromJson(Map<String, dynamic> json) => _$NodeFromJson(json);

  Map<String, dynamic> toJson() => _$NodeToJson(this);

  String getTrait(String traitType) {
    for (final trait in traits) {
      if (trait?.type == traitType) {
        return trait?.description ?? '';
      }
    }
    return '';
  }

}
