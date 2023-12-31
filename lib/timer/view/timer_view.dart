import 'package:bloc_demo/timer/view/timer_actions.dart';
import 'package:bloc_demo/timer/view/timer_text.dart';
import 'package:flutter/material.dart';

class TimerView extends StatelessWidget {
  const TimerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 100),
          child: Center(
            child: TimerText(),
          ),
        ),
        const TimerActions(),
      ],
    );
  }
}
