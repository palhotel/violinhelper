import 'accuracy.dart';

class MusicNote {
  int midi;
  Accuracy accuracy = Accuracy.NONE;
  double x;
  double y;
  String text;
  String strings;

  MusicNote.fromPitch(String pitchstr, double pitch, Map map, Map reverseMap){
    var list = reverseMap.keys;
    var min = 99999.0;
    var idx = 0;
    for(var i = 0; i < list.length; i++){
      var absValue = (list.elementAt(i) - pitch).abs();
      if(absValue < min){
        min = absValue;
        idx = i;
      }
    }
    this.text = reverseMap[list.elementAt(idx)];
    var pitchdelta = list.elementAt(idx) - pitch;
    if(pitchdelta < -8){
      this.accuracy = Accuracy.LOW;
    } else if(pitchdelta > 8){
      this.accuracy = Accuracy.HIGH;
    } else {
      this.accuracy = Accuracy.GOOD;
    }
    this.midi = idx + 55;

  }

  MusicNote(double x, double y, int midi, String text, String strings) {
    this.x = x;
    this.y = y;
    this.midi = midi;
    this.text = text;
    this.strings = strings;
  }

  void computeAccuracy(String pitchstr, double pitch, Map map, Map reverseMap){
    var list = reverseMap.keys;
    var min = 99999.0;
    var idx = 0;
    for(var i = 0; i < list.length; i++){
      var absValue = (list.elementAt(i) - pitch).abs();
      if(absValue < min){
        min = absValue;
        idx = i;
      }
    }
    var pitchdelta = list.elementAt(idx) - pitch;
    if(pitchdelta < -8){
      this.accuracy = Accuracy.LOW;
    } else if(pitchdelta > 8){
      this.accuracy = Accuracy.HIGH;
    } else {
      this.accuracy = Accuracy.GOOD;
    }

  }
}