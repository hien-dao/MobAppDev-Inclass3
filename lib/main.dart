import 'package:flutter/material.dart';
import 'dart:math';

void main() => runApp(const ValentineApp());

class ValentineApp extends StatelessWidget {
  const ValentineApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const ValentineHome(),
      theme: ThemeData(useMaterial3: true),
    );
  }
}

class ValentineHome extends StatefulWidget {
  const ValentineHome({super.key});

  @override
  State<ValentineHome> createState() => _ValentineHomeState();
}

class _ValentineHomeState extends State<ValentineHome> {
  final List<String> emojiOptions = ['Sweet Heart', 'Party Heart'];
  String selectedEmoji = 'Sweet Heart';

  // Slider value for horizontal movement
  double _currentSliderValue = 0;

  // Balloon Celebration dropdown
  final List<String> balloonOptions = ['None', 'Balloon Celebration'];
  String selectedBalloon = 'None';

  bool showBalloons = false;

  @override
  Widget build(BuildContext context) {
    return Container (
      // Background gradient image
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/bg_gradient.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Cupid\'s Canvas'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Column(
          children: [
            const SizedBox(height: 16),
            // Sweet Heart / Party Heart dropdown
            DropdownButton<String>(
              value: selectedEmoji,
              items: emojiOptions
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (value) => setState(() => selectedEmoji = value ?? selectedEmoji),
            ),
            const SizedBox(height: 16),
            // Slider for horizontal movement
            Slider(
              value: _currentSliderValue,
              min: -50,
              max: 50,
              divisions: 10,
              onChanged: (value) => setState(() => _currentSliderValue = value),
            ),
            const SizedBox(height: 16),
            // Balloon Celebration dropdown
            DropdownButton<String>(
              value: selectedBalloon,
              items: balloonOptions
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (value) => setState(() => selectedBalloon = value ?? selectedBalloon),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: selectedBalloon == 'Balloon Celebration'
                  ? () => setState(() => showBalloons = true)
                  : null,
              child: const Text('Drop Balloons!'),
            ),
            Expanded(
              child: Stack (
                children: [
                  Center(
                    child: CustomPaint(
                      size: const Size(300, 300),
                      painter: HeartEmojiPainter(
                        type: selectedEmoji,
                        offsetX: _currentSliderValue,
                        ),
                    ),
                  ),
                  if (showBalloons && selectedBalloon == 'Balloon Celebration')
                    BalloonCelebrationWidget(),
                ]
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HeartEmojiPainter extends CustomPainter {
  HeartEmojiPainter({required this.type, required this.offsetX});
  final String type;
  final double offsetX;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2 + offsetX, size.height / 2);
    final paint = Paint()..style = PaintingStyle.fill;

    // Heart base
    final heartPath = Path()
      ..moveTo(center.dx, center.dy + 60)
      ..cubicTo(center.dx + 110, center.dy - 10, center.dx + 60, center.dy - 120, center.dx, center.dy - 40)
      ..cubicTo(center.dx - 60, center.dy - 120, center.dx - 110, center.dy - 10, center.dx, center.dy + 60)
      ..close();

    paint.color = type == 'Party Heart' ? const Color(0xFFF48FB1) : const Color(0xFFE91E63);
    canvas.drawPath(heartPath, paint);

    // Face features (starter)
    final eyePaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(center.dx - 30, center.dy - 10), 10, eyePaint);
    canvas.drawCircle(Offset(center.dx + 30, center.dy - 10), 10, eyePaint);

    final mouthPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    canvas.drawArc(Rect.fromCircle(center: Offset(center.dx, center.dy + 20), radius: 30), 0, 3.14, false, mouthPaint);

    // Party hat placeholder (expand for confetti)
    if (type == 'Party Heart') {
      final hatPaint = Paint()..color = const Color(0xFFFFD54F);
      final hatPath = Path()
        ..moveTo(center.dx, center.dy - 110)
        ..lineTo(center.dx - 40, center.dy - 40)
        ..lineTo(center.dx + 40, center.dy - 40)
        ..close();
      canvas.drawPath(hatPath, hatPaint);
    }
  }

  @override
  bool shouldRepaint(covariant HeartEmojiPainter oldDelegate) => oldDelegate.type != type;

}

class BalloonCelebrationWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        size: Size(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height),
        painter: BalloonPainter(),
      ),
    );
  }
}

class BalloonPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final colors = [Colors.red, Colors.blue, Colors.green, Colors.yellow, Colors.purple, Colors.orange];
    final random = Random();
    final heartRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: 320, // slightly larger than heart
      height: 320,
    );
    int balloonsDrawn = 0;
    int attempts = 0;
    while (balloonsDrawn < 20 && attempts < 100) {
      final x = random.nextDouble() * (size.width - 40) + 20;
      final y = random.nextDouble() * (size.height - 120) + 60;
      final balloonRect = Rect.fromCenter(center: Offset(x, y), width: 40, height: 60);
      if (!balloonRect.overlaps(heartRect)) {
        final paint = Paint()..color = colors[balloonsDrawn % colors.length];
        canvas.drawOval(balloonRect, paint);
        // Balloon string
        final stringPaint = Paint()
          ..color = Colors.black
          ..strokeWidth = 2;
        canvas.drawLine(Offset(x, y + 30), Offset(x, y + 60), stringPaint);
        balloonsDrawn++;
      }
      attempts++;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}