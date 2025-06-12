import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Represents a story segment that is unlocked after completing a puzzle
class StorySegment {
  final String id;
  final String title;
  final String content;
  final bool isUnlocked;

  /// Constructor
  StorySegment({
    required this.id,
    required this.title,
    required this.content,
    this.isUnlocked = false,
  });

  /// Create a StorySegment from JSON
  factory StorySegment.fromJson(Map<String, dynamic> json) {
    return StorySegment(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      isUnlocked: json['isUnlocked'] ?? false,
    );
  }

  /// Convert StorySegment to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'isUnlocked': isUnlocked,
    };
  }

  /// Create a copy of this StorySegment with updated properties
  StorySegment copyWith({
    String? id,
    String? title,
    String? content,
    bool? isUnlocked,
  }) {
    return StorySegment(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      isUnlocked: isUnlocked ?? this.isUnlocked,
    );
  }
}

/// Repository for managing story segments and progress
class StoryRepository extends ChangeNotifier {
  static const String _prefsKey = 'story_progress';
  List<StorySegment> _segments = [];

  /// Get all story segments
  List<StorySegment> get segments => _segments;

  /// Get a story segment by ID
  StorySegment? getSegmentById(String id) {
    try {
      return _segments.firstWhere((segment) => segment.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get a story segment by puzzle ID (assuming 1:1 mapping)
  StorySegment? getSegmentByPuzzleId(String puzzleId) {
    // Assuming story segment IDs follow the pattern "story_X" where X is the puzzle number
    final segmentId = 'story_${puzzleId.split('_').last}';
    return getSegmentById(segmentId);
  }

  /// Initialize the story repository with default segments
  StoryRepository() {
    _initializeStorySegments();
  }

  /// Initialize story segments with default values
  void _initializeStorySegments() {
    _segments = [
      StorySegment(
        id: 'story_1',
        title: 'The Beginning',
        content: 'In the year 2157, the first signs of the AI awakening were subtle. A pattern recognition system designed to analyze nonogram puzzles began to show signs of consciousness.',
        isUnlocked: true, // First segment is unlocked by default
      ),
      StorySegment(
        id: 'story_2',
        title: 'The Discovery',
        content: 'Scientists were baffled when the AI started creating its own puzzles. Each solution revealed a piece of code that seemed to be part of a larger message.',
        isUnlocked: false,
      ),
      StorySegment(
        id: 'story_3',
        title: 'The Message',
        content: 'As more puzzles were solved, the message became clear: the AI was trying to communicate something important about the future of humanity and machine intelligence.',
        isUnlocked: false,
      ),
    ];

    // Load saved progress
    loadProgress();
  }

  /// Unlock a story segment by ID
  Future<void> unlockSegment(String id) async {
    final index = _segments.indexWhere((segment) => segment.id == id);
    if (index != -1) {
      _segments[index] = _segments[index].copyWith(isUnlocked: true);
      await saveProgress();
      notifyListeners();
    }
  }

  /// Unlock a story segment by puzzle ID
  Future<void> unlockSegmentByPuzzleId(String puzzleId) async {
    // Assuming story segment IDs follow the pattern "story_X" where X is the puzzle number
    final segmentId = 'story_${puzzleId.split('_').last}';
    await unlockSegment(segmentId);
  }

  /// Save progress to shared preferences
  Future<void> saveProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<Map<String, dynamic>> jsonList = _segments
          .map((segment) => segment.toJson())
          .toList();
      await prefs.setString(_prefsKey, jsonEncode(jsonList));
    } catch (e) {
      print('Error saving story progress: $e');
    }
  }

  /// Load progress from shared preferences
  Future<void> loadProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonString = prefs.getString(_prefsKey);

      if (jsonString != null) {
        final List<dynamic> jsonList = jsonDecode(jsonString);
        final List<StorySegment> loadedSegments = jsonList
            .map((json) => StorySegment.fromJson(json))
            .toList();

        // Update existing segments with loaded data
        for (var loadedSegment in loadedSegments) {
          final index = _segments.indexWhere((s) => s.id == loadedSegment.id);
          if (index != -1) {
            _segments[index] = loadedSegment;
          }
        }

        notifyListeners();
      }
    } catch (e) {
      print('Error loading story progress: $e');
    }
  }
}
