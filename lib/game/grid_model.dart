import 'package:flutter/foundation.dart';

/// Represents the possible states of a cell in the grid
enum CellState {
  empty,    // Cell is empty
  filled,   // Cell is filled (correct)
  marked,   // Cell is marked with an X (definitely not filled)
}

/// Model class for the nonogram puzzle grid
class GridModel extends ChangeNotifier {
  // Grid size (5x5)
  static const int gridSize = 5;
  
  // The solution grid (true = filled, false = empty)
  final List<List<bool>> _solution;
  
  // The current state of each cell in the grid
  final List<List<CellState>> _grid;
  
  // Row clues (numbers at the left of each row)
  final List<List<int>> rowClues;
  
  // Column clues (numbers at the top of each column)
  final List<List<int>> columnClues;
  
  /// Constructor that takes a solution grid and generates clues
  GridModel({List<List<bool>>? solution})
      : _solution = solution ?? _generateDefaultSolution(),
        _grid = List.generate(
            gridSize, (_) => List.filled(gridSize, CellState.empty)),
        rowClues = [],
        columnClues = [] {
    // Generate clues based on the solution
    _generateClues();
  }
  
  /// Generates a default solution if none is provided
  static List<List<bool>> _generateDefaultSolution() {
    // Simple pattern for testing (a plus sign)
    return [
      [false, false, true, false, false],
      [false, false, true, false, false],
      [true, true, true, true, true],
      [false, false, true, false, false],
      [false, false, true, false, false],
    ];
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
    
    // Cycle through states: empty -> filled -> marked -> empty
    switch (_grid[row][col]) {
      case CellState.empty:
        _grid[row][col] = CellState.filled;
        break;
      case CellState.filled:
        _grid[row][col] = CellState.marked;
        break;
      case CellState.marked:
        _grid[row][col] = CellState.empty;
        break;
    }
    
    // Notify listeners that the grid has changed
    notifyListeners();
  }
  
  /// Check if the current grid matches the solution
  bool checkSolution() {
    for (int row = 0; row < gridSize; row++) {
      for (int col = 0; col < gridSize; col++) {
        // If a cell should be filled but isn't, or shouldn't be filled but is
        if ((_solution[row][col] && _grid[row][col] != CellState.filled) ||
            (!_solution[row][col] && _grid[row][col] == CellState.filled)) {
          return false;
        }
      }
    }
    return true;
  }
  
  /// Check if a row is correctly filled
  bool isRowCorrect(int row) {
    if (row < 0 || row >= gridSize) return false;
    
    for (int col = 0; col < gridSize; col++) {
      if ((_solution[row][col] && _grid[row][col] != CellState.filled) ||
          (!_solution[row][col] && _grid[row][col] == CellState.filled)) {
        return false;
      }
    }
    return true;
  }
  
  /// Check if a column is correctly filled
  bool isColumnCorrect(int col) {
    if (col < 0 || col >= gridSize) return false;
    
    for (int row = 0; row < gridSize; row++) {
      if ((_solution[row][col] && _grid[row][col] != CellState.filled) ||
          (!_solution[row][col] && _grid[row][col] == CellState.filled)) {
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
}