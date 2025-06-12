import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:logic_grid/game/grid_model.dart';
import 'package:logic_grid/game/grid_widget.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => GridModel(),
      child: Scaffold(
        backgroundColor: const Color(0xFF1A1A2E),
        appBar: AppBar(
          backgroundColor: const Color(0xFF0F3460),
          title: const Text(
            'LogicGrid',
            style: TextStyle(color: Colors.white),
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Nonogram Puzzle',
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.white,
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
                          onPressed: () {
                            final isCorrect = gridModel.checkSolution();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  isCorrect ? 'Correct! Well done!' : 'Not quite right. Keep trying!',
                                ),
                                backgroundColor: isCorrect ? Colors.green : Colors.red,
                              ),
                            );
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
        ),
      ),
    );
  }
}
