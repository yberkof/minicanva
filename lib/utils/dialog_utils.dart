import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class DialogUtils {
  static showErrorDialog(
      {required String title,
      required String message,
      required BuildContext context}) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.error,
      animType: AnimType.rightSlide,
      title: title,
      desc: message,
      descTextStyle: const TextStyle(fontWeight: FontWeight.bold),
      btnOkOnPress: () {
        Navigator.popUntil(context, (route) => route.isFirst);
      },
      btnOk: GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: Container(
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.symmetric(vertical: 15),
          alignment: Alignment.center,
          decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(30)),
              boxShadow: <BoxShadow>[
                BoxShadow(
                    color: _getColor(50),
                    offset: const Offset(2, 4),
                    blurRadius: 5,
                    spreadRadius: 2)
              ],
              gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [Colors.red.shade400, Colors.red.shade900])),
          child: Text(
            "Ok",
            style: TextStyle(
              fontSize: 30,
              color: _getColor(50),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      dialogBorderRadius: BorderRadius.circular(30),
    ).show();
  }

  static showInfoDialog(
      {required String title,
      required String message,
      required BuildContext context,
      required VoidCallback btnOkOnPress}) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.info,
      animType: AnimType.rightSlide,
      title: title,
      desc: message,
      dismissOnBackKeyPress: false,
      dismissOnTouchOutside: false,
      descTextStyle: const TextStyle(fontWeight: FontWeight.bold),
      btnOkOnPress: btnOkOnPress,
      btnOk: GestureDetector(
        onTap: () {
          btnOkOnPress.call();
          Navigator.pop(context);
        },
        child: Container(
          width: 50.w,
          padding: const EdgeInsets.symmetric(vertical: 15),
          alignment: Alignment.center,
          decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(30)),
              boxShadow: <BoxShadow>[
                BoxShadow(
                    color: _getColor(50),
                    offset: const Offset(2, 4),
                    blurRadius: 5,
                    spreadRadius: 2)
              ],
              gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [Colors.blue.shade400, Colors.blue.shade900])),
          child: Text(
            "Ok",
            style: TextStyle(
              fontSize: 15.sp,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      dialogBorderRadius: BorderRadius.circular(30),
    ).show();
  }

  static showSuccessDialog({
    required String title,
    String? message,
    required BuildContext context,
    GestureTapCallback? onTap,
  }) {
    ;
    AwesomeDialog(
        dialogBorderRadius: BorderRadius.circular(30),
        context: context,
        dialogType: DialogType.success,
        animType: AnimType.rightSlide,
        title: title,
        desc: message,
        descTextStyle: const TextStyle(fontWeight: FontWeight.bold),
        btnOk: GestureDetector(
          onTap: () {
            if (onTap == null) {
              Navigator.of(context).pop();
            } else {
              onTap.call();
            }
          },
          child: Container(
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.symmetric(vertical: 15),
            alignment: Alignment.center,
            decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(30)),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                      color: _getColor(50),
                      offset: const Offset(2, 4),
                      blurRadius: 5,
                      spreadRadius: 2)
                ],
                gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Colors.greenAccent.shade200,
                      Colors.greenAccent.shade700
                    ])),
            child: Text(
              "Ok",
              style: TextStyle(
                fontSize: 30,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        )).show();
  }

  static Color _getColor(int code) => Color(0x9F1A237E);
}
