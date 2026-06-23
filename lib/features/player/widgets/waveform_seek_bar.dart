import 'dart:math';
import 'package:flutter/material.dart';

class WaveformSeekBar extends StatefulWidget {
  final Duration position;
  final Duration duration;
  final ValueChanged<Duration> onChanged;
  final String seedString;

  const WaveformSeekBar({
    super.key,
    required this.position,
    required this.duration,
    required this.onChanged,
    required this.seedString,
  });

  @override
  State<WaveformSeekBar> createState() => _WaveformSeekBarState();
}

class _WaveformSeekBarState extends State<WaveformSeekBar> {
  late List<double> _waveformHeights;

  @override
  void initState() {
    super.initState();
    _generateWaveform();
  }

  @override
  void didUpdateWidget(covariant WaveformSeekBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.seedString != widget.seedString) {
      _generateWaveform();
    }
  }

  void _generateWaveform() {
    // Generate deterministic random heights based on the seed string (e.g. song ID or URI)
    final random = Random(widget.seedString.hashCode);
    const numBars = 60;
    _waveformHeights = List.generate(numBars, (index) {
      // Add a slight sine wave pattern over the random noise to look more like music
      final sineWave = (sin(index / numBars * pi * 4) + 1) / 2;
      return (random.nextDouble() * 0.6 + sineWave * 0.4).clamp(0.1, 1.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = widget.duration.inMilliseconds == 0
        ? 0.0
        : (widget.position.inMilliseconds / widget.duration.inMilliseconds).clamp(0.0, 1.0);

    return GestureDetector(
      onPanUpdate: (details) => _handleSeek(details.localPosition.dx, context),
      onTapDown: (details) => _handleSeek(details.localPosition.dx, context),
      child: Container(
        width: double.infinity,
        height: 60,
        color: Colors.transparent, // Catch taps
        child: CustomPaint(
          painter: _WaveformPainter(
            heights: _waveformHeights,
            progress: progress,
            activeColor: theme.colorScheme.primary,
            inactiveColor: theme.colorScheme.primary.withValues(alpha: 0.3),
          ),
        ),
      ),
    );
  }

  void _handleSeek(double dx, BuildContext context) {
    final renderBox = context.findRenderObject() as RenderBox;
    final percent = (dx / renderBox.size.width).clamp(0.0, 1.0);
    final newPosition = Duration(milliseconds: (widget.duration.inMilliseconds * percent).round());
    widget.onChanged(newPosition);
  }
}

class _WaveformPainter extends CustomPainter {
  final List<double> heights;
  final double progress;
  final Color activeColor;
  final Color inactiveColor;

  _WaveformPainter({
    required this.heights,
    required this.progress,
    required this.activeColor,
    required this.inactiveColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round;

    final barWidth = size.width / heights.length;
    final spacing = barWidth * 0.3;
    final actualBarWidth = barWidth - spacing;

    for (int i = 0; i < heights.length; i++) {
      final x = i * barWidth;
      final barHeight = heights[i] * size.height;
      final y = (size.height - barHeight) / 2;

      final isPlayed = (i / heights.length) <= progress;
      paint.color = isPlayed ? activeColor : inactiveColor;

      final rrect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x + spacing / 2, y, actualBarWidth, barHeight),
        const Radius.circular(10),
      );
      canvas.drawRRect(rrect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _WaveformPainter oldDelegate) {
    return oldDelegate.progress != progress ||
           oldDelegate.activeColor != activeColor ||
           oldDelegate.inactiveColor != inactiveColor ||
           oldDelegate.heights != heights;
  }
}
