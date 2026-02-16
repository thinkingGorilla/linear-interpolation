part of 'main.dart';

Offset lerpOffset(Offset start, Offset end, double interval) {
  return Offset(
    start.dx + (end.dx - start.dx) * interval,
    start.dy + (end.dy - start.dy) * interval,
  );
}

/// n개의 제어점을 같은 interval(t) 비율로 선형 보간하면서
/// 점의 개수를 1개가 될 때까지 반복적으로 줄인다.
///
/// 각 단계에서는 인접한 두 점을 lerp하여 새로운 점 배열을 만든다.
/// 이 과정을 반복하면 점의 개수는 다음과 같이 감소한다:
///
/// n → n-1 → n-2 → ... → 2 → 1
///
/// 예시 (5개 점일 경우):
///
/// 0단계: P0, P1, P2, P3, P4
///   → Q0 = lerp(P0, P1, t)
///   → Q1 = lerp(P1, P2, t)
///   → Q2 = lerp(P2, P3, t)
///   → Q3 = lerp(P3, P4, t)
///
/// 1단계: Q0, Q1, Q2, Q3
///   → R0 = lerp(Q0, Q1, t)
///   → R1 = lerp(Q1, Q2, t)
///   → R2 = lerp(Q2, Q3, t)
///
/// 2단계: R0, R1, R2
///   → S0 = lerp(R0, R1, t)
///   → S1 = lerp(R1, R2, t)
///
/// 3단계: S0, S1
///   → T0 = lerp(S0, S1, t)
///
/// 4단계: T0 하나만 남으므로 반환
///
/// 최종 남는 점이 t 위치의 베지에 곡선 위 점이다.
Offset bezierN(List<Offset> points, double interval) {
  List<Offset> temp = List.from(points);

  while (temp.length > 1) {
    List<Offset> next = [];

    for (int i = 0; i < temp.length - 1; i++) {
      next.add(lerpOffset(temp[i], temp[i + 1], interval));
    }

    temp = next;
  }

  return temp.first;
}

class BezierCurvePage extends StatefulWidget {
  const BezierCurvePage({super.key});

  @override
  State<BezierCurvePage> createState() => _BezierCurvePageState();
}

class _BezierCurvePageState extends State<BezierCurvePage> {
  final Random random = Random();

  int pointCount = 4;
  List<Offset> points = [];

  int? draggingIndex;

  static const double visualRadius = 8;
  static const double hitRadius = 30;
  static const double hitRadiusSquared = hitRadius * hitRadius;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() => generateLinearPoints()));
  }

  void generateLinearPoints() {
    final size = MediaQuery.of(context).size;
    final Offset start = Offset(100, size.height * 0.3);
    final Offset end = Offset(size.width - 100, size.height * 0.3);

    points = List.generate(pointCount, (i) {
      double t = i / (pointCount - 1);

      return Offset(
        start.dx + (end.dx - start.dx) * t,
        start.dy + (end.dy - start.dy) * t,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Bezier Curve")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text("Point Count: $pointCount"),
                Slider(
                  min: 2,
                  max: 10,
                  divisions: 8,
                  value: pointCount.toDouble(),
                  onChanged: (value) {
                    setState(() {
                      pointCount = value.toInt();
                      generateLinearPoints();
                    });
                  },
                ),
                ElevatedButton(
                  onPressed: () => setState(() => generateLinearPoints()),
                  child: const Text("Regenerate Points"),
                ),
              ],
            ),
          ),
          Expanded(
            child: GestureDetector(
              onPanStart: (details) {
                for (int i = 0; i < points.length; i++) {
                  final dx = points[i].dx - details.localPosition.dx;
                  final dy = points[i].dy - details.localPosition.dy;
                  final distSquared = dx * dx + dy * dy;

                  if (distSquared < hitRadiusSquared) {
                    draggingIndex = i;
                    break;
                  }
                }
              },
              onPanUpdate: (details) {
                if (draggingIndex != null) {
                  setState(() => points[draggingIndex!] = details.localPosition);
                }
              },
              onPanEnd: (_) => draggingIndex = null,
              child: CustomPaint(
                size: Size.infinite,
                painter: BezierPainter(points, draggingIndex, visualRadius),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BezierPainter extends CustomPainter {
  final List<Offset> points;
  final int? draggingIndex;
  final double visualRadius;

  BezierPainter(this.points, this.draggingIndex, this.visualRadius);

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 1;

    final curvePaint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final pointPaint = Paint()..color = Colors.red;
    final activePaint = Paint()..color = Colors.orange;

    // 제어선 그리기
    for (int i = 0; i < points.length - 1; i++) {
      canvas.drawLine(points[i], points[i + 1], linePaint);
    }

    // 곡선 그리기
    // 점들을 이어서 곡선처럼 보이게 한다.
    final path = Path();
    path.moveTo(points.first.dx, points.first.dy);

    const segments = 200;

    for (int i = 1; i <= segments; i++) {
      double interval = i / segments;
      final point = bezierN(points, interval);
      path.lineTo(point.dx, point.dy);
    }

    canvas.drawPath(path, curvePaint);

    // 제어점 그리기
    for (int i = 0; i < points.length; i++) {
      canvas.drawCircle(
        points[i],
        visualRadius,
        i == draggingIndex ? activePaint : pointPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
