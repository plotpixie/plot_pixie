import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BottomNavigation extends StatefulWidget {
  const BottomNavigation({super.key, this.child});

  final Widget? child;

  @override
  State<BottomNavigation> createState() => _BottomNavigationBarState();
}

class _BottomNavigationBarState extends State<BottomNavigation> {
  int currentIndex = 0;

  void changeTab(int index) {
    switch (index) {
      case 0:
        GoRouter.of(context).go('/');
        break;
      case 1:
        GoRouter.of(context).go('/characters');
        break;
      case 2:
        GoRouter.of(context).go('/outline');
        break;
      default:
        GoRouter.of(context).go('/');
        break;
    }
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        onTap: changeTab,
        currentIndex: currentIndex,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.people), label: 'Characters'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}
