import 'package:flutter/material.dart';
import 'package:logic_grid/screens/game_screen.dart';
import 'package:logic_grid/screens/daily_puzzle_screen.dart';
import 'package:logic_grid/game/puzzle_model.dart';

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  final PuzzleRepository _puzzleRepository = PuzzleRepository();
  bool _isLoading = true;
  bool _showPuzzleList = false;

  @override
  void initState() {
    super.initState();
    _loadPuzzles();
  }

  Future<void> _loadPuzzles() async {
    await _puzzleRepository.loadPuzzles();
    setState(() {
      _isLoading = false;
    });
  }

  void _togglePuzzleList() {
    setState(() {
      _showPuzzleList = !_showPuzzleList;
    });
  }

  void _startGame({String? puzzleId}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => GameScreen(puzzleId: puzzleId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
          ),
        ),
        child: Center(
          child: _isLoading
              ? const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4ECCA3)),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Game title
                    const Text(
                      'LogicGrid',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 2.0,
                      ),
                    ),
                    const Text(
                      'AI Archives',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w300,
                        color: Color(0xFF4ECCA3),
                        letterSpacing: 4.0,
                      ),
                    ),
                    const SizedBox(height: 60),

                    // Play button
                    ElevatedButton(
                      onPressed: () {
                        _togglePuzzleList();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4ECCA3),
                        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        _showPuzzleList ? 'HIDE PUZZLES' : 'SELECT PUZZLE',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Daily puzzle button
                    if (!_showPuzzleList)
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const DailyPuzzleScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4ECCA3),
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          'DAILY PUZZLE',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A1A2E),
                          ),
                        ),
                      ),

                    const SizedBox(height: 15),

                    // Quick play button
                    if (!_showPuzzleList)
                      ElevatedButton(
                        onPressed: () {
                          _startGame();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0F3460),
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          'QUICK PLAY',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),

                    // Puzzle list
                    if (_showPuzzleList)
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F3460).withOpacity(0.7),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListView.builder(
                            padding: const EdgeInsets.all(10),
                            itemCount: _puzzleRepository.puzzles.length,
                            itemBuilder: (context, index) {
                              final puzzle = _puzzleRepository.puzzles[index];
                              return Card(
                                color: const Color(0xFF1A1A2E),
                                margin: const EdgeInsets.symmetric(vertical: 5),
                                child: ListTile(
                                  leading: Icon(
                                    puzzle.isLocked ? Icons.lock : Icons.grid_on,
                                    color: puzzle.isLocked ? Colors.grey : const Color(0xFF4ECCA3),
                                  ),
                                  title: Text(
                                    puzzle.name,
                                    style: TextStyle(
                                      color: puzzle.isLocked ? Colors.grey : Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text(
                                    'Difficulty: ${puzzle.difficulty}',
                                    style: TextStyle(
                                      color: puzzle.isLocked ? Colors.grey.shade600 : Colors.white70,
                                    ),
                                  ),
                                  trailing: Icon(
                                    Icons.play_circle_filled,
                                    color: puzzle.isLocked ? Colors.grey : const Color(0xFF4ECCA3),
                                  ),
                                  enabled: !puzzle.isLocked,
                                  onTap: puzzle.isLocked
                                      ? null
                                      : () {
                                          _startGame(puzzleId: puzzle.id);
                                        },
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                    // Settings button (placeholder for future implementation)
                    if (!_showPuzzleList)
                      TextButton(
                        onPressed: () {
                          // Will be implemented in future steps
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Settings coming soon!')),
                          );
                        },
                        child: const Text(
                          'Settings',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                  ],
                ),
        ),
      ),
    );
  }
}
