import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:logic_grid/game/grid_model.dart';

/// Widget that displays the nonogram grid with clues
class GridWidget extends StatelessWidget {
  const GridWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GridModel>(
      builder: (context, gridModel, child) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Column clues and grid
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Empty space in top-left corner
                  SizedBox(
                    width: 60,
                    height: 60,
                  ),

                  // Column clues
                  _buildColumnClues(gridModel),
                ],
              ),

              // Row clues and grid cells
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Row clues
                  _buildRowClues(gridModel),

                  // Grid cells
                  _buildGrid(context, gridModel),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  /// Builds the column clues (numbers at the top of each column)
  Widget _buildColumnClues(GridModel gridModel) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(gridModel.gridSize, (col) {
        return Container(
          width: 40,
          height: 60,
          alignment: Alignment.bottomCenter,
          padding: EdgeInsets.only(bottom: 5),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ...gridModel.columnClues[col].map((clue) => Text(
                clue.toString(),
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              )),
            ],
          ),
        );
      }),
    );
  }

  /// Builds the row clues (numbers at the left of each row)
  Widget _buildRowClues(GridModel gridModel) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(gridModel.gridSize, (row) {
        return Container(
          width: 60,
          height: 40,
          alignment: Alignment.centerRight,
          padding: EdgeInsets.only(right: 5),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ...gridModel.rowClues[row].map((clue) => Padding(
                padding: EdgeInsets.only(right: 5),
                child: Text(
                  clue.toString(),
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              )),
            ],
          ),
        );
      }),
    );
  }

  /// Builds the main grid of cells
  Widget _buildGrid(BuildContext context, GridModel gridModel) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(gridModel.gridSize, (row) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(gridModel.gridSize, (col) {
              return _buildCell(context, gridModel, row, col);
            }),
          );
        }),
      ),
    );
  }

  /// Builds an individual cell in the grid
  Widget _buildCell(BuildContext context, GridModel gridModel, int row, int col) {
    final cellState = gridModel.grid[row][col];
    final isCorrectRow = gridModel.isRowCorrect(row);
    final isCorrectCol = gridModel.isColumnCorrect(col);

    return GestureDetector(
      onTap: () {
        gridModel.toggleCellState(row, col);
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: _getCellColor(cellState),
          border: Border.all(
            color: Colors.grey.shade700,
            width: 1,
          ),
        ),
        child: Center(
          child: _getCellContent(cellState),
        ),
      ),
    );
  }

  /// Gets the background color for a cell based on its state
  Color _getCellColor(CellState state) {
    if (state == CellState.filled) {
      return const Color(0xFF4ECCA3); // Green for filled cells
    } else if (state == CellState.hint) {
      return const Color(0xFFE94560); // Red for hint cells
    } else {
      return const Color(0xFF0F3460); // Dark blue for empty/marked cells
    }
  }

  /// Gets the content (icon or text) for a cell based on its state
  Widget _getCellContent(CellState state) {
    if (state == CellState.marked) {
      return const Text(
        'X',
        style: TextStyle(
          color: Colors.red,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      );
    } else if (state == CellState.hint) {
      return const Icon(
        Icons.lightbulb,
        color: Colors.white,
        size: 20,
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}
