import 'dart:developer';

import 'package:appinio_swiper/appinio_swiper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../ai/model/Character.dart';

class ChoiceSwiper extends StatefulWidget {
  final String title;
  final List<Color> colors = [
    const Color.fromRGBO(247, 135, 154, 0.2), // #f7879a
    const Color.fromRGBO(237, 197, 87, 0.2),  // #edc557
    const Color.fromRGBO(243, 246, 244, 0.2), // #f3f6f4
    const Color.fromRGBO(61, 173, 183, 0.2),  // #3dadb7
    const Color.fromRGBO(116, 116, 189, 0.2), // #7474bd
    const Color.fromRGBO(168, 208, 230, 0.2), // #a8d0e6
    const Color.fromRGBO(248, 165, 194, 0.2), // #f8a5c2
    const Color.fromRGBO(106, 44, 112, 0.2),  // #6a2c70
    const Color.fromRGBO(184, 59, 94, 0.2),   // #b83b5e
    const Color.fromRGBO(240, 138, 93, 0.2),  // #f08a5d
    const Color.fromRGBO(178, 178, 178, 0.2), // #b2b2b2
    const Color.fromRGBO(73, 117, 156, 0.2),  // #49759c
    const Color.fromRGBO(255, 221, 147, 0.2), // #ffdd93
  ];

  List<Character> characters = [];
  ChoiceSwiper({super.key, required this.title});

  @override
  _ChoiceSwiperState createState() => _ChoiceSwiperState();
}

class _ChoiceSwiperState extends State<ChoiceSwiper> {
  final AppinioSwiperController controller = AppinioSwiperController();

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.75,
        child: AppinioSwiper(
          invertAngleOnBottomDrag: true,
          backgroundCardCount: 3,
          swipeOptions: const SwipeOptions.all(),
          controller: controller,
          onSwipeEnd: _swipeEnd,
          onEnd: _onEnd,
          cardCount: widget.colors.length,
          cardBuilder: (BuildContext context, int index) {
            return ClipRRect(
              child: Stack(
                children: [
                  Container(
                    alignment: Alignment.center,
                    color: Colors.grey, // Or any other color that suits your design
                  ),
                  Container(
                    alignment: Alignment.center,
                    color: widget.colors[index],
                    child: Text('Card ${index + 1}'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _swipeEnd(int previousIndex, int targetIndex, SwiperActivity activity) {
    switch (activity) {
      case Swipe():
        log('The card was swiped to the : ${activity.direction}');
        log('previous index: $previousIndex, target index: $targetIndex');
        break;
      case Unswipe():
        log('A ${activity.direction.name} swipe was undone.');
        log('previous index: $previousIndex, target index: $targetIndex');
        break;
      case CancelSwipe():
        log('A swipe was cancelled');
        break;
      case DrivenActivity():
        log('Driven Activity');
        break;
    }
  }

  void _onEnd() {
    log('end reached!');
  }
}
