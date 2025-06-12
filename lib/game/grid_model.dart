import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logic_grid/game/puzzle_model.dart';

/// Represents the possible states of a cell in the grid
enum CellState {
  empty,    // Cell is empty
  filled,   // Cell is filled (correct)
  marked,   // Cell is marked with an X (definitely not filled)
  hint,     // Cell is revealed as a hint
}

/// Model class for the nonogram puzzle grid
class GridModel extends ChangeNotifier {
  // The current puzzle
  final Puzzle _puzzle;

  // The solution grid (true = filled, false = empty)
  final List<List<bool>> _solution;

  // The current state of each cell in the grid
  final List<List<CellState>> _grid;

  // Row clues (numbers at the left of each row)
  final List<List<int>> rowClues;

  // Column clues (numbers at the top of each column)
  final List<List<int>> columnClues;

  // Flag to track if the puzzle is completed
  bool _isPuzzleCompleted = false;

  // Number of available hints
  int _hintsRemaining = 3;

  // Animation controller for puzzle completion
  AnimationController? _completionAnimationController;

  /// Constructor that takes a puzzle
  GridModel({Puzzle? puzzle})
      : _puzzle = puzzle ?? _getDefaultPuzzle(),
        _solution = puzzle?.solution ?? _getDefaultPuzzle().solution,
        _grid = List.generate(
            puzzle?.gridSize ?? 5, (_) => List.filled(puzzle?.gridSize ?? 5, CellState.empty)),
        rowClues = [],
        columnClues = [] {
    // Generate clues based on the solution
    _generateClues();
  }

  /// Get the current puzzle
  Puzzle get puzzle => _puzzle;

  /// Get the grid size
  int get gridSize => _puzzle.gridSize;

  /// Get the puzzle completion status
  bool get isPuzzleCompleted => _isPuzzleCompleted;

  /// Get the number of hints remaining
  int get hintsRemaining => _hintsRemaining;

  /// Set the animation controller
  set completionAnimationController(AnimationController controller) {
    _completionAnimationController = controller;
  }

  /// Generates a default puzzle if none is provided
  static Puzzle _getDefaultPuzzle() {
    return Puzzle(
      id: 'default',
      name: 'Default Puzzle',
      difficulty: 'Easy',
      gridSize: 5,
      solution: [
        [false, false, true, false, false],
        [false, false, true, false, false],
        [true, true, true, true, true],
        [false, false, true, false, false],
        [false, false, true, false, false],
      ],
      isLocked: false,
    );
  }

  /// Generates row and column clues based on the solution
  void _generateClues() {
    // Generate row clues
    for (int row = 0; row < gridSize; row++) {
      List<int> clues = [];
      int count = 0;

      for (int col = 0; col < gridSize; col++) {
        if (_solution[row][col]) {
          count++;
        } else if (count > 0) {
          clues.add(count);
          count = 0;
        }
      }

      if (count > 0) {
        clues.add(count);
      }

      // If there are no filled cells in this row, add a 0
      if (clues.isEmpty) {
        clues.add(0);
      }

      rowClues.add(clues);
    }

    // Generate column clues
    for (int col = 0; col < gridSize; col++) {
      List<int> clues = [];
      int count = 0;

      for (int row = 0; row < gridSize; row++) {
        if (_solution[row][col]) {
          count++;
        } else if (count > 0) {
          clues.add(count);
          count = 0;
        }
      }

      if (count > 0) {
        clues.add(count);
      }

      // If there are no filled cells in this column, add a 0
      if (clues.isEmpty) {
        clues.add(0);
      }

      columnClues.add(clues);
    }
  }

  /// Get the current state of the grid
  List<List<CellState>> get grid => _grid;

  /// Get the solution grid
  List<List<bool>> get solution => _solution;

