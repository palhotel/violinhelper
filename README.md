# violin_helper

Violin Pitch Helper
小提琴调音助手

使用flutter开发。

## Reference

- [flutter_midi](https://pub.flutter-io.cn/packages/flutter_midi)
- [pitchdetector](https://pub.flutter-io.cn/packages/pitchdetector)
- [solve a bug in pitchdetector](https://stackoverflow.com/questions/58486139/avaudioengine-connect-crash-on-hardware-not-simulator)
```swift
    do {
        try AVAudioSession.sharedInstance()
            .setCategory(AVAudioSession.Category.playAndRecord, options: .mixWithOthers);
    } catch {
                print("error in setCategory");
    }
```
