import 'package:flutter/material.dart';
import 'musicsheet.dart';
import 'musicnote.dart';
import 'fhole.dart';

class LeftArea extends AnimatedWidget {
  LeftArea({Key key, Animation<double> animation, this.pitchstr, this.pitchdelta})
      : super(key: key, listenable: animation);

  String pitchstr;
  double pitchdelta;

  List<Widget> pictures(){
    if(this.pitchstr.contains("/")){
      var arr = this.pitchstr.split("/");
      var str1 = "images/" + arr[0] + ".png";
      var str2 = "images/" + arr[1] + ".png";
      return [Image.asset(str1), Image.asset(str2)];
    } else {
      return [Image.asset("images/" + this.pitchstr + ".png")];
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var realWidth = size.width * 0.6;
    var containerHeight = size.height - 40;
    var firstBlockHeight = 200.0;
    var secondBlockHeight = 150.0;
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: pictures(),
                  )
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
