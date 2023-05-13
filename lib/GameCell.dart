import 'package:flutter/material.dart';

class GameCell {
  int amountOfBombsAroundCell;
  bool cellOpened;
  bool cellFlagged;
  GameCell({this.amountOfBombsAroundCell, this.cellOpened, this.cellFlagged});
}
