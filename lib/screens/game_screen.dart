import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:logic_grid/game/logic_grid_game.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        // This is a placeholder for the actual Flame game
        // In the future, we'll replace this with a GameWidget<LogicGridGame>
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: const Color(0xFF1A1A2E),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Game Screen Placeholder',
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  color: const Color(0xFF0F3460),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF4ECCA3), width: 2),
                ),
                child: const Center(
                  child: Text(
                    'Nonogram Puzzle\nComing Soon',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4ECCA3),
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                ),
                child: const Text(
                  'Back to Menu',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF1A1A2E),
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