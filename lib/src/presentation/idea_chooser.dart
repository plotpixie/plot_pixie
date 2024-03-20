import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:plot_pixie/src/ai/model/node.dart';
import 'package:plot_pixie/src/presentation/state/idea_notifier.dart';
import '../ai/pixie.dart';
import 'colors.dart';

class IdeaChooser extends ConsumerWidget {
  const IdeaChooser({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _IdeaChooser._ideaChooser(ref);
  }
}

class _IdeaChooser extends StatefulWidget {
  final WidgetRef ref;

  const _IdeaChooser._ideaChooser(this.ref);

  @override
  _IdeaChooserState createState() => _IdeaChooserState();
}

class _IdeaChooserState extends State<_IdeaChooser> {
  late Future<List<Node>> _ideaList;
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _ideaList = Pixie().getIdeas('', numberOfIdeas: 15);
  }

  Widget _buildIdeaCard(
      BuildContext context, AsyncSnapshot<List<Node>> snapshot, Node idea) {
    int index = snapshot.data!.indexOf(idea);
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: GestureDetector(
        onTap: () {
          widget.ref
              .read(selectedIdeaProvider.notifier)
              .selectIdea(snapshot.data![index]);
          GoRouter.of(context).go('/characters');
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Container(
            color: colors[index % colors.length],
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    idea.title,
                    style: const TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      decoration: TextDecoration.none,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    idea.description,
                    style: const TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.normal,
                      color: Colors.black,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.send),
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
              decoration: const InputDecoration(
                labelText: 'Suggest your own idea',
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Node>>(
              future: _ideaList,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) => _buildIdeaCard(
                        context, snapshot, snapshot.data![index]),
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
