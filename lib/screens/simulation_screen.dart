import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/topic.dart';
import '../providers/app_provider.dart';
import '../simulations/simulation_registry.dart';

class SimulationScreen extends StatefulWidget {
  final PhysicsSimulation simulation;
  final Topic topic;

  const SimulationScreen({
    super.key,
    required this.simulation,
    required this.topic,
  });

  @override
  State<SimulationScreen> createState() => _SimulationScreenState();
}

class _SimulationScreenState extends State<SimulationScreen> {
  @override
  void initState() {
    super.initState();
    // Mark simulation as viewed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppProvider>().markSimulationViewed(
            widget.topic.id,
            widget.simulation.id,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.simulation.title),
        backgroundColor: widget.topic.color,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Simulation area
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    widget.topic.color.withValues(alpha: 0.1),
                    Colors.black,
                  ],
                ),
              ),
              child: _buildSimulation(),
            ),
          ),
          // Description
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: widget.topic.color.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.science, color: widget.topic.color),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.simulation.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  widget.simulation.description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Interact with the simulation above to explore the concept!',
                  style: TextStyle(
                    color: widget.topic.color,
                    fontStyle: FontStyle.italic,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimulation() {
    return SimulationRegistry.getSimulation(widget.simulation.type);
  }
}
