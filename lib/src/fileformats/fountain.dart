import 'dart:io';

import 'package:intl/intl.dart';
import 'package:plot_pixie/src/ai/model/node.dart';
import 'package:plot_pixie/src/ai/model/work.dart';

class Fountain {
  static void write(File file, Work work) {
    String text = """
Title:
_**${work.idea?.title.toUpperCase()}**_
Credit: Written by
Author: 
Source: Story by 
Draft date: ${DateFormat('MM/dd/yy').format(DateTime.now())}
Contact:
""";

    for (int actCount = 0; actCount < work.acts.length; actCount++) {
      Node act = work.acts[actCount];
      text += """\n# Act ${actCount + 1} 
= ${act.description}
""";
      for (int beatCount = 0; beatCount < act.nodes.length; beatCount++) {
        Node? beat = act.nodes[beatCount];
        text += """\n## ${beat?.title} ( ${beat?.getTrait('plot_point')} )
= ${beat?.description}\n/*""";
        for (var trait in beat!.traits) {
          if (trait?.type != 'plot_point') {
            text += """\n${trait?.type} : ${trait?.description}""";
          }
        }
        text += """\n*/""";

        for (int sceneCount = 0; sceneCount < beat.nodes.length; sceneCount++) {
          text += """\n### ${beat.nodes[sceneCount]?.title}
= ${beat.nodes[sceneCount]?.description}
""";
        }
      }
    }
    file.writeAsString(text);
  }
}
