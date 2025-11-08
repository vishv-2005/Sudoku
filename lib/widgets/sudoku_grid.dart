import 'package:flutter/material.dart';

class SudokuGrid extends StatelessWidget {
  final List<List<int>> board;
  final int? selectedRow;
  final int? selectedCol;
  final Function(int, int) onCellTap;
  final List<List<bool>> isFixed;

  const SudokuGrid({
    super.key,
    required this.board,
    required this.selectedRow,
    required this.selectedCol,
    required this.onCellTap,
    required this.isFixed,
  });

  bool _isInSameRow(int row) {
    return selectedRow != null && selectedRow == row;
  }

  bool _isInSameCol(int col) {
    return selectedCol != null && selectedCol == col;
  }

  bool _isInSameBox(int row, int col) {
    if (selectedRow == null || selectedCol == null) return false;
    return (row ~/ 3) == (selectedRow! ~/ 3) &&
        (col ~/ 3) == (selectedCol! ~/ 3);
  }

  bool _hasConflict(int row, int col, int value) {
    if (value == 0 || (row == selectedRow && col == selectedCol)) return false;

    // Check if this cell has the same value as selected cell
    if (selectedRow != null && selectedCol != null &&
        board[selectedRow!][selectedCol!] != 0 &&
        board[selectedRow!][selectedCol!] == value) {
      // Check if they're in same row, col, or box
      return _isInSameRow(row) || _isInSameCol(col) || _isInSameBox(row, col);
    }

    // Check if selected cell value conflicts with this cell
    if (selectedRow != null && selectedCol != null &&
        board[selectedRow!][selectedCol!] != 0) {
      int selectedValue = board[selectedRow!][selectedCol!];
      if (value == selectedValue) {
        return _isInSameRow(row) || _isInSameCol(col) || _isInSameBox(row, col);
      }
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E2E),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.deepPurple.withOpacity(0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 20,
                offset: const Offset(0, 8),
                spreadRadius: 2,
              ),
            ],
          ),
          padding: const EdgeInsets.all(6),
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 81,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 9,
            ),
            itemBuilder: (context, index) {
              int row = index ~/ 9;
              int col = index % 9;
              int value = board[row][col];

              // Determine highlight states
              bool isSelected = selectedRow == row && selectedCol == col;
              bool isInSameRow = _isInSameRow(row);
              bool isInSameCol = _isInSameCol(col);
              bool isInSameBox = _isInSameBox(row, col);
              bool hasConflict = _hasConflict(row, col, value);
              bool isRelated = isInSameRow || isInSameCol || isInSameBox;
              bool sameNumberHighlighted = (selectedRow != null &&
                  selectedCol != null &&
                  value != 0 &&
                  value == board[selectedRow!][selectedCol!] &&
                  !isSelected);

              // Determine borders (thicker for 3x3)
              double top = row % 3 == 0 ? 3.0 : 0.5;
              double left = col % 3 == 0 ? 3.0 : 0.5;
              double right = (col + 1) % 3 == 0 ? 3.0 : 0.5;
              double bottom = (row + 1) % 3 == 0 ? 3.0 : 0.5;

              // Determine cell background color
              Color cellColor = const Color(0xFF2A2A3E);
              if (isSelected) {
                cellColor = Colors.blue[700]!;
              } else if (hasConflict) {
                cellColor = Colors.red[900]!.withOpacity(0.4);
              } else if (sameNumberHighlighted) {
                cellColor = Colors.amber[700]!.withOpacity(0.35);
              } else if (isRelated) {
                cellColor = Colors.blue[800]!.withOpacity(0.25);
              } else if (isFixed[row][col]) {
                cellColor = const Color(0xFF2D2D44);
              }

              // Determine text color - ALWAYS VISIBLE
              Color textColor;
              if (hasConflict) {
                textColor = Colors.red[300]!;
              } else if (isSelected) {
                textColor = Colors.white;
              } else if (sameNumberHighlighted) {
                textColor = Colors.amber[200]!;
              } else if (isRelated) {
                textColor = Colors.lightBlue[200]!;
              } else if (isFixed[row][col]) {
                textColor = Colors.deepPurple[200]!;
              } else {
                textColor = Colors.blue[200]!;
              }

              return GestureDetector(
                onTap: () => onCellTap(row, col),
                child: Container(
                  decoration: BoxDecoration(
                    color: cellColor,
                    // REMOVED borderRadius to fix the rendering error
                    border: Border(
                      top: BorderSide(
                        width: top,
                        color: top > 2
                            ? Colors.deepPurple[400]!
                            : Colors.grey[700]!,
                      ),
                      left: BorderSide(
                        width: left,
                        color: left > 2
                            ? Colors.deepPurple[400]!
                            : Colors.grey[700]!,
                      ),
                      right: BorderSide(
                        width: right,
                        color: right > 2
                            ? Colors.deepPurple[400]!
                            : Colors.grey[700]!,
                      ),
                      bottom: BorderSide(
                        width: bottom,
                        color: bottom > 2
                            ? Colors.deepPurple[400]!
                            : Colors.grey[700]!,
                      ),
                    ),
                    boxShadow: isSelected ? [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.4),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ] : null,
                  ),
                  child: Center(
                    child: Text(
                      value == 0 ? '' : value.toString(),
                      style: TextStyle(
                        fontSize: isSelected ? 26 : 20,
                        fontWeight: isFixed[row][col]
                            ? FontWeight.bold
                            : FontWeight.w600,
                        color: textColor,
                        letterSpacing: 0.5,
                        decoration: TextDecoration.none,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.7),
                            blurRadius: 3,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}