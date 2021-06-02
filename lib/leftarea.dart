import 'package:flutter/material.dart';
import 'musicsheet.dart';
import 'musicnote.dart';
import 'fhole.dart';

class LeftArea extends AnimatedWidget {
  LeftArea({Key key, Animation<double> animation, this.pitchstr, this.pitchdelta})
      : super(key: key, listenable: animation);

  String pitchstr;
  double pitchdelta;
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var realWidth = size.width * 0.6;
    var containerHeight = size.height - 40;
    var firstBlockHeight = 200.0;
    var secondBlockHeight = 150.0;
    var imagePath = "images/" + this.pitchstr + ".png";
    return Center(
        child: Container(
            width: realWidth,
            height: containerHeight,
            child: new Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                    width: realWidth,
                    height: firstBlockHeight,
                    child: ClipRect(
                      child: CustomPaint(
                          painter: MusicSheet.withSize(realWidth,
                              firstBlockHeight, pitchstr, pitchdelta)),
                    )),
                Container(
                  width: realWidth,
                  height: secondBlockHeight,
                  child: Image.asset(imagePath)
                ),
                Container(
                    width: realWidth,
                    height: containerHeight - firstBlockHeight - secondBlockHeight - 1,
                    child: ClipRect(
                      child: CustomPaint(
                          painter: FHole.withSize(realWidth,
                              containerHeight - firstBlockHeight - secondBlockHeight - 1)),
                    ))
              ],
            )));
  }
}
