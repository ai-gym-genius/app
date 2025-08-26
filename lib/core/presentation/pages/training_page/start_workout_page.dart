import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gym_genius/theme/context_getters.dart';

class StartWorkoutPage extends StatelessWidget {
  const StartWorkoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildNavBar(context),
      body: Center(
        child: CupertinoButton.tinted(
          child: Text(
            'Start a workout',
            style: context.txt.label.copyWith(
              color: context.colors.primary,
            ),
          ),
          onPressed: () {
            Navigator.pushNamed(context, '/training_process');
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildNavBar(BuildContext context) {
    final colors = context.colors;
    return CupertinoNavigationBar(
      backgroundColor: colors.secondary,
      middle: Text(
        'Profile',
        style: context.txt.title,
      ),
      trailing: CupertinoButton(
        padding: EdgeInsets.zero,
        child: const Icon(CupertinoIcons.profile_circled),
        onPressed: () {
          Navigator.pushNamed(context, '/auth');
        },
      ),
    );
  }
}
