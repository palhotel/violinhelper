import 'package:flutter/material.dart';

class MusicSheet extends CustomPainter {
  double clientWidth = 300;
  double clientHeight = 400;
  double clientLeft = 0;
  double clientTop = 0;
  TextPainter _sheetPainter;
  String note;

  MusicSheet() {
    initPaints();
  }
  MusicSheet.withSize(double w, double h, String note) {
    this.clientWidth = w;
    this.clientHeight = h;
    this.note = note;
    initPaints();
  }

  void initPaints() {
    _sheetPainter = TextPainter(
        textAlign: TextAlign.center, textDirection: TextDirection.rtl);
  }

  //child: Text('f', style: new TextStyle(fontFamily: 'Georgia', fontSize: 64, fontStyle: FontStyle.italic)),
  @override
  void paint(Canvas canvas, Size size) {
    _sheetPainter.text = new TextSpan(
        text: note,
        style: TextStyle(
          color: Colors.black,
          fontFamily: 'Georgia',
          fontStyle: FontStyle.italic,
          fontWeight: FontWeight.bold,
          fontSize: 64,
        ));
    _sheetPainter.layout();
    _sheetPainter.paint(canvas, new Offset(40, 24));
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

