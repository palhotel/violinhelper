import 'package:flutter/material.dart';
import 'package:flutter_midi/flutter_midi.dart';
import 'package:flutter/services.dart';
import 'package:flutter/animation.dart';
import 'package:pitchdetector/pitchdetector.dart';
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
  "F#4/Gb4":369.99,
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
  "F#5/Gb5":739.99,
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
  "F#6/Gb6":1479.98,
  "G6":1567.98,
  "G#6/Ab6":1661.22,
  "A6":1760.00
};

class Violin extends StatefulWidget {
  @override
  createState() => _Violin();
}

class _Violin extends State<Violin> with SingleTickerProviderStateMixin {
  Animation<double> animation;
  AnimationController controller;
  Pitchdetector detector;
  bool isRecording = false;
  double pitch = 440.0;
  String pitchstr = 'A';
  Map reverseMap = new Map();

  final gstring = 55;
  final dstring = 62;
  final astring = 69;
  final estring = 76;

  bool gplay = false;
  bool dplay = false;
  bool aplay = false;
  bool eplay = false;

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

    FlutterMidi.unmute();
    rootBundle.load("resource/violin.sf2").then((sf2) {
      FlutterMidi.prepare(sf2: sf2, name: "violin.sf2");
    });
    map.forEach((key, value) {
      reverseMap[value] = key;
    });
    detector = new Pitchdetector(sampleRate: 44100, sampleSize: 4096);
    detector.onRecorderStateChanged.listen((event) {
      print("event " + event.toString());
      setState(() {
        pitch = event["pitch"];
        getMusicNote();
      });
    });
    detector.startRecording();
    super.initState();
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
  }

  void playAndStop(int midi, int seconds) {
    FlutterMidi.playMidiNote(midi: midi);
    controller.reset();
    controller.forward();
    new Future.delayed(new Duration(seconds: seconds), () {
      FlutterMidi.stopMidiNote(midi: midi);
    });
  }

  void gotoAbout() {
    debugPrint("go to about");
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: Center(
          child: new GestureDetector(
              onTap: () {},
              onTapDown: (TapDownDetails details) {
                var x = details.localPosition.dx;

                if (x >= 245 && x <= 275) {
                  playAndStop(gstring, 1);
                  setState(() {
                    gplay = true;
                    dplay = false;
                    aplay = false;
                    eplay = false;
                    pitch = 196.0;
                    getMusicNote();
                  });
                  new Future.delayed(new Duration(seconds: 1), () {
                    setState(() {
                      gplay = false;
                    });
                  });
                } else if (x >= 290 && x <= 320) {
                  playAndStop(dstring, 1);
                  setState(() {
                    gplay = false;
                    dplay = true;
                    aplay = false;
                    eplay = false;
                    pitch = 293.66;
                    getMusicNote();
                  });
                  new Future.delayed(new Duration(seconds: 1), () {
                    setState(() {
                      dplay = false;
                    });
                  });
                } else if (x >= 330 && x <= 360) {
                  playAndStop(astring, 1);
                  setState(() {
                    gplay = false;
                    dplay = false;
                    aplay = true;
                    eplay = false;
                    pitch = 440.0;
                    getMusicNote();
                  });
                  new Future.delayed(new Duration(seconds: 1), () {
                    setState(() {
                      aplay = false;
                    });
                  });
                } else if (x >= 375 && x <= 405) {
                  playAndStop(estring, 1);
                  setState(() {
                    gplay = false;
                    dplay = false;
                    aplay = false;
                    eplay = true;
                    pitch = 659.25;
                    getMusicNote();
                  });
                  new Future.delayed(new Duration(seconds: 1), () {
                    setState(() {
                      eplay = false;
                    });
                  });
                }
              },
              child: Container(
                child: Row(
                  children: [
                    new LeftArea(animation: animation, pitchstr: pitchstr),
                    new AnimatedViolin(
                        animation: animation,
                        gplay: this.gplay,
                        dplay: this.dplay,
                        aplay: this.aplay,
                        eplay: this.eplay),
                  ],
                ),
                decoration:
                    new BoxDecoration(color: Color.fromRGBO(196, 96, 64, 1)),
              ))),
      persistentFooterButtons: <Widget>[
        Text('Violin Pitch Helper',
            style: new TextStyle(fontWeight: FontWeight.bold, fontSize: 18))
      ],
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
      this.eplay})
      : super(key: key, listenable: animation);
  bool gplay;
  bool dplay;
  bool aplay;
  bool eplay;

  Widget build(BuildContext context) {
    final Animation<double> animation = listenable;
    var size = MediaQuery.of(context).size;
    var realLeft = size.width * 0.6;
    var realWidth = size.width - realLeft - 8;
    var containerHeight = size.height - 40;
    return new Center(
      child: new Container(
          width: realWidth,
          height: containerHeight,
          child: ClipRect(
            child: CustomPaint(
                painter: FingerBoard.withSize(realWidth, containerHeight, 0, 18,
                    gplay, dplay, aplay, eplay, animation)),
          )),
    );
  }
}
