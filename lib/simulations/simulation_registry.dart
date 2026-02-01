import 'package:flutter/material.dart';
import '../models/topic.dart';
import 'wave_simulation.dart';
import 'circuit_simulation.dart';
import 'magnet_simulation.dart';
import 'forces_simulation.dart';
import 'light_simulation.dart';
import 'energy_simulation.dart';
import 'solar_system_simulation.dart';
import 'momentum_simulation.dart';
import 'pressure_simulation.dart';
import 'particle_simulation.dart';
import 'radioactive_decay_simulation.dart';
import 'spring_simulation.dart';
import 'static_electricity_simulation.dart';
import 'moments_simulation.dart';
import 'thermal_simulation.dart';
// New simulations
import 'projectile_motion_simulation.dart';
import 'ohms_law_simulation.dart';
import 'lenses_simulation.dart';
import 'nuclear_fission_simulation.dart';
import 'doppler_effect_simulation.dart';
import 'transformer_simulation.dart';
import 'specific_heat_simulation.dart';
import 'orbits_simulation.dart';
import 'motor_effect_simulation.dart';
import 'generator_simulation.dart';
import 'half_life_simulation.dart';
import 'sound_waves_simulation.dart';
import 'refraction_simulation.dart';
import 'electromagnetic_spectrum_simulation.dart';
import 'terminal_velocity_simulation.dart';
import 'wave_interference_simulation.dart';
import 'capacitors_simulation.dart';
import 'pendulum_simulation.dart';
import 'mirrors_simulation.dart';
import 'nuclear_fusion_simulation.dart';
import 'density_simulation.dart';
import 'parallel_circuit_simulation.dart';
import 'series_circuit_simulation.dart';
// Additional new simulations
import 'free_fall_simulation.dart';
import 'friction_simulation.dart';
import 'centripetal_simulation.dart';
import 'inclined_plane_simulation.dart';
import 'pulley_simulation.dart';
import 'diffraction_simulation.dart';
import 'standing_waves_simulation.dart';
import 'latent_heat_simulation.dart';
import 'potentialdivider_simulation.dart';
import 'newtons_cradle_simulation.dart';
import 'radiation_types_simulation.dart';
import 'satellites_simulation.dart';
import 'total_internal_reflection_simulation.dart';
import 'energy_efficiency_simulation.dart';
import 'electromagnet_simulation.dart';
import 'simple_machines_simulation.dart';
import 'electrolysis_simulation.dart';
import 'voltmeter_simulation.dart';
import 'electroplating_simulation.dart';

