import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'BombCell.dart';
import 'EmptyCell.dart';
import 'GameCell.dart';

class gamePage extends StatefulWidget {
  @override
  State<gamePage> createState() => _gamePageState();
}

class _gamePageState extends State<gamePage> {
  // amount of cells in a row of game field
  int cellsInRow = 10;

  // amount of cells in a column of game field
  int cellsInColumn = 10;

  // amount of bombs in game field
  int bombsInField = 20;
  int cellsInField = 10 * 10;

  // amount of cells that correctly flagged as a bomb
  int bombsFound = 0;

  // amount of empty cells that incorrectly flagged as a bomb
  int emptyCellsFlagged = 0;

  // game board
  List<GameCell> board;

  // array of bomb positions
  var bombPositions = [];

  // array of closed empty cells
  var closedEmptyCellsInField = [];

  // array of flagged cells
  var flaggedCells = [];

  // if the player clicked on the bomb
  bool loseTheGame = false;

  // to prevent lose on a first click
  bool firstClick = true;
  Timer timer;
  Stopwatch stopwatch = Stopwatch();

  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  //generate bomb positions
  void generateBombs() {
    for (int i = 0; i < bombsInField; ++i) {
      var bombPos = Random().nextInt(cellsInField);
      if (bombPositions.contains(bombPos)) {
        while (bombPositions.contains(bombPos)) {
          bombPos = Random().nextInt(cellsInField);
        }
        bombPositions.add(bombPos);
      } else {
        bombPositions.add(bombPos);
      }
    }
  }

  // method for generating a game board of size amount of rows * amount of columns
  void generateGameField(int cellsInRow, int cellsInColumn, int bombsInField) {
    board = List.generate(
        cellsInColumn * cellsInRow,
        (index) => GameCell(
            amountOfBombsAroundCell: 0, cellOpened: false, cellFlagged: false));
  }

  // method for replacing a bomb if a player opened it on the first click
  void replaceBomb(int pos) {
    bombPositions.remove(pos);
    var newBombPos = Random().nextInt(cellsInField);
    if (closedEmptyCellsInField.contains(newBombPos)) {
      closedEmptyCellsInField.remove(newBombPos);
    }
    if (bombPositions.contains(newBombPos) || newBombPos == pos) {
      while (bombPositions.contains(newBombPos) || newBombPos == pos) {
        newBombPos = Random().nextInt(cellsInField);
      }
      bombPositions.add(newBombPos);
    } else {
      bombPositions.add(newBombPos);
    }
  }

  // method for opening random empty cell to prevent random case
  void openRandomEmptyCell() {
    if (closedEmptyCellsInField.length == 1) {
      if (!board[closedEmptyCellsInField[0]].cellFlagged) {
        board[closedEmptyCellsInField[0]].cellOpened = true;
      }
      checkIfPlayerWon();
      return;
    }
    var posOfRandomEmptyCell = Random().nextInt(closedEmptyCellsInField.length - 1);
    setState(() {
      int index = closedEmptyCellsInField[posOfRandomEmptyCell];
      if (!board[index].cellFlagged) {
          board[index].cellOpened = true;
      } else {
        while (board[index].cellFlagged) {
          posOfRandomEmptyCell = Random().nextInt(closedEmptyCellsInField.length - 1 );
          index = closedEmptyCellsInField[posOfRandomEmptyCell];
        }
        board[index].cellOpened = true;
      }
      showEmptyCellsAroundCell(index);
      checkIfPlayerWon();
      closedEmptyCellsInField.removeAt(posOfRandomEmptyCell);
    });
  }

  //method to fill an array with closed empty cells
  void generateCellsWithoutBomb() {
    for (int i = 0; i < cellsInField; ++i) {
      if (!bombPositions.contains(i) && !board[i].cellOpened) {
        closedEmptyCellsInField.add(i);
      }
    }
  }

