import 'package:flutter/material.dart';

class EmptyCell extends StatelessWidget {
  int amountOfBombsAround;
  bool emptyCellOpened;
  final openEmptyCell;
  bool emptyCellFlagged;
  final flagEmptyCell;
  final unflagEmptyCell;

  EmptyCell({
    this.amountOfBombsAround,
    @required this.emptyCellOpened,
    this.openEmptyCell,
    this.emptyCellFlagged,
    this.flagEmptyCell,
    this.unflagEmptyCell,
  });

  @override
  Widget build(BuildContext context) {
    if (!emptyCellFlagged) {
      return GestureDetector(
          onTap: openEmptyCell,
          onLongPress: flagEmptyCell,
          child: Padding(
            padding: const EdgeInsets.all(1.0),
            child: Container(
              color: (emptyCellOpened) ? Colors.grey[300] : Colors.grey[400],
              child: Center(
                child: Text(
                  emptyCellOpened ? amountOfBombsAround.toString() : '',
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
    } else if (emptyCellFlagged) {
      return GestureDetector(
        onTap: openEmptyCell,
        onLongPress: flagEmptyCell,
        onDoubleTap: unflagEmptyCell,
        child: Padding(
          padding: const EdgeInsets.all(1.0),
          child: Container(
            color: (emptyCellFlagged) ? Colors.grey[300] : Colors.grey[300],
            child: Center(
              child: Image.asset(
                emptyCellFlagged ? 'lib/icons/flag.png' : '',
              ),
            ),
          ),
        ),
      );
    }
  }
}
