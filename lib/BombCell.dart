import 'package:flutter/material.dart';

class BombCell extends StatelessWidget {
  bool bombCellOpened;
  final openBombCell;
  bool firstClick;
  int amountOfBombsAround;
  final ignoreBombCell;
  bool firstBombCellOpened;
  bool bombCellFlagged;
  final flagBombCell;
  final unflagBombCell;

  BombCell({
    this.bombCellOpened,
    this.openBombCell,
    this.firstClick,
    this.amountOfBombsAround,
    this.ignoreBombCell,
    this.firstBombCellOpened,
    this.bombCellFlagged,
    this.flagBombCell,
    this.unflagBombCell,
  });

  @override
  Widget build(BuildContext context) {
    if (firstClick && !bombCellFlagged) {
      return GestureDetector(
          onTap: ignoreBombCell,
          onLongPress: flagBombCell,
          onDoubleTap: unflagBombCell,
          child: Padding(
            padding: const EdgeInsets.all(1.0),
            child: Container(
              color:
                  (firstBombCellOpened) ? Colors.grey[300] : Colors.grey[400],
              child: Center(
                child: Text(
                  firstBombCellOpened ? amountOfBombsAround.toString() : '',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: amountOfBombsAround == 1
                        ? Colors.blueAccent
                        : (amountOfBombsAround == 2
                            ? Colors.green
                            : Colors.red),
                  ),
                ),
              ),
            ),
          ));
    } else if (bombCellFlagged) {
      return GestureDetector(
        onTap: openBombCell,
        onLongPress: flagBombCell,
        onDoubleTap: unflagBombCell,
        child: Padding(
          padding: const EdgeInsets.all(1.0),
          child: Container(
            color: bombCellFlagged ? Colors.grey[300] : Colors.grey[300],
            child: Center(
              child: Image.asset(
                bombCellFlagged ? 'lib/icons/flag.png' : '',
              ),
            ),
          ),
        ),
      );
    } else if (!bombCellFlagged) {
      return GestureDetector(
        onTap: openBombCell,
        onLongPress: flagBombCell,
        onDoubleTap: unflagBombCell,
        child: Padding(
          padding: const EdgeInsets.all(1.0),
          child: Container(
            color: bombCellOpened ? Colors.grey[800] : Colors.grey[400],
          ),
        ),
      );
    }
  }
}
