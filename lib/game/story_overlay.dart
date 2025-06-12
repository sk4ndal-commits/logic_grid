import 'package:flutter/material.dart';
import 'package:logic_grid/game/story_model.dart';

/// A widget that displays a story segment in an overlay
class StoryOverlay extends StatelessWidget {
  final StorySegment segment;
  final VoidCallback onContinue;
  final Animation<double> animation;

  const StoryOverlay({
    Key? key,
    required this.segment,
    required this.onContinue,
    required this.animation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Positioned.fill(
          child: Material(
            type: MaterialType.transparency, // Use Material to ensure proper touch handling
            child: Stack(
              children: [
                // Background overlay
                Positioned.fill(
                  child: Opacity(
                    opacity: animation.value,
                    child: Container(
                      color: Colors.black.withOpacity(0.8),
                    ),
                  ),
                ),
                // Story card that accepts pointer events
                Center(
                  child: _buildStoryCard(context),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Builds the story card with title, content, and continue button
  Widget _buildStoryCard(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: const Color(0xFF0F3460),
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
        border: Border.all(
          color: const Color(0xFF4ECCA3),
          width: 2.0,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Story title
          Text(
            segment.title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4ECCA3),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          // Divider
          Container(
            height: 2,
            width: 100,
            color: Colors.white.withOpacity(0.3),
          ),
          const SizedBox(height: 16),

          // Story content
          Text(
            segment.content,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // Continue button
          ElevatedButton(
            onPressed: onContinue,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4ECCA3),
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            child: const Text(
              'Continue',
              style: TextStyle(
                fontSize: 18,
                color: Color(0xFF1A1A2E),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
