import 'package:flutter/material.dart';
import 'musicsheet.dart';
import 'musicnote.dart';
import 'fhole.dart';

class LeftArea extends AnimatedWidget {
  LeftArea({Key key, Animation<double> animation, this.pitchstr})
      : super(key: key, listenable: animation);

  String pitchstr;
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var realWidth = size.width * 0.6;
    var containerHeight = size.height - 40;
    var firstColumnHeight = 300.0;
    return Center(
        child: Container(
            width: realWidth,
            height: containerHeight,
            child: new Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                    width: realWidth,
                    height: firstColumnHeight,
                    child: ClipRect(
                      child: CustomPaint(
                          painter: MusicSheet.withSize(realWidth,
                              firstColumnHeight, pitchstr)),
                    )),
                Container(
                    width: realWidth,
                    height: containerHeight - firstColumnHeight - 1,
                    child: ClipRect(
                      child: CustomPaint(
                          painter: FHole.withSize(realWidth,
                              containerHeight - firstColumnHeight - 1)),
                    ))
              ],
            )));
  }
}
