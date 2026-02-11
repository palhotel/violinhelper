import 'package:flutter/material.dart';

import 'app_entry_mobile.dart' if (dart.library.html) 'app_entry_web.dart' as app_entry;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Violin Pitch Helper',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: app_entry.buildHome(),
      debugShowCheckedModeBanner: false,
    );
  }
}
