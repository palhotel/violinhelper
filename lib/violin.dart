import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_midi/flutter_midi.dart';
import 'package:flutter/services.dart';
import 'package:flutter/animation.dart';
import 'package:pitchdetector/pitchdetector.dart';
import 'package:violin_helper/accuracy.dart';
import 'package:violin_helper/musicnote.dart';

import 'fingerboard.dart';
import 'leftarea.dart';
const map = {
  "G3":196.00,
  "G#3/Ab3":207.65,
  "A3":220.00,
  "A#3/Bb3":233.08,
  "B3":246.94,
  "C4":261.63,
  "C#4/Db4":277.18,
  "D4":293.66,
  "D#4/Eb4":311.13,
  "E4":329.63,
  "F4":349.23,
  "F#4":369.99,
  "G4":392.00,
  "G#4/Ab4":415.30,
  "A4":440.00,
  "A#4/Bb4":466.16,
  "B4":493.88,
  "C5":523.25,
  "C#5/Db5":554.37,
  "D5":587.33,
  "D#5/Eb5":622.25,
  "E5":659.25,
  "F5":698.46,
  "F#5":739.99,
  "G5":783.99,
  "G#5/Ab5":830.61,
  "A5":880.00,
  "A#5/Bb5":932.33,
  "B5":987.77,
  "C6":1046.50,
  "C#6/Db6":1108.73,
  "D6":1174.66,
  "D#6/Eb6":1244.51,
  "E6":1318.51,
  "F6":1396.91,
  "F#6":1479.98,
  "G6":1567.98,
  "G#6":1661.22,
  "A6":1760.00
};
bool drawDecorations = true;

class Violin extends StatefulWidget {
  @override
  createState() => _Violin();
}

class _Violin extends State<Violin> with SingleTickerProviderStateMixin {
  Animation<double> animation;
  AnimationController controller;
  Pitchdetector detector = new Pitchdetector(sampleRate: 44100, sampleSize: 4096);
  bool isRecording = false;
  double pitch = 440.0;
  double pitchdelta = 0;
  String pitchstr = 'A4';
  Map reverseMap = new Map();

  final gstring = 55;
  final dstring = 62;
  final astring = 69;
  final estring = 76;

  bool gplay = false;
  bool dplay = false;
  bool aplay = false;
  bool eplay = false;

  double screenWidth = 0;
  double screenHeight = 0;
  double verticalPadding = 0;
  double padding = 1;

  List<MusicNote> musicNotes = List<MusicNote>();
  final _flutterMidi = FlutterMidi();

  void startRecording()  async{
    await detector.startRecording();
  }

  @override
  void initState() {
    controller = new AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: this);
    final CurvedAnimation curve = CurvedAnimation(parent: controller, curve: Curves.easeInOutSine);
    var tween1 = new Tween(begin: -2.0, end: 2.0);
    var tween2 = new Tween(begin: 2.0, end: -2.0);
    var tweenItem1 = new TweenSequenceItem(tween: tween1, weight: 1);
    var tweenItem2 = new TweenSequenceItem(tween: tween2, weight: 1);
    var sequence = new TweenSequence([
      tweenItem1,tweenItem2,tweenItem1,tweenItem2,tweenItem1,tweenItem2,tweenItem1,tweenItem2,
      tweenItem1,tweenItem2,tweenItem1,tweenItem2,tweenItem1,tweenItem2,tweenItem1,tweenItem2,
      tweenItem1,tweenItem2,tweenItem1,tweenItem2,tweenItem1,tweenItem2,tweenItem1,tweenItem2
    ]);
    animation = sequence.animate(curve);

    _flutterMidi.unmute();
    rootBundle.load("resource/zzz.sf2").then((sf2) {
      _flutterMidi.prepare(sf2: sf2, name: "zzz.sf2");
    });
    map.forEach((key, value) {
      reverseMap[value] = key;
    });

    detector.onRecorderStateChanged.listen((event) {
      print("event " + event.toString());
      if(event.toString() == "-1.0"){
        return;
      }
      setState(() {
        pitch = event["pitch"];
        getMusicNote();
      });
    });