/// Registry for all physics simulations.
/// Add new simulations by:
/// 1. Adding the SimulationType to the enum in topic.dart
/// 2. Creating the simulation widget file
/// 3. Importing it here and adding to the _simulations map
class SimulationRegistry {
  static final Map<SimulationType, Widget Function()> _simulations = {
    SimulationType.waves: () => const WaveSimulation(),
    SimulationType.circuits: () => const CircuitSimulation(),
    SimulationType.magnetism: () => const MagnetSimulation(),
    SimulationType.forces: () => const ForcesSimulation(),
    SimulationType.light: () => const LightSimulation(),
    SimulationType.energy: () => const EnergySimulation(),
    SimulationType.solarSystem: () => const SolarSystemSimulation(),
    SimulationType.momentum: () => const MomentumSimulation(),
    SimulationType.pressure: () => const PressureSimulation(),
    SimulationType.particles: () => const ParticleSimulation(),
    SimulationType.radioactiveDecay: () => const RadioactiveDecaySimulation(),
    SimulationType.springs: () => const SpringSimulation(),
    SimulationType.staticElectricity: () => const StaticElectricitySimulation(),
    SimulationType.moments: () => const MomentsSimulation(),
    SimulationType.thermal: () => const ThermalSimulation(),
    // New simulations
    SimulationType.projectileMotion: () => const ProjectileMotionSimulation(),
    SimulationType.ohmsLaw: () => const OhmsLawSimulation(),
    SimulationType.lenses: () => const LensesSimulation(),
    SimulationType.nuclearFission: () => const NuclearFissionSimulation(),
    SimulationType.dopplerEffect: () => const DopplerEffectSimulation(),
    SimulationType.transformer: () => const TransformerSimulation(),
    SimulationType.specificHeatCapacity: () => const SpecificHeatSimulation(),
    SimulationType.orbits: () => const OrbitsSimulation(),
    SimulationType.motorEffect: () => const MotorEffectSimulation(),
    SimulationType.generator: () => const GeneratorSimulation(),
    SimulationType.halfLife: () => const HalfLifeSimulation(),
    SimulationType.soundWaves: () => const SoundWavesSimulation(),
    SimulationType.refraction: () => const RefractionSimulation(),
    SimulationType.electromagneticSpectrum: () => const ElectromagneticSpectrumSimulation(),
    SimulationType.terminalVelocity: () => const TerminalVelocitySimulation(),
    SimulationType.waveInterference: () => const WaveInterferenceSimulation(),
    SimulationType.capacitorCharging: () => const CapacitorsSimulation(),
    SimulationType.pendulum: () => const PendulumSimulation(),
    SimulationType.mirrors: () => const MirrorsSimulation(),
    SimulationType.nuclearFusion: () => const NuclearFusionSimulation(),
    SimulationType.density: () => const DensitySimulation(),
    SimulationType.resistorsInParallel: () => const ParallelCircuitSimulation(),
    SimulationType.resistorsInSeries: () => const SeriesCircuitSimulation(),
    // Additional new simulations
    SimulationType.freeFall: () => const FreeFallSimulation(),
    SimulationType.friction: () => const FrictionSimulation(),
    SimulationType.centripetal: () => const CentripetalSimulation(),
    SimulationType.inclinedPlane: () => const InclinedPlaneSimulation(),
    SimulationType.pulleySystem: () => const PulleySimulation(),
    SimulationType.diffraction: () => const DiffractionSimulation(),
    SimulationType.standingWaves: () => const StandingWavesSimulation(),
    SimulationType.latentHeat: () => const LatentHeatSimulation(),
    SimulationType.potentialDivider: () => const PotentialDividerSimulation(),
    SimulationType.newtonsCradle: () => const NewtonsCradleSimulation(),
    SimulationType.radiationTypes: () => const RadiationTypesSimulation(),
    SimulationType.satellites: () => const SatellitesSimulation(),
    SimulationType.totalInternalReflection: () => const TotalInternalReflectionSimulation(),
    SimulationType.energyEfficiency: () => const EnergyEfficiencySimulation(),
    SimulationType.electromagnetStrength: () => const ElectromagnetSimulation(),
    // Simple Machines & Electrolysis
    SimulationType.simpleMachines: () => const SimpleMachinesSimulation(),
    SimulationType.electrolysis: () => const ElectrolysisSimulation(),
    SimulationType.voltmeter: () => const VoltmeterSimulation(),
    SimulationType.electroplating: () => const ElectroplatingSimulation(),
  };

  /// Get the simulation widget for a given type
  static Widget getSimulation(SimulationType type) {
    final builder = _simulations[type];
    if (builder != null) {
      return builder();
    }
    return _buildPlaceholder(type);
  }

  /// Check if a simulation type is implemented
  static bool isImplemented(SimulationType type) {
    return _simulations.containsKey(type);
  }

  /// Get list of all implemented simulation types
  static List<SimulationType> getImplementedTypes() {
    return _simulations.keys.toList();
  }

  /// Placeholder for simulations that are not yet implemented
  static Widget _buildPlaceholder(SimulationType type) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.construction,
            size: 64,
            color: Colors.orange,
          ),
          const SizedBox(height: 16),
          Text(
            'Simulation Coming Soon',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${type.name} simulation is under development',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
