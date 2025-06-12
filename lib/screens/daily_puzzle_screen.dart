import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:logic_grid/game/grid_model.dart';
import 'package:logic_grid/game/grid_widget.dart';
import 'package:logic_grid/game/puzzle_model.dart';
import 'package:logic_grid/game/daily_puzzle_service.dart';

class DailyPuzzleScreen extends StatefulWidget {
  const DailyPuzzleScreen({super.key});

  @override
  State<DailyPuzzleScreen> createState() => _DailyPuzzleScreenState();
}

class _DailyPuzzleScreenState extends State<DailyPuzzleScreen> with TickerProviderStateMixin {
  late PuzzleRepository _puzzleRepository;
  late DailyPuzzleService _dailyPuzzleService;
  Puzzle? _dailyPuzzle;
  late AnimationController _completionAnimationController;
  late Animation<double> _completionAnimation;
  bool _isLoading = true;
  bool _isPuzzleSolved = false;

  @override
  void initState() {
    super.initState();

    // Initialize the puzzle repository
    _puzzleRepository = PuzzleRepository();

    // Initialize the daily puzzle service
    _dailyPuzzleService = DailyPuzzleService(puzzleRepository: _puzzleRepository);

    // Load the daily puzzle
    _loadDailyPuzzle();

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
        // When animation completes, mark the puzzle as solved if it's not already
        if (!_isPuzzleSolved) {
          _dailyPuzzleService.markDailyPuzzleSolved().then((_) {
            setState(() {
              _isPuzzleSolved = true;
            });
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _completionAnimationController.dispose();
    super.dispose();
  }

  Future<void> _loadDailyPuzzle() async {
    setState(() {
      _isLoading = true;
    });

    // Check if the puzzle has already been solved today
    _isPuzzleSolved = await _dailyPuzzleService.isDailyPuzzleSolved();

    // Get the daily puzzle
    _dailyPuzzle = await _dailyPuzzleService.getDailyPuzzle();

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFF1A1A2E),
        appBar: AppBar(
          backgroundColor: const Color(0xFF0F3460),
          title: const Text('Daily Puzzle', style: TextStyle(color: Colors.white)),
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

    if (_dailyPuzzle == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF1A1A2E),
        appBar: AppBar(
          backgroundColor: const Color(0xFF0F3460),
          title: const Text('Daily Puzzle', style: TextStyle(color: Colors.white)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: const Center(
          child: Text(
            'No daily puzzle available',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ),
      );
    }

    return ChangeNotifierProvider(
      create: (context) {
        // Use the daily puzzle
        final gridModel = GridModel(puzzle: _dailyPuzzle);
        gridModel.completionAnimationController = _completionAnimationController;
        return gridModel;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF1A1A2E),
        appBar: AppBar(
          backgroundColor: const Color(0xFF0F3460),
          title: const Text('Daily Puzzle', style: TextStyle(color: Colors.white)),
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
                      const SizedBox(height: 20),

                      // Today's date
                      Text(
                        'Today: ${DateTime.now().toLocal().toString().split(' ')[0]}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Puzzle name and difficulty
                      Consumer<GridModel>(
                        builder: (context, gridModel, child) {
                          return Column(
                            children: [
                              Text(
                                gridModel.puzzle.name,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF4ECCA3),
                                ),
                              ),
                              Text(
                                'Difficulty: ${gridModel.puzzle.difficulty}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          );
                        },
                      ),

                      const SizedBox(height: 20),

                      // Already solved message
                      if (_isPuzzleSolved)
                        Container(
                          padding: const EdgeInsets.all(10),
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F3460),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'You\'ve already solved today\'s puzzle! Come back tomorrow for a new challenge.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
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
                                onPressed: () async {
                                  final isCorrect = gridModel.checkSolution();
                                  if (isCorrect) {
                                    // Start the completion animation
                                    _completionAnimationController.forward(from: 0.0);

                                    // Mark the daily puzzle as solved
                                    await _dailyPuzzleService.markDailyPuzzleSolved();
                                    setState(() {
                                      _isPuzzleSolved = true;
                                    });
                                  } else {
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
                    if (!gridModel.isPuzzleCompleted) {
                      return const SizedBox.shrink();
                    }

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
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      // Scale up the text during the animation
                                      Transform.scale(
                                        scale: 0.5 + (_completionAnimation.value * 0.5),
                                        child: const Text(
                                          'Daily Puzzle Complete!',
                                          style: TextStyle(
                                            fontSize: 36,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF4ECCA3),
                                          ),
                                        ),
                                      ),
                                      if (_completionAnimation.value > 0.5)
                                        Opacity(
                                          opacity: (_completionAnimation.value - 0.5) * 2,
                                          child: const Padding(
                                            padding: EdgeInsets.all(20.0),
                                            child: Text(
                                              'Come back tomorrow for a new challenge!',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 18,
                                                color: Colors.white,
                                              ),
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
    );
  }
}