    super.initState();
    startRecording();
  }

  dispose() {
    controller?.dispose();
    super.dispose();
  }

  getMusicNote() {
    var list = reverseMap.keys;
    var min = 99999.0;
    var idx = 0;
    for(var i = 0; i < list.length; i++){
      var absValue = (list.elementAt(i) - this.pitch).abs();
      if(absValue < min){
        min = absValue;
        idx = i;
      }
    }
    this.pitchstr = reverseMap[list.elementAt(idx)];
    this.pitchdelta = this.pitch - list.elementAt(idx);
    MusicNote targetNote = MusicNote.fromPitch(pitchstr, this.pitch, map, reverseMap);
    //find targetNote in musicNotes list
    for(MusicNote note in musicNotes){
      if(note.text == targetNote.text){

        setState(() {
          note.accuracy = targetNote.accuracy;
        });
        new Future.delayed(new Duration(seconds: 1), () {
          setState(() {
            note.accuracy = Accuracy.NONE;
          });
        });
      }
    }
  }

  void playAndStop(int midi, int seconds) {
    _flutterMidi.playMidiNote(midi: midi);
    controller.reset();
    controller.forward();
    new Future.delayed(new Duration(seconds: seconds), () {
      _flutterMidi.stopMidiNote(midi: midi);
    });
  }

  void gotoAbout() {
    debugPrint("go to about");
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: SafeArea(
        child: SizedBox.expand(
          child: buildRealWidget(context),
        ),
      ),
    );
  }

  void TapDown(TapDownDetails details){
    var x = details.localPosition.dx;
    var y = details.localPosition.dy;

    var clientWidth = screenWidth / 2 - padding;
    const toLeft = 16;
    const radius = 36.0;
    var boarderLeft = clientWidth * 0.2;
    var boardWidth = clientWidth - boarderLeft;

    double xStart = boarderLeft + toLeft + screenWidth / 2; // start point of the G string
    double delta = (boardWidth - toLeft * 2) / 3; //distance between two strings

    if (x >= xStart - radius && x <= xStart + radius) {
      //G String
      double min = 36;
      MusicNote matched = null;
      for(MusicNote note in this.musicNotes){
        if(note.strings == 'G' && (note.y - y).abs() < min){
          min = (note.y - y).abs();
          matched = note;
        }
      }
      if(matched != null){
        pitch = map[matched.text];
        getMusicNote();
        playAndStop(matched.midi, 1);
      } else {
        pitch = map['G3'];
        getMusicNote();
        playAndStop(gstring, 1);
      }
      setState(() {
        gplay = true;
        dplay = false;
        aplay = false;
        eplay = false;
      });
      new Future.delayed(new Duration(seconds: 1), () {
        setState(() {
          gplay = false;
        });
      });
    } else if (x >= xStart + delta - radius && x <= xStart + delta + radius) {
      //D String
      double min = 36;
      MusicNote matched = null;
      for(MusicNote note in this.musicNotes){
        if(note.strings == 'D' && (note.y - y).abs() < min){
          min = (note.y - y).abs();
          matched = note;
        }
      }
      if(matched != null){
        pitch = map[matched.text];
        getMusicNote();
        playAndStop(matched.midi, 1);
      } else {
        pitch = map['D4'];
        getMusicNote();
        playAndStop(dstring, 1);
      }
      setState(() {
        gplay = false;
        dplay = true;
        aplay = false;
        eplay = false;
      });
      new Future.delayed(new Duration(seconds: 1), () {
        setState(() {
          dplay = false;
        });
      });
    } else if (x >= xStart + delta * 2 - radius && x <= xStart + delta * 2 + radius) {
      //A String
      double min = 36;
      MusicNote matched = null;
      for(MusicNote note in this.musicNotes){
        if(note.strings == 'A' && (note.y - y).abs() < min){
          min = (note.y - y).abs();
          matched = note;
        }
      }
      if(matched != null){
        pitch = map[matched.text];
        getMusicNote();
        playAndStop(matched.midi, 1);
      } else {
        pitch = map['A4'];
        getMusicNote();
        playAndStop(astring, 1);
      }
      setState(() {
        gplay = false;
        dplay = false;
        aplay = true;
        eplay = false;
      });
      new Future.delayed(new Duration(seconds: 1), () {
        setState(() {
          aplay = false;
        });
      });
    } else if (x >= xStart + delta * 3 - radius && x <= xStart + delta * 3 + radius) {
      //E String
      double min = 36;
      MusicNote matched = null;
      for(MusicNote note in this.musicNotes){
        if(note.strings == 'E' && (note.y - y).abs() < min){
          min = (note.y - y).abs();
          matched = note;
        }
      }
      if(matched != null){
        pitch = map[matched.text];
        getMusicNote();
        playAndStop(matched.midi, 1);
      } else {
        pitch = map['E5'];
        getMusicNote();
        playAndStop(estring, 1);
      }
      setState(() {
        gplay = false;
        dplay = false;
        aplay = false;
        eplay = true;
      });
      new Future.delayed(new Duration(seconds: 1), () {
        setState(() {
          eplay = false;
        });
      });
    }
  }
  
  Widget buildRealWidget(BuildContext context) {
    var allSize = MediaQuery.of(context).size;
    RenderBox renderBox = context.findRenderObject();
    Size size;
    if(renderBox == null){
      size = allSize;
    } else {
      size = renderBox.size;
    }
    this.screenWidth = size.width;
    this.screenHeight = size.height;

    var paddingObj = MediaQuery.of(context).padding;
    this.verticalPadding = paddingObj.top + paddingObj.bottom;

    return new Scaffold(
      body: Center(
          child: new GestureDetector(
              onTap: () {},
              onTapDown: TapDown,
              child: Container(
                child: Row(
                  children: [
                    new LeftArea(
                        animation: animation,
                        pitchstr: pitchstr,
                        pitchdelta: pitchdelta,
                        maxwidth: size.width / 2 - padding,
                        maxheight: size.height - verticalPadding
                    ),
                    new AnimatedViolin(
                        animation: animation,
                        gplay: this.gplay,
                        dplay: this.dplay,
                        aplay: this.aplay,
                        eplay: this.eplay,
                        pitchstr: pitchstr,
                        pitchdelta: pitchdelta,
                        map: map,
                        reverseMap: reverseMap,
                        musicNotes: musicNotes,
                        maxwidth: size.width / 2 - padding,
                      maxheight: size.height - verticalPadding,
                    ),
                  ],
                ),
                decoration:
                    new BoxDecoration(color: Color.fromRGBO(196, 96, 64, 1)),
              ))),
      // persistentFooterButtons: <Widget>[
      //   Text.rich(
      //     TextSpan(text: 'Violin Pitch Helper',
      //         recognizer: TapGestureRecognizer()..onTap=(){
      //           showDialog(
      //               context: context,
      //               builder: (ctx) {
      //                 return SimpleDialog(
      //                   title: Text("About", textAlign: TextAlign.center,),
      //                   titlePadding: EdgeInsets.all(10),
      //                   elevation: 5,
      //                   shape: RoundedRectangleBorder(
      //                       borderRadius: BorderRadius.all(Radius.circular(6))),
      //                   children: <Widget>[
      //                     ListTile(
      //                       title: Center(child: Text("Violin Pitch Helper (v1.0)"),),
      //                     ),
      //                     ListTile(
      //                       title: Center(child: Text("Hide / Show all decorations"),),
      //                       onTap: (){
      //                         setState(() {
      //                           drawDecorations = !drawDecorations;
      //                         });
      //                       },
      //                     ),
      //                     ListTile(
      //                       title: Center(child: Text("you@likeada.com"),),
      //                     ),
      //                     ListTile(
      //                       title: Center(child: Text("Close"),),
      //                       onTap: (){
      //                         Navigator.pop(context);
      //                       },
      //                     ),
      //                   ],
      //                 );
      //               });
      //         },
      //         style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18))
      //   )
      // ],
    );
  }
}

class AnimatedViolin extends AnimatedWidget {
  AnimatedViolin(
      {Key key,
      Animation<double> animation,
      this.gplay,
      this.dplay,
      this.aplay,
      this.eplay,
      this.pitchstr,
      this.pitchdelta,
      this.map,
      this.reverseMap,
      this.musicNotes,
      this.maxwidth,
      this.maxheight})
      : super(key: key, listenable: animation);
  double maxwidth;
  double maxheight;
  bool gplay;
  bool dplay;
  bool aplay;
  bool eplay;
  String pitchstr;
  double pitchdelta;
  Map map;
  Map reverseMap;
  List<MusicNote> musicNotes;

  Widget build(BuildContext context) {
    final Animation<double> animation = listenable;
    var containerHeight = maxheight;
    return new Center(
      child: new Container(
          width: maxwidth,
          height: containerHeight,
          child: ClipRect(
            child: CustomPaint(
                painter: FingerBoard.withSize(maxwidth, containerHeight, 0, 0,
                    gplay, dplay, aplay, eplay, animation, pitchstr, pitchdelta,
                    map, reverseMap, musicNotes, drawDecorations)),
          )),
    );
  }
}
