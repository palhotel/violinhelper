import 'accuracy.dart';

class MusicNote {
  int midi;
  Accuracy accuracy = Accuracy.NONE;
  double x;
  double y;
  String text;


  MusicNote(double x, double y, int midi, String text) {
    this.x = x;
    this.y = y;
    this.midi = midi;
    this.text = text;
  }
}