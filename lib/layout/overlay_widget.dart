import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sizer/sizer.dart';

import '../matrix_gesture_detector.dart';
import '../provider/drawer_provider.dart';
import '../provider/file_management_provider.dart';
import 'custom_paint.dart';

class OverlayWidget extends StatelessWidget {
  final Widget widget;
  final ValueNotifier<Matrix4> notifier;
 final bool isFinal;
  const OverlayWidget({super.key, required this.widget, required this.notifier, required this.isFinal});

  @override
  Widget build(BuildContext context) {
    return MatrixGestureDetector(
      clipChild: true,
      onMatrixUpdate: (m, tm, sm, rm) {
        notifier.value = m;
      },
      onScaleEnd: () {},
      onScaleStart: () {},
      child: AnimatedBuilder(
        animation: notifier,
        builder: (ctx, child) {
          return Transform(
            transform: notifier.value,
            child: Stack(
              children: [
                Container(
                  color: Colors.transparent,
                ),
                // Image.asset("assets/crop_bg.png",height: 20.h,width: 65.w,fit: BoxFit.fill,),
                Container(
                    child: Padding(
                      padding:  EdgeInsets.all(5.w),
                      child: widget,
                    )),
              ],
            ),
          );
        },
      ),
    );
  }
}
