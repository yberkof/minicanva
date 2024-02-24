import 'dart:math';

import 'package:flutter/material.dart';
class ZoomPaint extends CustomPainter {

  var key;
  var image;
  ZoomPaint({required this.key,required this.image});
  @override
  void paint(Canvas canvas, Size size) {
    final keyContext = key.currentContext;
    // widget is visible
    final box = keyContext?.findRenderObject() as RenderBox;
    var rectWidth=box.size.width;
    var rectHeight=box.size.height;
    final rect = Rect.fromLTRB(
      0,0,150,100

      );
    const radius = 4.0;
    const strokeWidth = 6.0;
    const extend = radius + 24.0;
    const arcSize = Size.square(radius );
    canvas.drawImage(image, new Offset(0.0, 0.0), new Paint());
    canvas.drawPath(
      Path()
        ..fillType = PathFillType.evenOdd
        ..addRRect(
          RRect.fromLTRBR(
           0,0,100,100,
            const Radius.circular(radius*4),
          ).deflate(strokeWidth / 2),
        )
        ,
      Paint()..color = Colors.transparent,
    );

    canvas.save();
    canvas.translate(rect.left, rect.top);
    final path = Path();
    for (var i = 0; i < 4; i++) {
      final l = i & 1 == 0;
      final t = i & 2 == 0;
      path
        ..moveTo(l ? 0 : rectWidth, t ? extend : rectHeight - extend)
        ..arcTo(
            Offset(l ? 0 : rectWidth - arcSize.width,
                t ? 0 : rectHeight - arcSize.width) &
            arcSize,
            l ? pi : pi * 2,
            l == t ? pi / 2 : -pi / 2,
            false)
        ..lineTo(l ? extend : rectWidth - extend, t ? 0 : rectHeight);
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.blue
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(ZoomPaint oldDelegate) => false;
}