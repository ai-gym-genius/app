import 'package:flutter/cupertino.dart';

class Warnings {
  static void showAIReviewWarning(BuildContext context) {
    showCupertinoDialog<dynamic>(
      barrierDismissible: true,
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Something Wrong'),
        content: const Text('Try getting review later'),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
          ),
        ],
      ),
    );
  }

  static void showAlreadyHasExerciseWarning(BuildContext context) {
    showCupertinoDialog<dynamic>(
      barrierDismissible: true,
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Exercise Already Added'),
        content: const Text('This exercise is already in your workout'),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
          ),
        ],
      ),
    );
  }

  static void showSubmitEmptyWarning(BuildContext context) {
    showCupertinoDialog<dynamic>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Empty Workout'),
        content: const Text('Your workout does not have exercises'),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
          ),
        ],
      ),
    );
  }

  static void showSubmitIncompleteWarning(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Empty Exercises'),
        content: const Text('Complete or delete empty exercises'),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
          ),
        ],
      ),
    );
  }

  static void showWritingFailureWarning(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Failed to Write'),
        content: const Text('Rare writing error occurred'),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
          ),
        ],
      ),
    );
  }
}
