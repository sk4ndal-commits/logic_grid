import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logic_grid/game/puzzle_model.dart';

/// Service for managing daily puzzles
class DailyPuzzleService {
  static const String _dailyPuzzleIdKey = 'daily_puzzle_id';
  static const String _dailyPuzzleDateKey = 'daily_puzzle_date';
  static const String _dailyPuzzleSolvedKey = 'daily_puzzle_solved';
  
  final PuzzleRepository _puzzleRepository;
  
  /// Constructor
  DailyPuzzleService({required PuzzleRepository puzzleRepository})
      : _puzzleRepository = puzzleRepository;
  
  /// Get today's date as a string in the format YYYY-MM-DD
  String _getTodayDateString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
  
  /// Generate a seed based on the current date
  int _generateDailySeed() {
    final dateString = _getTodayDateString();
    // Simple hash function to convert date string to a number
    int seed = 0;
    for (int i = 0; i < dateString.length; i++) {
      seed = (seed * 31 + dateString.codeUnitAt(i)) % 2147483647;
    }
    return seed;
  }
  
  /// Get or generate the daily puzzle
  Future<Puzzle?> getDailyPuzzle() async {
    final prefs = await SharedPreferences.getInstance();
    final todayString = _getTodayDateString();
    final savedDate = prefs.getString(_dailyPuzzleDateKey);
    
    // If we already have a puzzle for today, return it
    if (savedDate == todayString) {
      final puzzleId = prefs.getString(_dailyPuzzleIdKey);
      if (puzzleId != null) {
        return _puzzleRepository.getPuzzleById(puzzleId);
      }
    }
    
    // Otherwise, generate a new daily puzzle
    return _generateAndSaveDailyPuzzle();
  }
  
  /// Generate a new daily puzzle and save it
  Future<Puzzle?> _generateAndSaveDailyPuzzle() async {
    // Make sure puzzles are loaded
    if (_puzzleRepository.puzzles.isEmpty) {
      await _puzzleRepository.loadPuzzles();
    }
    
    // If there are no puzzles, return null
    if (_puzzleRepository.puzzles.isEmpty) {
      return null;
    }
    
    // Use the daily seed to select a random puzzle
    final seed = _generateDailySeed();
    final random = Random(seed);
    final puzzleIndex = random.nextInt(_puzzleRepository.puzzles.length);
    final puzzle = _puzzleRepository.puzzles[puzzleIndex];
    
    // Save the puzzle ID and today's date
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_dailyPuzzleIdKey, puzzle.id);
    await prefs.setString(_dailyPuzzleDateKey, _getTodayDateString());
    await prefs.setBool(_dailyPuzzleSolvedKey, false);
    
    return puzzle;
  }
  
  /// Check if the daily puzzle has been solved
  Future<bool> isDailyPuzzleSolved() async {
    final prefs = await SharedPreferences.getInstance();
    final todayString = _getTodayDateString();
    final savedDate = prefs.getString(_dailyPuzzleDateKey);
    
    // If we don't have a puzzle for today, it's not solved
    if (savedDate != todayString) {
      return false;
    }
    
    // Return the solved status
    return prefs.getBool(_dailyPuzzleSolvedKey) ?? false;
  }
  
  /// Mark the daily puzzle as solved
  Future<void> markDailyPuzzleSolved() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_dailyPuzzleSolvedKey, true);
  }
}