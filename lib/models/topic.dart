import 'package:flutter/material.dart';

class Topic {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final List<Lesson> lessons;
  final List<Quiz> quizzes;
  final List<PhysicsSimulation> simulations;

  const Topic({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.lessons,
    required this.quizzes,
    required this.simulations,
  });
}

class Lesson {
  final String id;
  final String title;
  final String content;
  final List<String> keyPoints;
  final List<String> formulas;
  final String? imagePath;

  const Lesson({
    required this.id,
    required this.title,
    required this.content,
    required this.keyPoints,
    this.formulas = const [],
    this.imagePath,
  });
}

class Quiz {
  final String id;
  final String title;
  final List<Question> questions;

  const Quiz({
    required this.id,
    required this.title,
    required this.questions,
  });
}

class Question {
  final String id;
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;
  final String? formula;

  const Question({
    required this.id,
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
    this.formula,
  });
}

class PhysicsSimulation {
  final String id;
  final String title;
  final String description;
  final SimulationType type;

  const PhysicsSimulation({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
  });
}

enum SimulationType {
  // Existing simulations (15)
  waves,
  circuits,
  magnetism,
  forces,
  light,
  energy,
  particles,
  solarSystem,
  momentum,
  pressure,
  radioactiveDecay,
  springs,
  staticElectricity,
  moments,
  thermal,

  // Forces and Motion (11 new)
  projectileMotion,
  freeFall,
  terminalVelocity,
  friction,
  airResistance,
  centripetal,
  newtonsCradle,
  inclinedPlane,
  pulleySystem,
  gravityField,
  pendulum,

  // Waves and Sound (8 new)
  soundWaves,
  ultraSound,
  seismicWaves,
  waveInterference,
  diffraction,
  standingWaves,
  dopplerEffect,
  echoLocation,

  // Electricity (9 new)
  ohmsLaw,
  resistorsInSeries,
  resistorsInParallel,
  potentialDivider,
  capacitors,
  capacitorCharging,
  diodes,
  transistors,
  electromagneticInduction,

  // Magnetism and EM (5 new)
  motorEffect,
  generator,
  transformer,
  electromagnetStrength,
  magneticFieldLines,

  // Light and Optics (8 new)
  lenses,
  mirrors,
  refraction,
  totalInternalReflection,
  colourSpectrum,
  electromagneticSpectrum,
  eyeAndVision,
  opticalFibres,

  // Energy (5 new)
  specificHeatCapacity,
  latentHeat,
  thermalInsulation,
  energyEfficiency,
  powerStations,

  // Nuclear Physics (5 new)
  nuclearFission,
  nuclearFusion,
  halfLife,
  halfLifeGraph,
  radiationTypes,

  // Space (4 new)
  orbits,
  satellites,
  lifeCycleOfStars,
  bigBang,

  // Practical Skills (6 new)
  measuringDensity,
  density,
  measuringAcceleration,
  investigatingResistance,
  measuringWavelength,
  investigatingSpecificHeat,
  // Simple Machines & Electrolysis
  simpleMachines,
  electrolysis,
  voltmeter,
  electroplating,
  // Calculus
  differentiation,
  integration,
}
