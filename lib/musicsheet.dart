import 'package:flutter/material.dart';

class MusicSheet extends CustomPainter {
  double clientWidth = 300;
  double clientHeight = 400;
  double clientLeft = 0;
  double clientTop = 0;
  double delta = 0;
  TextPainter _sheetPainter;
  TextPainter _accuracyPainter;
  Paint _scalePaint;
  Paint _cusorPaint;
  String note;

  MusicSheet() {
    initPaints();
  }
  MusicSheet.withSize(double w, double h, String note, double delta) {
    this.clientWidth = w;
    this.clientHeight = h;
    this.note = note;
    this.delta = delta;
    initPaints();
  }

  void initPaints() {
    _sheetPainter = TextPainter(
        textAlign: TextAlign.center, textDirection: TextDirection.rtl);
    _accuracyPainter = TextPainter(textAlign: TextAlign.center, textDirection: TextDirection.rtl);
    _scalePaint = Paint()
      ..color = Color.fromARGB(255, 224, 192, 128)
      ..strokeWidth = 6;
    _cusorPaint = Paint()
      ..color = Color.fromARGB(168, 255, 64, 128)
      ..strokeWidth = 6;
  }

  /**
   * x,y: center of the scale
   */
  void symmetricScale(Canvas canvas, double x, double y){
    var len = 60;
    for(var i = 0; i < 10; i++){
      canvas.drawLine(Offset(x + i * 10, y + i), Offset(x + i * 10, y + len - i * 2), _scalePaint);
      if(i > 0){
        canvas.drawLine(Offset(x - i * 10, y + i), Offset(x - i * 10, y + len - i * 2), _scalePaint);
      }
    }
  }

  void drawCusor(Canvas canvas, double x, double y, int idx, int flag){
    var len = 68;
    if(idx >= 10){
      idx = 9;
    } else if(idx < 0){
      idx = 0;
    }
    if(flag >= 0){
      canvas.drawLine(Offset(x + idx * 10, y - 4), Offset(x + idx * 10, y + len), _cusorPaint);
    } else {
      canvas.drawLine(Offset(x - idx * 10, y - 4 ), Offset(x - idx * 10, y + len), _cusorPaint);
    }
  }
  @override
  void paint(Canvas canvas, Size size) {
    _sheetPainter.text = new TextSpan(
        text: note,
        style: TextStyle(
          color: Colors.black,
          fontFamily: 'Georgia',
          fontStyle: FontStyle.italic,
          fontWeight: FontWeight.bold,
          fontSize: 32,
        ));
    _sheetPainter.layout();
    _sheetPainter.paint(canvas, new Offset(this.clientWidth /2 - 16 * note.length / 2, 24));

    //drawscales
    symmetricScale(canvas, this.clientWidth / 2 - 1, 64);
    //draw cursor
    var idx = (delta.abs() / 3).round();
    var flag = 1;
    if(delta < 0){
      flag = -1;
    }
    var accuracy = 'Perfect';
    if(delta >= -4 && delta <= 4){
      accuracy = 'Perfect';
    } else if(delta >= -8 && delta <= 8){
      accuracy = 'Good';
    } else if(delta < -8){
      accuracy = 'Low';
    } else {
      accuracy = 'High';
    }
    var color = Colors.deepOrange;
    if(accuracy == "Perfect"){
      color = Colors.lime;
    } else if(accuracy == "Good"){
      color = Colors.amber;
    }
    _accuracyPainter.text = new TextSpan(
        text: accuracy,
        style: TextStyle(
          color: color,
          fontFamily: 'Georgia',
          fontStyle: FontStyle.italic,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ));
    _accuracyPainter.layout();
    _accuracyPainter.paint(canvas, new Offset(this.clientWidth /2 - 10 * accuracy.length / 2, 138));
    drawCusor(canvas, this.clientWidth / 2 - 1, 64, idx, flag);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

