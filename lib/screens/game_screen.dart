import 'package:flutter/material.dart';
import 'package:logic_grid/game/grid_model.dart';
import 'package:logic_grid/game/grid_widget.dart';
import 'package:logic_grid/game/puzzle_model.dart';
import 'package:logic_grid/game/story_model.dart';
import 'package:logic_grid/game/story_overlay.dart';
import 'package:provider/provider.dart';

class GameScreen extends StatefulWidget {
  final String? puzzleId;

  const GameScreen({super.key, this.puzzleId});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  late PuzzleRepository _puzzleRepository;
  late StoryRepository _storyRepository;
  Puzzle? _currentPuzzle;
  late AnimationController _completionAnimationController;
  late Animation<double> _completionAnimation;
  bool _isLoading = true;
  bool _showingStory = false;

  int _currentPuzzleIndex = 0;

  @override
  void initState() {
    super.initState();

    // Initialize the puzzle repository
    _puzzleRepository = PuzzleRepository();

    // Initialize the story repository
    _storyRepository = StoryRepository();

    // Load puzzles
    _loadPuzzles();

    // Initialize the completion animation controller
    _completionAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Create the completion animation
    _completionAnimation = CurvedAnimation(
      parent: _completionAnimationController,
      curve: Curves.easeInOut,
    );

    // Add a listener to the animation controller
    _completionAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // Show the story overlay when the animation completes
        setState(() {
          _showingStory = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _completionAnimationController.dispose();
    super.dispose();
  }

  Future<void> _loadPuzzles() async {
    setState(() {
      _isLoading = true;
    });

    await _puzzleRepository.loadPuzzles();

    setState(() {
      // If a specific puzzle ID was provided, use that puzzle
      if (widget.puzzleId != null) {
        _currentPuzzle =
            _puzzleRepository.getPuzzleById(widget.puzzleId!) ??
            _puzzleRepository.puzzles.first;
        _currentPuzzleIndex = _puzzleRepository.puzzles.indexOf(
          _currentPuzzle!,
        );
      } else {
        // Otherwise, use the first puzzle
        _currentPuzzle = _puzzleRepository.puzzles.first;
        _currentPuzzleIndex = 0;
      }
      _isLoading = false;
    });
  }

  void _goToNextPuzzle() {
    if (_currentPuzzleIndex < _puzzleRepository.puzzles.length - 1) {
      // Unlock the next story segment for the current puzzle
      if (_currentPuzzle != null) {
        _storyRepository.unlockSegmentByPuzzleId(_currentPuzzle!.id);
      }

      setState(() {
        _currentPuzzleIndex++;
        _currentPuzzle = _puzzleRepository.puzzles[_currentPuzzleIndex];
        // Note: _showingStory is now set to false in the onContinue callback
        // before calling this method, so we don't need to set it again here.

        // Unlock the next puzzle if it's locked
        if (_currentPuzzle!.isLocked) {
          _puzzleRepository.unlockPuzzle(_currentPuzzle!.id);
        }
      });
    }
  }

  void _goToPreviousPuzzle() {
    if (_currentPuzzleIndex > 0) {
      setState(() {
        _currentPuzzleIndex--;
        _currentPuzzle = _puzzleRepository.puzzles[_currentPuzzleIndex];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFF1A1A2E),
        appBar: AppBar(
          backgroundColor: const Color(0xFF0F3460),
          title: const Text(
            'Loading...',
            style: TextStyle(color: Colors.white),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4ECCA3)),
          ),
        ),
      );
    }

    return ChangeNotifierProvider(
      create: (context) {
        // Use the current puzzle or let GridModel use its default
        final gridModel = GridModel(puzzle: _currentPuzzle);
        gridModel.completionAnimationController =
            _completionAnimationController;
        return gridModel;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF1A1A2E),
        appBar: AppBar(
          backgroundColor: const Color(0xFF0F3460),
          title: Consumer<GridModel>(
            builder: (context, gridModel, child) {
              return Text(
                gridModel.puzzle.name,
                style: const TextStyle(color: Colors.white),
              );
            },
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          // Add top padding to prevent camera overlap with title
          toolbarHeight: 60,
          titleSpacing: 0,
          titleTextStyle: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        body: SafeArea(
          child: Center(
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: const Color(0xFF1A1A2E),
              child: Stack(
                children: [
                  SingleChildScrollView(
                    // Add padding to ensure content is not obscured and all cells are clickable
                    padding: const EdgeInsets.only(top: 20, bottom: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Consumer<GridModel>(
                          builder: (context, gridModel, child) {
                            return Text(
                              'Difficulty: ${gridModel.puzzle.difficulty}',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white70,
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 20),

                        // Grid widget with clues
                        const GridWidget(),

                        const SizedBox(height: 30),

                        // Game controls
                        Consumer<GridModel>(
                          builder: (context, gridModel, child) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Previous puzzle button
                                if (_currentPuzzleIndex > 0)
                                  IconButton(
                                    onPressed: _goToPreviousPuzzle,
                                    icon: const Icon(
                                      Icons.arrow_back_ios,
                                      color: Colors.white,
                                    ),
                                  ),

                                const SizedBox(width: 10),

                                // Reset button
                                ElevatedButton(
                                  onPressed: () {
                                    gridModel.resetGrid();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF0F3460),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 10,
                                    ),
                                  ),
                                  child: const Text(
                                    'Reset',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 20),

                                // Hint button
                                ElevatedButton(
                                  onPressed: gridModel.hintsRemaining > 0
                                      ? () {
                                          gridModel.revealHint();
                                        }
                                      : null,
                                  // Disable button when no hints remaining
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFE94560),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 10,
                                    ),
                                    // Dim the button when disabled
                                    disabledBackgroundColor: const Color(
                                      0xFFE94560,
                                    ).withOpacity(0.3),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text(
                                        'Hint',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        '(${gridModel.hintsRemaining})',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 20),

                                // Check solution button
                                ElevatedButton(
                                  onPressed: () {
                                    final isCorrect = gridModel.checkSolution();
                                    if (!isCorrect) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Not quite right. Keep trying!',
                                          ),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF4ECCA3),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 10,
                                    ),
                                  ),
                                  child: const Text(
                                    'Check',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Color(0xFF1A1A2E),
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 10),

                                // Next puzzle button
                                if (_currentPuzzleIndex <
                                        _puzzleRepository.puzzles.length - 1 &&
                                    gridModel.isPuzzleCompleted &&
                                    !_showingStory)
                                  IconButton(
                                    onPressed: _goToNextPuzzle,
                                    icon: const Icon(
                                      Icons.arrow_forward_ios,
                                      color: Colors.white,
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),

                        const SizedBox(height: 20),

                        // Back to menu button
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text(
                            'Back to Menu',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Puzzle completion and story overlay
                  Consumer<GridModel>(
                    builder: (context, gridModel, child) {
                      if (!gridModel.isPuzzleCompleted) {
                        return const SizedBox.shrink();
                      }

                      // If showing story, display the story overlay
                      if (_showingStory && _currentPuzzle != null) {
                        // Get the story segment for the current puzzle
                        final storySegment = _storyRepository
                            .getSegmentByPuzzleId(_currentPuzzle!.id);

                        if (storySegment != null) {
                          // Use the StoryOverlay directly - it now handles pointer events correctly
                          return StoryOverlay(
                            segment: storySegment,
                            animation: _completionAnimation,
                            onContinue: () {
                              // First, hide the story overlay
                              setState(() {
                                _showingStory = false;
                              });

                              // Then, handle navigation immediately without using Future.delayed
                              if (_currentPuzzleIndex <
                                  _puzzleRepository.puzzles.length - 1) {
                                _goToNextPuzzle();
                                _completionAnimationController.reset();
                              }
                            },
                          );
                        }
                      }

                      // Otherwise show the completion message
                      return AnimatedBuilder(
                        animation: _completionAnimation,
                        builder: (context, child) {
                          return Positioned.fill(
                            child: IgnorePointer(
                              // Ignore pointer events so buttons underneath remain clickable
                              ignoring: true,
                              child: Opacity(
                                opacity: _completionAnimation.value * 0.7,
                                child: Container(
                                  color: Colors.black,
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        // Scale up the text during the animation
                                        Transform.scale(
                                          scale:
                                              0.5 +
                                              (_completionAnimation.value *
                                                  0.5),
                                          child: const Text(
                                            'Puzzle Complete!',
                                            style: TextStyle(
                                              fontSize: 36,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF4ECCA3),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
