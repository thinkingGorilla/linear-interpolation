part of 'main.dart';

class SmoothMovePage extends StatefulWidget {
  const SmoothMovePage({super.key});

  @override
  State<SmoothMovePage> createState() => _SmoothMovePageState();
}

class _SmoothMovePageState extends State<SmoothMovePage>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;

  Offset position = const Offset(200, 200);
  Offset target = const Offset(200, 200);

  double speed = 0.1;

  @override
  void initState() {
    super.initState();

    /// 매 프레임마다 setState를 호출 선형보간된 값이 렌더링 되도록 한다.
    /// start + (end - start) * t = position + (target - position) * speed
    ///
    ///  예) 목표까지의 거리가 100일 때
    ///  1프레임 : 10 이동 (100 * 0.1)
    ///  2프레임 : 9 이동(90 * 0.1)
    ///  3프레임 : 8.1 이동(81 * 0.1)
    ///  ...
    _ticker = createTicker((_) {
      setState(() {
        position = Offset(
          lerpValue(position.dx, target.dx, speed),
          lerpValue(position.dy, target.dy, speed),
        );
      });
    });

    _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Smooth Move Lerp")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  "Speed: ${speed.toStringAsFixed(2)}",
                  style: const TextStyle(fontSize: 18),
                ),
                Slider(
                  min: 0.01,
                  max: 0.2,
                  divisions: 19,
                  value: speed,
                  onChanged: (value) => setState(() => speed = value),
                ),
              ],
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTapDown: (details) => target = details.localPosition,
              child: Stack(
                children: [
                  CustomPaint(
                    size: Size.infinite,
                    painter: CirclePainter(position, target),
                  ),
                  Positioned(
                    left: 20,
                    top: 20,
                    child: Text(
                      "Position: (${position.dx.toStringAsFixed(1)}, "
                          "${position.dy.toStringAsFixed(1)})",
                    ),
                  ),
                  Positioned(
                    left: 20,
                    top: 40,
                    child: Text(
                      "Target: (${target.dx.toStringAsFixed(1)}, "
                          "${target.dy.toStringAsFixed(1)})",
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CirclePainter extends CustomPainter {
  final Offset position;
  final Offset target;

  CirclePainter(this.position, this.target);

  @override
  void paint(Canvas canvas, Size size) {
    final paintCircle = Paint()..color = Colors.red;
    final paintTarget = Paint()..color = Colors.green;

    canvas.drawCircle(position, 20, paintCircle);
    canvas.drawCircle(target, 6, paintTarget);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