  /// Toggle the state of a cell at the given row and column
  void toggleCellState(int row, int col) {
    if (row < 0 || row >= gridSize || col < 0 || col >= gridSize) {
      return; // Out of bounds
    }

    // Don't allow toggling hint cells
    if (_grid[row][col] == CellState.hint) {
      return;
    }

    // Cycle through states: empty -> filled -> marked -> empty
    if (_grid[row][col] == CellState.empty) {
      _grid[row][col] = CellState.filled;
    } else if (_grid[row][col] == CellState.filled) {
      _grid[row][col] = CellState.marked;
    } else if (_grid[row][col] == CellState.marked) {
      _grid[row][col] = CellState.empty;
    }
    // The hint case is handled by the early return above

    // Notify listeners that the grid has changed
    notifyListeners();
  }

  /// Check if the current grid matches the solution
  bool checkSolution() {
    for (int row = 0; row < gridSize; row++) {
      for (int col = 0; col < gridSize; col++) {
        // If a cell should be filled but isn't, or shouldn't be filled but is
        // Consider both filled and hint cells as correct when they match the solution
        if ((_solution[row][col] && _grid[row][col] != CellState.filled && _grid[row][col] != CellState.hint) ||
            (!_solution[row][col] && (_grid[row][col] == CellState.filled || _grid[row][col] == CellState.hint))) {
          return false;
        }
      }
    }

    // If we get here, the solution is correct
    if (!_isPuzzleCompleted) {
      _isPuzzleCompleted = true;

      // Trigger the completion animation if available
      if (_completionAnimationController != null) {
        _completionAnimationController!.forward(from: 0.0);
      }

      // Notify listeners that the puzzle is completed
      notifyListeners();
    }

    return true;
  }

  /// Check if a row is correctly filled
  bool isRowCorrect(int row) {
    if (row < 0 || row >= gridSize) return false;

    for (int col = 0; col < gridSize; col++) {
      if ((_solution[row][col] && _grid[row][col] != CellState.filled && _grid[row][col] != CellState.hint) ||
          (!_solution[row][col] && (_grid[row][col] == CellState.filled || _grid[row][col] == CellState.hint))) {
        return false;
      }
    }
    return true;
  }

  /// Check if a column is correctly filled
  bool isColumnCorrect(int col) {
    if (col < 0 || col >= gridSize) return false;

    for (int row = 0; row < gridSize; row++) {
      if ((_solution[row][col] && _grid[row][col] != CellState.filled && _grid[row][col] != CellState.hint) ||
          (!_solution[row][col] && (_grid[row][col] == CellState.filled || _grid[row][col] == CellState.hint))) {
        return false;
      }
    }
    return true;
  }

  /// Reset the grid to all empty cells
  void resetGrid() {
    for (int row = 0; row < gridSize; row++) {
      for (int col = 0; col < gridSize; col++) {
        _grid[row][col] = CellState.empty;
      }
    }
    notifyListeners();
  }

  /// Reveal a correct cell as a hint
  /// Returns true if a hint was used, false if no hints are available
  bool revealHint() {
    // Check if there are hints remaining
    if (_hintsRemaining <= 0) {
      return false;
    }

    // Find cells that are not already correct
    List<List<int>> incorrectCells = [];
    for (int row = 0; row < gridSize; row++) {
      for (int col = 0; col < gridSize; col++) {
        // If the cell should be filled but isn't, or shouldn't be filled but is
        bool shouldBeFilled = _solution[row][col];
        bool isCorrect = (shouldBeFilled && (_grid[row][col] == CellState.filled || _grid[row][col] == CellState.hint)) ||
                         (!shouldBeFilled && _grid[row][col] != CellState.filled && _grid[row][col] != CellState.hint);

        if (!isCorrect) {
          incorrectCells.add([row, col]);
        }
      }
    }

    // If there are no incorrect cells, return false
    if (incorrectCells.isEmpty) {
      return false;
    }

    // Randomly select an incorrect cell
    incorrectCells.shuffle();
    int row = incorrectCells[0][0];
    int col = incorrectCells[0][1];

    // Set the cell to the correct state
    if (_solution[row][col]) {
      _grid[row][col] = CellState.hint;
    } else {
      _grid[row][col] = CellState.marked;
    }

    // Decrement the hint counter
    _hintsRemaining--;

    // Notify listeners
    notifyListeners();

    // Check if the puzzle is now complete
    checkSolution();

    return true;
  }
}
