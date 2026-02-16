part of 'main.dart';

class DottedLinePage extends StatefulWidget {
  const DottedLinePage({super.key});

  @override
  State<DottedLinePage> createState() => _DottedLinePageState();
}

class _DottedLinePageState extends State<DottedLinePage> {
  Offset start = const Offset(100, 200);
  Offset end = const Offset(600, 300);
  int numDots = 20;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Dotted Line Lerp")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                    "Number of Dots: $numDots",
                    style: const TextStyle(fontSize: 18)
                ),
                Slider(
                  min: 2,
                  max: 50,
                  divisions: 48,
                  value: numDots.toDouble(),
                  onChanged: (value) => setState(() => numDots = value.toInt()),
                )
              ],
            ),
          ),
          Expanded(
            child: GestureDetector(
              onPanUpdate: (details) {
                setState(() => end = details.localPosition);
              },
              child: CustomPaint(
                size: Size.infinite,
                painter: DottedLinePainter(start, end, numDots),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DottedLinePainter extends CustomPainter {
  final Offset start;
  final Offset end;
  final int numDots;

  DottedLinePainter(this.start, this.end, this.numDots);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    double space = 1 / (numDots - 1);

    for (int i = 0; i < numDots; i++) {
      double t = i * space;
      double x = lerpValue(start.dx, end.dx, t);
      double y = lerpValue(start.dy, end.dy, t);

      canvas.drawCircle(Offset(x, y), 4, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
