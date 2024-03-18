import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:plot_pixie/src/ai/model/node.dart';
import 'package:plot_pixie/src/presentation/state/idea_notifier.dart';

import '../ai/pixie.dart';

class IdeaChooser extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _IdeaChooser._IdeaChooser(ref);
  }
}

class _IdeaChooser extends StatefulWidget {
  final WidgetRef ref;

  _IdeaChooser._IdeaChooser(this.ref);

  @override
  _IdeaChooserState createState() => _IdeaChooserState();
}

class _IdeaChooserState extends State<_IdeaChooser> {
  late Future<List<Node>> _ideaList;
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _ideaList = Pixie().getIdeas('');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Idea Chooser'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.send),
            onPressed: () {
              setState(() {
                _ideaList = Pixie().getIdeas(_controller.text);
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Enter your own idea',
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Node>>(
              future: _ideaList,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(snapshot.data![index].title),
                        subtitle: Text(
                          snapshot.data![index].description,
                          style: TextStyle(
                            fontSize: 12.0,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                        onTap: () {
                          widget.ref
                              .read(selectedIdeaProvider.notifier)
                              .selectIdea(snapshot.data![index]);
                          GoRouter.of(context).go('/characters');
                        },
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
