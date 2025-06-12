import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:logic_grid/game/grid_model.dart';
import 'package:logic_grid/game/grid_widget.dart';
import 'package:logic_grid/game/puzzle_model.dart';

class GameScreen extends StatefulWidget {
  final String? puzzleId;

  const GameScreen({super.key, this.puzzleId});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  late PuzzleRepository _puzzleRepository;
  Puzzle? _currentPuzzle;
  late AnimationController _completionAnimationController;
  late Animation<double> _completionAnimation;
  bool _isLoading = true;

  int _currentPuzzleIndex = 0;

  @override
  void initState() {
    super.initState();

    // Initialize the puzzle repository
    _puzzleRepository = PuzzleRepository();

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
        // Show the next puzzle button when the animation completes
        setState(() {});
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
        _currentPuzzle = _puzzleRepository.getPuzzleById(widget.puzzleId!) ?? 
                         _puzzleRepository.puzzles.first;
        _currentPuzzleIndex = _puzzleRepository.puzzles.indexOf(_currentPuzzle!);
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
      setState(() {
        _currentPuzzleIndex++;
        _currentPuzzle = _puzzleRepository.puzzles[_currentPuzzleIndex];

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
          title: const Text('Loading...', style: TextStyle(color: Colors.white)),
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
        gridModel.completionAnimationController = _completionAnimationController;
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
        ),
        body: Center(
          child: Container(
            width: double.infinity,
            height: double.infinity,
            color: const Color(0xFF1A1A2E),
            child: Stack(
              children: [
                SingleChildScrollView(
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
                                icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                              ),

                            const SizedBox(width: 10),

                            // Reset button
                            ElevatedButton(
                              onPressed: () {
                                gridModel.resetGrid();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0F3460),
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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

                            // Check solution button
                            ElevatedButton(
                              onPressed: () {
                                final isCorrect = gridModel.checkSolution();
                                if (!isCorrect) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Not quite right. Keep trying!'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4ECCA3),
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                            if (_currentPuzzleIndex < _puzzleRepository.puzzles.length - 1 && 
                                gridModel.isPuzzleCompleted)
                              IconButton(
                                onPressed: _goToNextPuzzle,
                                icon: const Icon(Icons.arrow_forward_ios, color: Colors.white),
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

                // Puzzle completion overlay
                Consumer<GridModel>(
                  builder: (context, gridModel, child) {
                    return AnimatedBuilder(
                      animation: _completionAnimation,
                      builder: (context, child) {
                        return gridModel.isPuzzleCompleted
                            ? Positioned.fill(
                                child: Opacity(
                                  opacity: _completionAnimation.value * 0.7,
                                  child: Container(
                                    color: Colors.black,
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          // Scale up the text during the animation
                                          Transform.scale(
                                            scale: 0.5 + (_completionAnimation.value * 0.5),
                                            child: const Text(
                                              'Puzzle Complete!',
                                              style: TextStyle(
                                                fontSize: 36,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF4ECCA3),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 20),
                                          if (_completionAnimation.value > 0.8 &&
                                              _currentPuzzleIndex < _puzzleRepository.puzzles.length - 1)
                                            ElevatedButton(
                                              onPressed: () {
                                                _goToNextPuzzle();
                                                _completionAnimationController.reset();
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: const Color(0xFF4ECCA3),
                                                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                                              ),
                                              child: const Text(
                                                'Next Puzzle',
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  color: Color(0xFF1A1A2E),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : const SizedBox.shrink();
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
