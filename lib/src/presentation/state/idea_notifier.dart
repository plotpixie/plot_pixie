import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plot_pixie/src/ai/model/node.dart';

final selectedIdeaProvider =
    StateNotifierProvider<IdeaNotifier, Node?>((ref) => IdeaNotifier());

class IdeaNotifier extends StateNotifier<Node?> {
  IdeaNotifier() : super(null);

  void selectIdea(Node idea) {
    state = idea;
  }
}
