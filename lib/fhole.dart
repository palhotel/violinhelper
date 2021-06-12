import 'package:flutter/material.dart';

class FHole extends CustomPainter {
  double clientWidth = 300;
  double clientHeight = 400;
  double clientLeft = 0;
  double clientTop = 0;
  TextPainter _fHolePaint;

  FHole() {
    initPaints();
  }
  FHole.withSize(double w, double h) {
    this.clientWidth = w;
    this.clientHeight = h;
    initPaints();
  }

  void initPaints() {
    _fHolePaint = TextPainter(
        textAlign: TextAlign.center, textDirection: TextDirection.rtl);
  }

  //child: Text('f', style: new TextStyle(fontFamily: 'Georgia', fontSize: 64, fontStyle: FontStyle.italic)),
  @override
  void paint(Canvas canvas, Size size) {
    _fHolePaint.text = new TextSpan(
        text: 'f',
        style: TextStyle(
          color: Colors.black,
          fontFamily: 'Georgia',
          fontStyle: FontStyle.italic,
          fontWeight: FontWeight.bold,
          fontSize: 128,
        ));
    _fHolePaint.layout();
    _fHolePaint.paint(canvas, new Offset(clientWidth - 128, clientHeight - 120));
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
