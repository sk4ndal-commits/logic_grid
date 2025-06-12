import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

/// Represents a nonogram puzzle with its solution and metadata
class Puzzle {
  final String id;
  final String name;
  final String difficulty;
  final int gridSize;
  final List<List<bool>> solution;
  final bool isLocked;
  
  /// Constructor
  Puzzle({
    required this.id,
    required this.name,
    required this.difficulty,
    required this.gridSize,
    required this.solution,
    this.isLocked = true,
  });
  
  /// Create a Puzzle from JSON
  factory Puzzle.fromJson(Map<String, dynamic> json) {
    // Parse the solution grid from the JSON string representation
    List<List<bool>> solutionGrid = [];
    List<dynamic> rows = json['solution'];
    
    for (var row in rows) {
      List<bool> boolRow = [];
      for (var cell in row) {
        boolRow.add(cell == 1);
      }
      solutionGrid.add(boolRow);
    }
    
    return Puzzle(
      id: json['id'],
      name: json['name'],
      difficulty: json['difficulty'],
      gridSize: json['gridSize'],
      solution: solutionGrid,
      isLocked: json['isLocked'] ?? true,
    );
  }
  
  /// Convert Puzzle to JSON
  Map<String, dynamic> toJson() {
    // Convert the solution grid to a list of 1s and 0s
    List<List<int>> solutionAsInts = solution.map((row) {
      return row.map((cell) => cell ? 1 : 0).toList();
    }).toList();
    
    return {
      'id': id,
      'name': name,
      'difficulty': difficulty,
      'gridSize': gridSize,
      'solution': solutionAsInts,
      'isLocked': isLocked,
    };
  }
}

/// Repository for loading and managing puzzles
class PuzzleRepository {
  List<Puzzle> _puzzles = [];
  
  /// Get all puzzles
  List<Puzzle> get puzzles => _puzzles;
  
  /// Get a puzzle by ID
  Puzzle? getPuzzleById(String id) {
    try {
      return _puzzles.firstWhere((puzzle) => puzzle.id == id);
    } catch (e) {
      return null;
    }
  }
  
  /// Load puzzles from a JSON asset file
  Future<void> loadPuzzles() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/puzzles.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      
      _puzzles = (jsonData['puzzles'] as List)
          .map((puzzleJson) => Puzzle.fromJson(puzzleJson))
          .toList();
    } catch (e) {
      print('Error loading puzzles: $e');
      // Load default puzzles if file can't be loaded
      _loadDefaultPuzzles();
    }
  }
  
  /// Load default puzzles if no JSON file is available
  void _loadDefaultPuzzles() {
    _puzzles = [
      Puzzle(
        id: 'puzzle_1',
        name: 'Plus Sign',
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
      ),
      Puzzle(
        id: 'puzzle_2',
        name: 'X Mark',
        difficulty: 'Easy',
        gridSize: 5,
        solution: [
          [true, false, false, false, true],
          [false, true, false, true, false],
          [false, false, true, false, false],
          [false, true, false, true, false],
          [true, false, false, false, true],
        ],
        isLocked: false,
      ),
      Puzzle(
        id: 'puzzle_3',
        name: 'Heart',
        difficulty: 'Medium',
        gridSize: 5,
        solution: [
          [false, true, false, true, false],
          [true, true, true, true, true],
          [true, true, true, true, true],
          [false, true, true, true, false],
          [false, false, true, false, false],
        ],
        isLocked: true,
      ),
    ];
  }
  
  /// Unlock a puzzle by ID
  void unlockPuzzle(String id) {
    final index = _puzzles.indexWhere((puzzle) => puzzle.id == id);
    if (index != -1) {
      final puzzle = _puzzles[index];
      _puzzles[index] = Puzzle(
        id: puzzle.id,
        name: puzzle.name,
        difficulty: puzzle.difficulty,
        gridSize: puzzle.gridSize,
        solution: puzzle.solution,
        isLocked: false,
      );
    }
  }
}