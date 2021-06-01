import 'package:flutter/material.dart';
import 'musicnote.dart';
import 'accuracy.dart';

class FingerBoard extends CustomPainter {
  FingerBoard() {
    initPaints();
  }
  FingerBoard.withSize(double w, double h, double l, double t, bool gplay,
      bool dplay, bool aplay, bool eplay, Animation<double> animation) {
    this.clientLeft = l;
    this.clientTop = t;
    this.clientWidth = w;
    this.clientHeight = h;
    this.gplay = gplay;
    this.dplay = dplay;
    this.aplay = aplay;
    this.eplay = eplay;
    this.animation = animation;
    initPaints();
  }
  bool gplay;
  bool dplay;
  bool aplay;
  bool eplay;
  Paint _boardPaint;
  Paint _stringsPaint;
  Paint _carvePaint;
  Paint _notePaint;
  Paint _activeNotePaint;
  Paint _bridgePaint;
  TextPainter textPainter;
  double clientWidth = 300;
  double clientHeight = 400;
  double clientLeft = 0;
  double clientTop = 0;
  List<MusicNote> musicNotes;
  Animation<double> animation;

  static const toLeft = 16;
  static const span = 32;

  void genrateMusicNotes() {
    musicNotes = List<MusicNote>();
    double xStart = clientLeft + toLeft;
    double yStart = clientTop + 14;
    double delta = (clientWidth - toLeft * 2) / 3;
    MusicNote g = MusicNote(xStart, yStart, 55, 'G');
    MusicNote d = MusicNote(xStart + delta, yStart, 62, 'D');
    MusicNote a = MusicNote(xStart + delta * 2, yStart, 69, 'A');
    MusicNote e = MusicNote(xStart + delta * 3, yStart, 76, 'E');
    g.accuracy = Accuracy.GOOD;
    musicNotes.addAll([g, d, a, e]);
  }

  void initPaints() {
    _boardPaint = Paint()..color = Color.fromARGB(255, 64, 64, 64);
    _stringsPaint = Paint()
      ..color = Color.fromARGB(255, 220, 220, 220)
      ..strokeWidth = 4;
    _carvePaint = Paint()
      ..color = Color.fromARGB(200, 192, 162, 128)
      ..strokeWidth = 2;
    _notePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = Colors.white;
    _activeNotePaint = Paint()
      ..style = PaintingStyle.fill
      ..strokeWidth = 2
      ..color = Color.fromARGB(128, 64, 240, 64);
    _bridgePaint = Paint()
      ..color = Color.fromARGB(255, 240, 192, 128)
      ..strokeWidth = 4;
    textPainter = TextPainter(
        textAlign: TextAlign.center, textDirection: TextDirection.rtl);
    genrateMusicNotes();
  }

  void drawString(
      Canvas canvas, Offset start, Offset end, Paint painter, bool shake) {
    if (shake) {
      //find middle and add offset
      var offset = animation.value;
      Offset middle =
      Offset((start.dx + end.dx) / 2 + offset, (start.dy + end.dy) / 2);
      canvas.drawLine(start, middle, painter);
      canvas.drawLine(middle, end, painter);
    } else {
      canvas.drawLine(start, end, painter);
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    var boardHeight = clientHeight * 0.8;
    var bridgeTop = clientHeight - 32;

    canvas.drawRect(
        Rect.fromLTWH(clientLeft, clientTop, clientWidth, boardHeight),
        _boardPaint);
    double xStart = clientLeft + toLeft;
    double yStart = clientTop + 32;
    double delta = (clientWidth - toLeft * 2) / 3;
    double stringsLen = clientHeight;
    //Draw pillow
    canvas.drawLine(Offset(clientLeft, clientTop + 32),
        Offset(clientWidth, clientTop + 32), _carvePaint);
    canvas.drawLine(
        Offset(xStart, clientTop),
        Offset(xStart, yStart),
        _stringsPaint
          ..strokeWidth = 4
          ..color = Color.fromARGB(128, 220, 220, 220));
    canvas.drawLine(
        Offset((xStart + delta), clientTop),
        Offset(xStart + delta, yStart),
        _stringsPaint
          ..strokeWidth = 3
          ..color = Color.fromARGB(128, 220, 220, 220));
    canvas.drawLine(
        Offset((xStart + delta * 2), clientTop),
        Offset((xStart + delta * 2), yStart),
        _stringsPaint
          ..strokeWidth = 2
          ..color = Color.fromARGB(128, 220, 220, 220));
    canvas.drawLine(
        Offset((xStart + delta * 3), clientTop),
        Offset((xStart + delta * 3), yStart),
        _stringsPaint
          ..strokeWidth = 1
          ..color = Color.fromARGB(128, 220, 220, 220));

    //Draw Bridge
    canvas.drawLine(Offset(clientLeft, bridgeTop),
        Offset(clientWidth, bridgeTop), _bridgePaint);

    _stringsPaint..color = Color.fromARGB(255, 220, 220, 220);
    //Draw G
    drawString(canvas, Offset(xStart, yStart), Offset(xStart, stringsLen),
        _stringsPaint..strokeWidth = 4, gplay);
    //Draw D
    drawString(
        canvas,
        Offset((xStart + delta), yStart),
        Offset(xStart + delta, stringsLen),
        _stringsPaint..strokeWidth = 3,
        dplay);
    //Draw A
    drawString(
        canvas,
        Offset((xStart + delta * 2), yStart),
        Offset((xStart + delta * 2), stringsLen),
        _stringsPaint..strokeWidth = 2,
        aplay);
    //Draw E
    drawString(
        canvas,
        Offset((xStart + delta * 3), yStart),
        Offset((xStart + delta * 3), stringsLen),
        _stringsPaint
          ..strokeWidth = 1
          ..color = Colors.white,
        eplay);

    //Draw Music Notes
    this.musicNotes.forEach((note) {
      if (note.accuracy == Accuracy.GOOD) {
        canvas.drawCircle(
            Offset(note.x, note.y), delta / 10, _activeNotePaint..style);
        canvas.save();
        textPainter.text = new TextSpan(
          text: note.text,
          style: TextStyle(
            color: Colors.white,
            decorationColor: Colors.amberAccent,
            decorationStyle: TextDecorationStyle.solid,
            fontFamily: 'Times New Roman',
            fontWeight: FontWeight.bold,
            fontSize: 12.0,
          ),
        );
        textPainter.layout();
        textPainter.paint(canvas, new Offset(note.x - 6, note.y - 6));
        canvas.restore();
      } else {
        canvas.drawCircle(Offset(note.x, note.y), delta / 10, _notePaint);
      }
    });
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
