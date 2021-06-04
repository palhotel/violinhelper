import 'package:flutter/material.dart';
import 'musicnote.dart';
import 'accuracy.dart';

class FingerBoard extends CustomPainter {
  FingerBoard() {
    initPaints();
  }
  FingerBoard.withSize(double w, double h, double l, double t, bool gplay,
      bool dplay, bool aplay, bool eplay, Animation<double> animation,
      String pitchstr, double pitchdelta, Map map, Map reverseMap, List<MusicNote> musicNotes) {
    this.clientLeft = l;
    this.clientTop = t;
    this.clientWidth = w;
    this.clientHeight = h;
    this.gplay = gplay;
    this.dplay = dplay;
    this.aplay = aplay;
    this.eplay = eplay;
    this.animation = animation;
    this.pitchdelta = pitchdelta;
    this.pitchstr = pitchstr;
    this.map = map;
    this.reverseMap = reverseMap;
    this.musicNotes = musicNotes;
    initPaints();
  }
  bool gplay;
  bool dplay;
  bool aplay;
  bool eplay;
  String pitchstr;
  double pitchdelta;
  Map map;
  Map reverseMap;
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
    if(this.musicNotes.length > 0){
      return;
    }
    double xStart = clientLeft + toLeft;
    double yStart = clientTop + 14;
    double delta = (clientWidth - toLeft * 2) / 3;
    MusicNote g = MusicNote(xStart, yStart, 55, 'G3', 'G');
    MusicNote d = MusicNote(xStart + delta, yStart, 62, 'D4', 'D');
    MusicNote a = MusicNote(xStart + delta * 2, yStart, 69, 'A4', 'A');
    MusicNote e = MusicNote(xStart + delta * 3, yStart, 76, 'E5', 'E');

    musicNotes.addAll([g, d, a, e]);
    var boardHeight = clientHeight * 0.8;
    var maxHeight = boardHeight * 0.9;
    var every = maxHeight / 18;
    var keys = map.keys;

    //compute all music notes in G String
    var idx = 0;
    for(var i = 1; i <= 17; i++){
      idx ++;
      MusicNote note = MusicNote.fromPitch(keys.elementAt(i), map[keys.elementAt(i)], map, reverseMap);
      note.accuracy = Accuracy.NONE;
      note.x = xStart;
      note.y = yStart + idx * every;
      note.strings = 'G';
      musicNotes.add(note);
    }

    //compute all music notes in D String
    idx = 0;
    for(var i = 8; i <= 24; i++){
      idx ++;
      MusicNote note = MusicNote.fromPitch(keys.elementAt(i), map[keys.elementAt(i)], map, reverseMap);
      note.accuracy = Accuracy.NONE;
      note.x = xStart + delta;
      note.y = yStart + idx * every;
      note.strings = 'D';
      musicNotes.add(note);
    }

    //compute all music notes in A String
    idx = 0;
    for(var i = 15; i <= 31; i++){
      idx ++;
      MusicNote note = MusicNote.fromPitch(keys.elementAt(i), map[keys.elementAt(i)], map, reverseMap);
      note.accuracy = Accuracy.NONE;
      note.x = xStart + delta * 2;
      note.y = yStart + idx * every;
      note.strings = 'A';
      musicNotes.add(note);
    }

    //compute all music notes in E String
    idx = 0;
    for(var i = 22; i <= 38; i++){
      idx ++;
      MusicNote note = MusicNote.fromPitch(keys.elementAt(i), map[keys.elementAt(i)], map, reverseMap);
      note.accuracy = Accuracy.NONE;
      note.x = xStart + delta * 3;
      note.y = yStart + idx * every;
      note.strings = 'E';
      musicNotes.add(note);
    }
  }

  void initPaints() {
    genrateMusicNotes();
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