  // inital state
  void initState() {
    super.initState();
    generateGameField(cellsInRow, cellsInColumn, bombsInField);
    generateBombs();
    generateCellsWithoutBomb();
    countBombsAroundCell();
    timer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
      setState(() {});
    });
  }

  //method for opening empty cells around an empty cell
  void showEmptyCellsAroundCell(int pos) {
    if (board[pos].amountOfBombsAroundCell != 0) {
      setState(() {
        board[pos].cellOpened = true;
        if (closedEmptyCellsInField.contains(pos)) {
          closedEmptyCellsInField.remove(pos);
        }
      });
    } else {
      setState(() {
        board[pos].cellOpened = true;
        if (closedEmptyCellsInField.contains(pos)) {
          closedEmptyCellsInField.remove(pos);
        }
        //left
        if (pos % cellsInRow != 0) {
          if (board[pos - 1].amountOfBombsAroundCell == 0 &&
              board[pos - 1].cellOpened == false) {
            showEmptyCellsAroundCell(pos - 1);
          }
          board[pos - 1].cellOpened = true;
        }
        //top left
        if (pos % cellsInRow != 0 && pos >= cellsInRow) {
          if (board[pos - 1 - cellsInRow].amountOfBombsAroundCell == 0 &&
              board[pos - 1 - cellsInRow].cellOpened == false) {
            showEmptyCellsAroundCell(pos - 1 - cellsInRow);
          }
          board[pos - 1 - cellsInRow].cellOpened = true;
        }
        //top
        if (pos >= cellsInRow) {
          if (board[pos - cellsInRow].amountOfBombsAroundCell == 0 &&
              board[pos - cellsInRow].cellOpened == false) {
            showEmptyCellsAroundCell(pos - cellsInRow);
          }
          board[pos - cellsInRow].cellOpened = true;
        }
        //top right
        if (pos >= cellsInRow && pos % cellsInRow != cellsInRow - 1) {
          if (board[pos + 1 - cellsInRow].amountOfBombsAroundCell == 0 &&
              board[pos + 1 - cellsInRow].cellOpened == false) {
            showEmptyCellsAroundCell(pos + 1 - cellsInRow);
          }
          board[pos + 1 - cellsInRow].cellOpened = true;
        }
        //right
        if (pos % cellsInRow != cellsInRow - 1) {
          if (board[pos + 1].amountOfBombsAroundCell == 0 &&
              board[pos + 1].cellOpened == false) {
            showEmptyCellsAroundCell(pos + 1);
          }
          board[pos + 1].cellOpened = true;
        }
        //bottom right
        if (pos % cellsInRow != cellsInRow - 1 &&
            pos < cellsInField - cellsInRow) {
          if (board[pos + 1 + cellsInRow].amountOfBombsAroundCell == 0 &&
              board[pos + 1 + cellsInRow].cellOpened == false) {
            showEmptyCellsAroundCell(pos + 1 + cellsInRow);
          }
          board[pos + 1 + cellsInRow].cellOpened = true;
        }
        //bottom
        if (pos < cellsInField - cellsInRow) {
          if (board[pos + cellsInRow].amountOfBombsAroundCell == 0 &&
              board[pos + cellsInRow].cellOpened == false) {
            showEmptyCellsAroundCell(pos + cellsInRow);
          }
          board[pos + cellsInRow].cellOpened = true;
        }
        //bottom left
        if (pos < cellsInField - cellsInRow && pos % cellsInRow != 0) {
          if (board[pos - 1 + cellsInRow].amountOfBombsAroundCell == 0 &&
              board[pos - 1 + cellsInRow].cellOpened == false) {
            showEmptyCellsAroundCell(pos - 1 + cellsInRow);
          }
          board[pos - 1 + cellsInRow].cellOpened = true;
        }
      });
    }
  }

    void countBombsAroundCell() {
    for (int i = 0; i < cellsInField; ++i) {
      int amountOfBombsAround = 0;
      // left
      if (bombPositions.contains(i - 1) && i % cellsInRow != 0) {
        amountOfBombsAround++;
      }
      // top left
      if (bombPositions.contains(i - 1 - cellsInRow) &&
          i % cellsInRow != 0 &&
          i >= cellsInRow) {
        amountOfBombsAround++;
      }
      // top
      if (bombPositions.contains(i - cellsInRow) && i >= cellsInRow) {
        amountOfBombsAround++;
      }
      // top right
      if (bombPositions.contains(i + 1 - cellsInRow) &&
          i >= cellsInRow &&
          i % cellsInRow != cellsInRow - 1) {
        amountOfBombsAround++;
      }
      // right
      if (bombPositions.contains(i + 1) && i % cellsInRow != cellsInRow - 1) {
        amountOfBombsAround++;
      }
      // bottom right
      if (bombPositions.contains(i + 1 + cellsInRow) &&
          i % cellsInRow != cellsInRow - 1 &&
          i < cellsInField - cellsInRow) {
        amountOfBombsAround++;
      }
      // bottom
      if (bombPositions.contains(i + cellsInRow) &&
          i < cellsInField - cellsInRow) {
        amountOfBombsAround++;
      }

      // bottom left
      if (bombPositions.contains(i - 1 + cellsInRow) &&
          i < cellsInField - cellsInRow &&
          i % cellsInRow != 0) {
        amountOfBombsAround++;
      }
      setState(() {
        board[i].amountOfBombsAroundCell = amountOfBombsAround;
      });
    }
  }

  // method for restarting a game
  void restartGame() {
    setState(() {
      firstClick = true;
      loseTheGame = false;
      bombsFound = 0;
      emptyCellsFlagged = 0;
      bombPositions.clear();
      flaggedCells.clear();
      closedEmptyCellsInField.clear();
      generateBombs();
      generateCellsWithoutBomb();
      countBombsAroundCell();
      for (int i = 0; i < cellsInField; ++i) {
        board[i].cellOpened = false;
        board[i].cellFlagged = false;
      }
    });
    stopwatch.reset();
    stopwatch.stop();
    timer?.cancel();
    timer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
      setState(() {});
    });
  }

  //method for displaying a window with win
  void gameOverWithWin() {
    stopwatch.stop();
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Color.fromRGBO(190, 222, 233, 1),
            title: Center(
              child: Text('YOU HAVE WON',
                  style: TextStyle(color: Color.fromRGBO(83, 75, 75, 1))),
            ),
            actions: [
              ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(
                        Color.fromRGBO(83, 75, 75, 1)),
                    foregroundColor: MaterialStateProperty.all(Colors.white),
                    shape: MaterialStateProperty.all(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30))),
                  ),
                  onPressed: () {
                    restartGame();
                    Navigator.pop(context);
                  },
                  child: Icon(Icons.refresh,
                      color: Color.fromRGBO(190, 222, 233, 1)))
            ],
          );
        });
  }

  void cellFlaggedAlert() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Color.fromRGBO(190, 222, 233, 1),
            title: Center(
              child: Text('CELL IS FLAGGED!',
                  style: TextStyle(color: Color.fromRGBO(83, 75, 75, 1))),
            ),
            actions: [
              ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(
                        Color.fromRGBO(83, 75, 75, 1)),
                    foregroundColor: MaterialStateProperty.all(Colors.white),
                    shape: MaterialStateProperty.all(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30))),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Icon(Icons.skip_next,
                      color: Color.fromRGBO(190, 222, 233, 1)))
            ],
          );
        });
  }
  // method for checking if the player won
  void checkIfPlayerWon() {
    int closedCells = 0;
    for (int i = 0; i < cellsInField; ++i) {
      if (board[i].cellOpened == false) {
        closedCells++;
      }
    }
    if (closedCells == bombPositions.length ||
        (bombsFound == bombPositions.length && emptyCellsFlagged == 0)) {
      gameOverWithWin();
    }
  }

  //method for displaying a window with loss
  void gameOverWithLose() {
    stopwatch.stop();
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Color.fromRGBO(190, 222, 233, 1),
            title: Center(
              child: Text('YOU HAVE LOST',
                  style: TextStyle(color: Color.fromRGBO(83, 75, 75, 1))),
            ),
            actions: [
              ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                          Color.fromRGBO(83, 75, 75, 1)),
                      foregroundColor: MaterialStateProperty.all(Colors.white),
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)))),
                  onPressed: () {
                    restartGame();
                    Navigator.pop(context);
                  },
                  child: Icon(Icons.refresh,
                      color: Color.fromRGBO(190, 222, 233, 1)))
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    int timeElapsed = stopwatch.elapsedMilliseconds ~/ 1000;
    return Scaffold(
      backgroundColor: Color.fromRGBO(83, 75, 75, 1),
      body: Column(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.05,
            width: MediaQuery.of(context).size.width * 1,
            color: Color.fromRGBO(190, 222, 233, 1),
            child: Center(
              child: Text(
                'MINESWEEPER',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
          ),
          Container(
              height: MediaQuery.of(context).size.height * 0.15,
              width: MediaQuery.of(context).size.width * 1,
              color: Color.fromRGBO(190, 222, 233, 1),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          bombsInField.toString(),
                          style: TextStyle(fontSize: 40),
                        ),
                        Text('BOMBS'),
                      ]),
                  GestureDetector(
                    onTap: restartGame,
                    child: Card(
                      child: Image.asset(
                        'lib/icons/mine.png',
                        height: 45,
                      ),
                      color: Color.fromRGBO(190, 222, 233, 1),
                    ),
                  ),
                  Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          timeElapsed.toString(),
                          style: TextStyle(fontSize: 40),
                        ),
                        Text('TIME'),
                      ])
                ],
              )),
          Container(
              height: MediaQuery.of(context).size.height * 0.6,
              width: MediaQuery.of(context).size.width * 1,
              child: GridView.builder(
                //physics: NeverScrollableScrollPhysics(),
                itemCount: cellsInField,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: cellsInRow),
                itemBuilder: (context, index) {
                  if (bombPositions.contains(index)) {
                    return BombCell(
                      bombCellOpened: loseTheGame,
                      openBombCell: () {
                        if (!board[index].cellFlagged) {
                          if (!stopwatch.isRunning) stopwatch.start();
                          setState(() {
                            loseTheGame = true;
                          });
                          gameOverWithLose();
                        }
                      },
                      firstClick: firstClick,
                      amountOfBombsAround: board[index].amountOfBombsAroundCell,
                      ignoreBombCell: () {
                        setState(() {
                          if (!board[index].cellFlagged) {
                            if (!stopwatch.isRunning) stopwatch.start();
                            if (firstClick) {
                              replaceBomb(index);
                            }
                            firstClick = false;
                            showEmptyCellsAroundCell(index);
                            countBombsAroundCell();
                            checkIfPlayerWon();
                          }
                        });
                      },
                      firstBombCellOpened: board[index].cellOpened,
                      bombCellFlagged: board[index].cellFlagged,
                      flagBombCell: () {
                        setState(() {
                          bombsFound++;
                          board[index].cellFlagged = true;
                          if (!flaggedCells.contains(index)) {
                            flaggedCells.add(index);
                          }
                        });
                        checkIfPlayerWon();
                      },
                      unflagBombCell: () {
                        setState(() {
                          bombsFound--;
                          board[index].cellFlagged = false;
                          flaggedCells.remove(index);
                        });
                        checkIfPlayerWon();
                      },
                    );
                  } else {
                    return EmptyCell(
                      amountOfBombsAround: board[index].amountOfBombsAroundCell,
                      emptyCellOpened: board[index].cellOpened,
                      openEmptyCell: () {
                        setState(() {
                          if (firstClick) {
                            firstClick = false;
                          }
                          if (board[index].cellFlagged) {
                              cellFlaggedAlert();
                          }
                          if (!board[index].cellFlagged) {
                            if (!stopwatch.isRunning) stopwatch.start();
                            showEmptyCellsAroundCell(index);
                            checkIfPlayerWon();
                          }
                        });
                      },
                      emptyCellFlagged: board[index].cellFlagged,
                      flagEmptyCell: () {
                        setState(() {
                          emptyCellsFlagged++;
                          if (!board[index].cellOpened) {
                            board[index].cellFlagged = true;
                            if (!flaggedCells.contains(index)) {
                              flaggedCells.add(index);
                            }
                            checkIfPlayerWon();
                          }
                        });
                      },
                      unflagEmptyCell: () {
                        setState(() {
                          emptyCellsFlagged--;
                          if (!board[index].cellOpened) {
                            board[index].cellFlagged = false;
                            flaggedCells.remove(index);
                          }
                          checkIfPlayerWon();
                        });
                      },
                    );
                  }
                },
              )),
          Container(
              height: MediaQuery.of(context).size.height * 0.1,
              width: MediaQuery.of(context).size.width * 1,
              color: Color.fromRGBO(190, 222, 233, 1),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  SizedBox(
                      height: 40,
                      width: MediaQuery.of(context).size.width * 0.33,
                      child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              cellsInRow = 9;
                              cellsInColumn = 9;
                              bombsInField = 10;
                              cellsInField = 9 * 9;
                              generateGameField(9, 9, 10);
                              restartGame();
                            });
                          },
                          child: Center(child: Text('Easy')),
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                                Color.fromRGBO(83, 75, 75, 1)),
                            foregroundColor:
                                MaterialStateProperty.all(Colors.white),
                            shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30))),
                          ))),
                  SizedBox(
                      height: 40,
                      width: MediaQuery.of(context).size.width * 0.33,
                      child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              cellsInRow = 10;
                              cellsInColumn = 10;
                              bombsInField = 20;
                              cellsInField = 10 * 10;
                              generateGameField(10, 10, 20);
                              restartGame();
                            });
                          },
                          child: Center(child: Text('Medium')),
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                                Color.fromRGBO(83, 75, 75, 1)),
                            foregroundColor:
                                MaterialStateProperty.all(Colors.white),
                            shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30))),
                          ))),
                  SizedBox(
                      height: 40,
                      width: MediaQuery.of(context).size.width * 0.33,
                      child: ElevatedButton(
                          onPressed: () {
                            cellsInRow = 11;
                            cellsInColumn = 11;
                            bombsInField = 30;
                            cellsInField = 11 * 11;
                            generateGameField(11, 11, 30);
                            restartGame();
                          },
                          child: Center(child: Text('Hard')),
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                                Color.fromRGBO(83, 75, 75, 1)),
                            foregroundColor:
                                MaterialStateProperty.all(Colors.white),
                            shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30))),
                          ))),
                ],
              )),
          Container(
              height: MediaQuery.of(context).size.height * 0.10,
              width: MediaQuery.of(context).size.width * 1,
              color: Color.fromRGBO(190, 222, 233, 1),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  SizedBox(
                      width: MediaQuery.of(context).size.width * 0.33,
                      height: 40,
                      child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              closedEmptyCellsInField.clear();
                              generateCellsWithoutBomb();
                              openRandomEmptyCell();
                            });
                          },
                          child: Center(child: Text('Bot')),
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                                Color.fromRGBO(83, 75, 75, 1)),
                            foregroundColor:
                                MaterialStateProperty.all(Colors.white),
                            shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30))),
                          ))),
                ],
              )),
        ],
      ),
    );
  }
}
