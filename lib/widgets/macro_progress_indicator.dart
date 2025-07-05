import 'package:flutter/material.dart';

class MacroProgressIndicator extends StatelessWidget {
    final String label;
    final double consumed;
    final double goal;
    final String unit;

    const MacroProgressIndicator({
        super.key,
        required this.label, 
        required this.consumed, 
        required this.goal,
        required this.unit,
    });
    
    @override
    Widget build(BuildContext context) {
        final double progress = (goal > 0 && consumed > 0) ? (consumed / goal).clamp(0.0, 1.0) : 0.0;
        final double remaining = goal - consumed;

        return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                            Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            Text(
                                "${consumed.toStringAsFixed(0)} / ${goal.toStringAsFixed(0)} $unit",
                                style: Theme.of(context).textTheme.bodySmall,
                            ),
                        ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: Colors.grey[800],
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.red),
                          minHeight: 12,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                            "Restante: ${remaining.toStringAsFixed(0)} $unit",
                            style: TextStyle(
                              color: remaining < 0 ? Colors.redAccent : Colors.greenAccent[400],
                              fontSize: 12,
                            ),
                        ),
                    ),
                ],
            ),
        );
    }
}