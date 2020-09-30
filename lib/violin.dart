import 'package:flutter/material.dart';
import 'package:flutter_midi/flutter_midi.dart';
import 'package:flutter/services.dart';
import 'package:flutter/animation.dart';

class Violin extends StatefulWidget {
  @override
  createState() => _Violin();
}

class _Violin extends State<Violin> with SingleTickerProviderStateMixin {
  Animation<double> animation;
  AnimationController controller;

  final gstring = 55;
  final dstring = 62;
  final astring = 69;
  final estring = 76;

  @override
  void initState() {
    controller = new AnimationController(
        duration: const Duration(milliseconds: 2000), vsync: this);
    animation = new Tween(begin: 10.0, end: 400.0).animate(controller);
    controller.forward();

    FlutterMidi.unmute();
    rootBundle.load("resource/violin.sf2").then((sf2) {
      FlutterMidi.prepare(sf2: sf2, name: "violin.sf2");
    });
    super.initState();
  }

  dispose() {
    controller?.dispose();
    super.dispose();
  }

  void playAndStop(int midi, int seconds) {
    FlutterMidi.playMidiNote(midi: midi);
    new Future.delayed(new Duration(seconds: seconds), () {
      FlutterMidi.stopMidiNote(midi: midi);
    });
  }

  void gotoAbout(){
    debugPrint("go to about");
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: Center(
          child: new GestureDetector(
            onTap: () {
              controller.reset();
              controller.forward();
              playAndStop(astring, 2);
            },
            child: Container(
              child: Row(
                children: [
                  new LeftArea(animation: animation),
                  new AnimatedViolin(animation: animation),
                ],
              ),
              decoration: new BoxDecoration(
                color: Color.fromRGBO(196, 96, 64, 1)
              ),
            )
          )
      ),
      persistentFooterButtons: <Widget>[
        Text('Violin Pitch Helper', style: new TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        new IconButton(tooltip: 'Check New Version', icon: new Icon(Icons.update), onPressed: gotoAbout,)
      ],
    );
  }
}

//The accuracy of the pitch
enum Accuracy {
  NONE,
  GOOD,
  LOW,
  HIGH
}

class MusicNote {
  int midi;
  Accuracy accuracy = Accuracy.NONE;
  double x;
  double y;
  String text;

  MusicNote(double x, double y, int midi, String text){
    this.x = x;
    this.y = y;
    this.midi = midi;
    this.text = text;
  }
}

class FingerBoard extends CustomPainter {
  FingerBoard(){
    initPaints();
  }
  FingerBoard.withSize(double w, double h, double l, double t){
    this.clientLeft = l;
    this.clientTop = t;
    this.clientWidth = w;
    this.clientHeight = h;
    initPaints();
  }
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

  static const toLeft = 16;
  static const span = 32;

  void genrateMusicNotes(){
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

  void initPaints(){
    _boardPaint = Paint()
      ..color = Color.fromARGB(255, 64, 64, 64);
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
    textPainter = TextPainter(textAlign: TextAlign.center, textDirection: TextDirection.rtl);
    genrateMusicNotes();
  }

  @override
  void paint(Canvas canvas, Size size) {
    var boardHeight = clientHeight * 0.8;
    var bridgeTop = clientHeight - 32;

    canvas.drawRect(Rect.fromLTWH(clientLeft, clientTop, clientWidth, boardHeight), _boardPaint);
    double xStart = clientLeft + toLeft;
    double yStart = clientTop + 32;
    double delta = (clientWidth - toLeft * 2) / 3;
    double stringsLen = clientHeight;
    //Draw pillow
    canvas.drawLine(Offset(clientLeft, clientTop + 32), Offset(clientWidth, clientTop + 32), _carvePaint);
    canvas.drawLine(Offset(xStart, clientTop), Offset(xStart, yStart), _stringsPaint..strokeWidth = 4..color=Color.fromARGB(128, 220, 220, 220));
    canvas.drawLine(Offset((xStart + delta), clientTop), Offset(xStart + delta, yStart), _stringsPaint..strokeWidth = 3..color=Color.fromARGB(128, 220, 220, 220));
    canvas.drawLine(Offset((xStart + delta * 2), clientTop), Offset((xStart + delta * 2), yStart), _stringsPaint..strokeWidth=2..color=Color.fromARGB(128, 220, 220, 220));
    canvas.drawLine(Offset((xStart + delta * 3), clientTop), Offset((xStart + delta * 3), yStart), _stringsPaint..strokeWidth=1..color=Color.fromARGB(128, 220, 220, 220));

    _stringsPaint..color = Color.fromARGB(255, 220, 220, 220);
    //Draw G
    canvas.drawLine(Offset(xStart, yStart), Offset(xStart, stringsLen), _stringsPaint..strokeWidth = 4);
    //Draw D
    canvas.drawLine(Offset((xStart + delta), yStart), Offset(xStart + delta, stringsLen), _stringsPaint..strokeWidth = 3);
    //Draw A
    canvas.drawLine(Offset((xStart + delta * 2), yStart), Offset((xStart + delta * 2), stringsLen), _stringsPaint..strokeWidth = 2);
    //Draw E
    canvas.drawLine(Offset((xStart + delta * 3), yStart), Offset((xStart + delta * 3), stringsLen), _stringsPaint..strokeWidth = 1..color=Colors.white);

    //Draw Bridge
    canvas.drawLine(Offset(clientLeft, bridgeTop), Offset(clientWidth, bridgeTop), _bridgePaint);

    //Draw Music Notes
    this.musicNotes.forEach((note) {
      if(note.accuracy == Accuracy.GOOD){
        canvas.drawCircle(Offset(note.x, note.y), delta / 10, _activeNotePaint..style);
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

class FHole extends CustomPainter{

  double clientWidth = 300;
  double clientHeight = 400;
  double clientLeft = 0;
  double clientTop = 0;
  TextPainter _fHolePaint;

  FHole(){
    initPaints();
  }
  FHole.withSize(double w, double h, double l, double t){
    this.clientLeft = l;
    this.clientTop = t;
    this.clientWidth = w;
    this.clientHeight = h;
    initPaints();
  }

  void initPaints(){
    _fHolePaint = TextPainter(textAlign: TextAlign.center, textDirection: TextDirection.rtl);
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
      )
    );
    _fHolePaint.layout();
    _fHolePaint.paint(canvas, new Offset(clientWidth - 128, clientHeight - 80));
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class LeftArea extends AnimatedWidget {
  LeftArea({Key key, Animation<double> animation})
      : super(key: key, listenable: animation);
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var realWidth = size.width * 0.6;
    var containerHeight = size.height - 84;
    return Center(
        child: Container(
            width: realWidth,
            height: containerHeight,
            child: ClipRect(
              child: CustomPaint(
                  painter:FHole.withSize(realWidth, containerHeight, 0, 18)
              ),
            )
        )
    );
  }
}

class AnimatedViolin extends AnimatedWidget {
  AnimatedViolin({Key key, Animation<double> animation})
      : super(key: key, listenable: animation);

  Widget build(BuildContext context) {
    final Animation<double> animation = listenable;
    var size = MediaQuery.of(context).size;
    var realLeft = size.width * 0.6;
    var realWidth = size.width - realLeft - 8;
    var containerHeight = size.height - 84;

    return new Center(
      child: new Container(
        width: realWidth,
        height: containerHeight,
        child: ClipRect(
          child: CustomPaint(
            painter: FingerBoard.withSize(realWidth, containerHeight, 0, 18)
          ),
        )
      ),
    );
  }
}
