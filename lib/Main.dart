import 'package:flutter/material.dart';
import 'Game.dart';
void main() {
  runApp(MineSweeper());
}

class MineSweeper extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: gamePage(),
    );
  }
}
