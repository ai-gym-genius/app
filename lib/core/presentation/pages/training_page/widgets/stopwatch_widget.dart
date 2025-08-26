import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gym_genius/theme/context_getters.dart';

class StopwatchController extends ChangeNotifier {
  StopwatchController({Duration tick = const Duration(milliseconds: 30)}) {
    _ticker = Timer.periodic(tick, (_) => notifyListeners());
  }
  final Stopwatch _sw = Stopwatch();
  late final Timer _ticker;

  Duration get elapsed => _sw.elapsed;
  bool get isRunning => _sw.isRunning;

  void start() {
    _sw.start();
  }

  void stop() {
    _sw.stop();
  }

  void reset() {
    _sw.reset();
    notifyListeners();
  }

  @override
  void dispose() {
    _ticker.cancel();
    _sw.stop();
    super.dispose();
  }
}

class StopwatchWidget extends StatelessWidget {
  const StopwatchWidget({
    required this.controller,
    super.key,
    this.style,
  });
  final StopwatchController controller;
  final TextStyle? style;

  String _fmt(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.inHours)}:${two(d.inMinutes.remainder(60))}:'
        '${two(d.inSeconds.remainder(60))}';
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) => Text(
        _fmt(controller.elapsed),
        style: style ??
            TextStyle(
              color: context.colors.onSurface,
            ),
      ),
    );
  }
}
