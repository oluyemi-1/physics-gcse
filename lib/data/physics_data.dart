import 'package:flutter/material.dart';
import '../models/topic.dart';

class PhysicsData {
  static List<Topic> getAllTopics() {
    return [
      _forcesAndMotionTopic,
      _wavesTopic,
      _electricityTopic,
      _magnetismTopic,
      _spaceTopic,
      _energyTopic,
      _nuclearPhysicsTopic,
      _thermalPhysicsTopic,
    ];
  }

  // ==================== FORCES AND MOTION ====================
  static final Topic _forcesAndMotionTopic = Topic(
    id: 'forces_motion',
    title: 'Forces & Motion',
    description: 'Learn about speed, velocity, acceleration, and the forces that affect motion',
    icon: Icons.speed,
    color: const Color(0xFF4CAF50),
    lessons: [
      const Lesson(
        id: 'fm_distance_time',
        title: 'Distance-Time Graphs',
        content: '''Distance-time graphs show how far an object has travelled over time. They are powerful tools for understanding motion.

Reading a Distance-Time Graph:
The gradient (slope) of a distance-time graph represents speed. A steeper slope means faster movement.

Key Features:
• Horizontal line = stationary (not moving)
• Straight diagonal line = constant speed
• Curved line = changing speed (acceleration or deceleration)
• Steeper gradient = faster speed

Calculating Speed from the Graph:
Speed = Distance ÷ Time
or
Speed = Change in distance ÷ Change in time

For example, if an object travels 100m in 20 seconds:
Speed = 100m ÷ 20s = 5 m/s

The gradient can be calculated using:
Gradient = Rise ÷ Run = (y₂ - y₁) ÷ (x₂ - x₁)

This gives you the speed in metres per second (m/s).''',
        keyPoints: [
          'Gradient of distance-time graph = speed',
          'Horizontal line means the object is stationary',
          'Steeper slope means faster speed',
          'Curved line indicates acceleration or deceleration',
          'Speed = Distance ÷ Time',
        ],
        formulas: [
          'Speed (m/s) = Distance (m) ÷ Time (s)',
          'Gradient = Rise ÷ Run',
        ],
      ),
      const Lesson(
        id: 'fm_velocity_time',
        title: 'Velocity-Time Graphs',
        content: '''Velocity-time graphs show how an object's velocity changes over time. They provide more information than distance-time graphs.

Key Differences from Distance-Time Graphs:
• The gradient represents acceleration, not speed
• The area under the graph represents distance travelled

Reading a Velocity-Time Graph:
• Horizontal line = constant velocity (no acceleration)
• Positive gradient = acceleration (speeding up)
• Negative gradient = deceleration (slowing down)
• Line at zero = stationary

Calculating Acceleration:
Acceleration = Change in velocity ÷ Time
a = (v - u) ÷ t

Where:
• a = acceleration (m/s²)
• v = final velocity (m/s)
• u = initial velocity (m/s)
• t = time (s)

Calculating Distance:
The area under a velocity-time graph equals the distance travelled.
For a rectangular area: Distance = velocity × time
For a triangular area: Distance = ½ × base × height''',
        keyPoints: [
          'Gradient of velocity-time graph = acceleration',
          'Area under the graph = distance travelled',
          'Horizontal line means constant velocity',
          'Positive gradient = speeding up',
          'Negative gradient = slowing down',
        ],
        formulas: [
          'Acceleration (m/s²) = Change in velocity (m/s) ÷ Time (s)',
          'a = (v - u) ÷ t',
          'Distance = Area under graph',
        ],
      ),
      const Lesson(
        id: 'fm_acceleration',
        title: 'Acceleration',
        content: '''Acceleration is the rate of change of velocity. It tells us how quickly an object is speeding up or slowing down.

Understanding Acceleration:
Acceleration occurs when an object:
• Speeds up (positive acceleration)
• Slows down (negative acceleration/deceleration)
• Changes direction

The Acceleration Equation:
a = (v - u) ÷ t

Where:
• a = acceleration (m/s²)
• v = final velocity (m/s)
• u = initial velocity (m/s)
• t = time taken (s)

Example Calculation:
A car accelerates from 10 m/s to 30 m/s in 5 seconds.
a = (30 - 10) ÷ 5 = 20 ÷ 5 = 4 m/s²

Uniform Acceleration:
When acceleration is constant, we can use:
v² = u² + 2as

Where s = distance travelled

This equation is useful when time is not given.

Free Fall:
Objects falling under gravity accelerate at approximately 9.8 m/s² (often rounded to 10 m/s²).
This is called gravitational field strength (g).''',
        keyPoints: [
          'Acceleration is rate of change of velocity',
          'Measured in metres per second squared (m/s²)',
          'Positive acceleration = speeding up',
          'Negative acceleration = slowing down (deceleration)',
          'Free fall acceleration ≈ 9.8 m/s²',
        ],
        formulas: [
          'a = (v - u) ÷ t',
          'v² = u² + 2as',
          'g ≈ 9.8 m/s² (gravitational acceleration)',
        ],
      ),
      const Lesson(
        id: 'fm_momentum',
        title: 'Momentum',
        content: '''Momentum is a measure of how difficult it is to stop a moving object. It depends on both mass and velocity.

The Momentum Equation:
p = m × v

Where:
• p = momentum (kg m/s)
• m = mass (kg)
• v = velocity (m/s)

Conservation of Momentum:
In a closed system, the total momentum before a collision equals the total momentum after.

Total momentum before = Total momentum after
m₁u₁ + m₂u₂ = m₁v₁ + m₂v₂

Example:
A 1000 kg car travelling at 20 m/s:
Momentum = 1000 × 20 = 20,000 kg m/s

Types of Collisions:
1. Elastic collision: Objects bounce apart, kinetic energy is conserved
2. Inelastic collision: Objects may stick together, some kinetic energy is lost

Momentum is a Vector:
Momentum has both magnitude and direction. Objects moving in opposite directions have momenta with opposite signs.''',
        keyPoints: [
          'Momentum = mass × velocity',
          'Momentum is conserved in collisions',
          'Unit is kg m/s (kilogram metres per second)',
          'Momentum is a vector quantity (has direction)',
          'Larger mass or velocity = more momentum',
        ],
        formulas: [
          'p = m × v',
          'Total momentum before = Total momentum after',
          'm₁u₁ + m₂u₂ = m₁v₁ + m₂v₂',
        ],
      ),
      const Lesson(
        id: 'fm_braking',
        title: 'Forces & Braking',
        content: '''Understanding stopping distances is crucial for road safety. The total stopping distance consists of two parts.

Stopping Distance = Thinking Distance + Braking Distance

Thinking Distance:
The distance travelled during the driver's reaction time (before brakes are applied).

Factors affecting thinking distance:
• Speed (faster = longer thinking distance)
• Tiredness
• Distractions
• Alcohol or drugs
• Age

Braking Distance:
The distance travelled while the brakes are applied until the vehicle stops.

Factors affecting braking distance:
• Speed (faster = much longer braking distance)
• Road conditions (wet, icy = longer)
• Tyre condition
• Brake condition
• Mass of vehicle

The Relationship with Speed:
• Thinking distance is proportional to speed
• Braking distance is proportional to speed squared

This means doubling your speed:
• Doubles your thinking distance
• Quadruples your braking distance!

Braking Force and Work Done:
When brakes are applied, friction converts kinetic energy to heat.
Work done by brakes = Kinetic energy of vehicle
F × d = ½ × m × v²''',
        keyPoints: [
          'Stopping distance = Thinking distance + Braking distance',
          'Thinking distance proportional to speed',
          'Braking distance proportional to speed squared',
          'Wet/icy roads increase braking distance',
          'Brakes convert kinetic energy to heat',
        ],
        formulas: [
          'Stopping distance = Thinking distance + Braking distance',
          'Kinetic energy = ½ × m × v²',
          'Work done = Force × distance',
        ],
      ),
    ],
    quizzes: [
      Quiz(
        id: 'fm_quiz_1',
        title: 'Forces & Motion Quiz',
        questions: [
          const Question(
            id: 'fm_q1',
            question: 'What does the gradient of a distance-time graph represent?',
            options: ['Acceleration', 'Speed', 'Distance', 'Time'],
            correctIndex: 1,
            explanation: 'The gradient (slope) of a distance-time graph represents speed. A steeper gradient means a faster speed.',
          ),
          const Question(
            id: 'fm_q2',
            question: 'A car travels 150m in 30 seconds. What is its speed?',
            options: ['4500 m/s', '5 m/s', '180 m/s', '0.2 m/s'],
            correctIndex: 1,
            explanation: 'Speed = Distance ÷ Time = 150m ÷ 30s = 5 m/s',
            formula: 'Speed = Distance ÷ Time',
          ),
          const Question(
            id: 'fm_q3',
            question: 'What does a horizontal line on a velocity-time graph indicate?',
            options: ['The object is stationary', 'The object has constant velocity', 'The object is accelerating', 'The object is decelerating'],
            correctIndex: 1,
            explanation: 'A horizontal line on a velocity-time graph means the velocity is not changing - the object is moving at constant velocity (no acceleration).',
          ),
          const Question(
            id: 'fm_q4',
            question: 'A car accelerates from rest to 25 m/s in 5 seconds. What is its acceleration?',
            options: ['125 m/s²', '5 m/s²', '20 m/s²', '30 m/s²'],
            correctIndex: 1,
            explanation: 'Acceleration = (v - u) ÷ t = (25 - 0) ÷ 5 = 5 m/s²',
            formula: 'a = (v - u) ÷ t',
          ),
          const Question(
            id: 'fm_q5',
            question: 'What is the momentum of a 1500 kg car travelling at 20 m/s?',
            options: ['75 kg m/s', '1520 kg m/s', '30000 kg m/s', '750 kg m/s'],
            correctIndex: 2,
            explanation: 'Momentum = mass × velocity = 1500 kg × 20 m/s = 30,000 kg m/s',
            formula: 'p = m × v',
          ),
          const Question(
            id: 'fm_q6',
            question: 'If you double your speed, what happens to your braking distance?',
            options: ['It doubles', 'It triples', 'It quadruples', 'It stays the same'],
            correctIndex: 2,
            explanation: 'Braking distance is proportional to speed squared. So if speed doubles, braking distance increases by 2² = 4 times (quadruples).',
          ),
          const Question(
            id: 'fm_q7',
            question: 'What is the area under a velocity-time graph equal to?',
            options: ['Speed', 'Acceleration', 'Distance travelled', 'Force'],
            correctIndex: 2,
            explanation: 'The area under a velocity-time graph represents the distance travelled. This is because distance = velocity × time.',
          ),
          const Question(
            id: 'fm_q8',
            question: 'What is the approximate acceleration due to gravity on Earth?',
            options: ['5 m/s²', '9.8 m/s²', '15 m/s²', '100 m/s²'],
            correctIndex: 1,
            explanation: 'The acceleration due to gravity on Earth is approximately 9.8 m/s² (often rounded to 10 m/s² for calculations).',
          ),
          const Question(
            id: 'fm_q9',
            question: 'In a collision, what is conserved (in a closed system)?',
            options: ['Speed', 'Velocity', 'Momentum', 'Kinetic Energy'],
            correctIndex: 2,
            explanation: 'In a closed system, total momentum is always conserved. This is the law of conservation of momentum.',
          ),
          const Question(
            id: 'fm_q10',
            question: 'Which factor does NOT affect thinking distance?',
            options: ['Driver tiredness', 'Road surface conditions', 'Speed', 'Distractions'],
            correctIndex: 1,
            explanation: 'Road surface conditions affect braking distance, not thinking distance. Thinking distance depends on the driver\'s reaction time, which is affected by tiredness, distractions, speed, alcohol, and drugs.',
          ),
        ],
      ),
    ],
    simulations: [
      const PhysicsSimulation(
        id: 'fm_sim_motion',
        title: 'Motion Graphs Simulator',
        description: 'Create and analyze distance-time and velocity-time graphs interactively',
        type: SimulationType.forces,
      ),
      const PhysicsSimulation(
        id: 'fm_sim_momentum',
        title: 'Collision Simulator',
        description: 'Explore elastic and inelastic collisions and conservation of momentum',
        type: SimulationType.momentum,
      ),
      const PhysicsSimulation(
        id: 'fm_sim_springs',
        title: 'Springs & Hooke\'s Law',
        description: 'Investigate how springs extend under different forces and explore elastic behavior',
        type: SimulationType.springs,
      ),
      const PhysicsSimulation(
        id: 'fm_sim_moments',
        title: 'Moments & Levers',
        description: 'Balance forces on levers and understand the principle of moments',
        type: SimulationType.moments,
      ),
      const PhysicsSimulation(
        id: 'fm_sim_freefall',
        title: 'Free Fall',
        description: 'Explore objects falling under gravity in a vacuum versus with air resistance',
        type: SimulationType.freeFall,
      ),
      const PhysicsSimulation(
        id: 'fm_sim_friction',
        title: 'Friction Forces',
        description: 'Investigate static and kinetic friction on different surfaces',
        type: SimulationType.friction,
      ),
      const PhysicsSimulation(
        id: 'fm_sim_centripetal',
        title: 'Circular Motion',
        description: 'Explore centripetal force and acceleration in circular motion',
        type: SimulationType.centripetal,
      ),
      const PhysicsSimulation(
        id: 'fm_sim_inclined',
        title: 'Inclined Plane',
        description: 'Analyze forces on objects sliding down slopes',
        type: SimulationType.inclinedPlane,
      ),
      const PhysicsSimulation(
        id: 'fm_sim_pulley',
        title: 'Pulley Systems',
        description: 'Learn about mechanical advantage using pulley systems',
        type: SimulationType.pulleySystem,
      ),
      const PhysicsSimulation(
        id: 'fm_sim_cradle',
        title: 'Newton\'s Cradle',
        description: 'Observe conservation of momentum and energy in elastic collisions',
        type: SimulationType.newtonsCradle,
      ),
      const PhysicsSimulation(
        id: 'fm_sim_projectile',
        title: 'Projectile Motion',
        description: 'Launch projectiles and explore trajectory, range, and maximum height',
        type: SimulationType.projectileMotion,
      ),
      const PhysicsSimulation(
        id: 'fm_sim_terminal',
        title: 'Terminal Velocity',
        description: 'Observe objects reaching terminal velocity with air resistance',
        type: SimulationType.terminalVelocity,
      ),
      const PhysicsSimulation(
        id: 'fm_sim_pendulum',
        title: 'Pendulum',
        description: 'Investigate simple harmonic motion and factors affecting period',
        type: SimulationType.pendulum,
      ),
    ],
  );

  // ==================== WAVES ====================
  static final Topic _wavesTopic = Topic(
    id: 'waves',
    title: 'Waves',
    description: 'Explore sound waves, electromagnetic spectrum, reflection, and refraction',
    icon: Icons.waves,
    color: const Color(0xFFE91E63),
    lessons: [
      const Lesson(
        id: 'w_properties',
        title: 'Wave Properties',
        content: '''Waves transfer energy from one place to another without transferring matter. Understanding wave properties is fundamental to physics.

Types of Waves:
1. Transverse Waves: Oscillations perpendicular to direction of travel
   Examples: Light, water waves, electromagnetic waves

2. Longitudinal Waves: Oscillations parallel to direction of travel
   Examples: Sound waves, seismic P-waves

Key Wave Properties:

Wavelength (λ): Distance between two consecutive points in phase (e.g., peak to peak)
Unit: metres (m)

Frequency (f): Number of complete waves passing a point per second
Unit: Hertz (Hz)

Amplitude: Maximum displacement from the equilibrium position
Related to energy - larger amplitude = more energy

Period (T): Time for one complete wave cycle
T = 1/f

The Wave Equation:
Wave speed = frequency × wavelength
v = f × λ

This equation applies to all types of waves.

Example:
A wave has frequency 50 Hz and wavelength 2m.
Speed = 50 × 2 = 100 m/s''',
        keyPoints: [
          'Waves transfer energy without transferring matter',
          'Transverse waves: oscillations perpendicular to travel',
          'Longitudinal waves: oscillations parallel to travel',
          'Wave speed = frequency × wavelength',
          'Amplitude relates to energy carried',
        ],
        formulas: [
          'v = f × λ (wave equation)',
          'T = 1/f (period)',
        ],
      ),
      const Lesson(
        id: 'w_sound',
        title: 'Sound Waves',
        content: '''Sound is a longitudinal wave that requires a medium to travel through. It cannot travel through a vacuum.

How Sound Travels:
Sound waves are created by vibrating objects. These vibrations cause particles in the medium to vibrate, creating compressions and rarefactions.

• Compressions: Regions where particles are close together (high pressure)
• Rarefactions: Regions where particles are spread apart (low pressure)

Speed of Sound:
Sound travels at different speeds in different media:
• Air (20°C): ~340 m/s
• Water: ~1500 m/s
• Steel: ~5000 m/s

Sound travels faster in solids because particles are closer together.

Frequency and Pitch:
• Higher frequency = higher pitch
• Human hearing range: 20 Hz to 20,000 Hz
• Below 20 Hz = infrasound
• Above 20,000 Hz = ultrasound

Amplitude and Loudness:
• Greater amplitude = louder sound
• Loudness measured in decibels (dB)

Echoes:
Sound reflects off surfaces. An echo is a reflected sound wave. Used in sonar and ultrasound imaging.''',
        keyPoints: [
          'Sound is a longitudinal wave',
          'Sound needs a medium to travel (cannot travel in vacuum)',
          'Higher frequency = higher pitch',
          'Greater amplitude = louder sound',
          'Sound travels fastest in solids',
        ],
        formulas: [
          'v = f × λ',
          'Speed of sound in air ≈ 340 m/s',
        ],
      ),
      const Lesson(
        id: 'w_em_spectrum',
        title: 'Electromagnetic Waves',
        content: '''The electromagnetic (EM) spectrum is a continuous range of waves that all travel at the speed of light in a vacuum.

All EM Waves:
• Are transverse waves
• Travel at 3 × 10⁸ m/s in a vacuum (speed of light)
• Can travel through a vacuum (don't need a medium)
• Transfer energy

The EM Spectrum (lowest to highest frequency):

1. Radio Waves
   Uses: TV, radio, communications
   Wavelength: > 1m

2. Microwaves
   Uses: Cooking, satellite communications, mobile phones
   Wavelength: 1mm - 1m

3. Infrared
   Uses: Remote controls, thermal imaging, heating
   Wavelength: 700nm - 1mm

4. Visible Light
   Uses: Seeing, photography
   Wavelength: 400nm - 700nm (violet to red)

5. Ultraviolet
   Uses: Sterilization, fluorescent lights
   Dangers: Skin cancer, eye damage
   Wavelength: 10nm - 400nm

6. X-rays
   Uses: Medical imaging, airport security
   Dangers: Cell damage, cancer
   Wavelength: 0.01nm - 10nm

7. Gamma Rays
   Uses: Cancer treatment, sterilizing equipment
   Dangers: Cell damage, cancer
   Wavelength: < 0.01nm

Higher frequency = higher energy = more dangerous''',
        keyPoints: [
          'All EM waves travel at speed of light (3×10⁸ m/s)',
          'Order: Radio, Microwave, Infrared, Visible, UV, X-ray, Gamma',
          'Higher frequency = shorter wavelength = more energy',
          'EM waves can travel through vacuum',
          'Different waves have different uses and dangers',
        ],
        formulas: [
          'c = f × λ (where c = 3 × 10⁸ m/s)',
        ],
      ),
      const Lesson(
        id: 'w_reflection_refraction',
        title: 'Reflection & Refraction',
        content: '''When waves meet a boundary between materials, they can be reflected, refracted, or absorbed.

Reflection:
When a wave bounces off a surface. The law of reflection states:

Angle of incidence = Angle of reflection

Both angles are measured from the normal (a line perpendicular to the surface).

Types of Reflection:
• Specular reflection: From smooth surfaces (mirrors)
• Diffuse reflection: From rough surfaces (paper, walls)

Refraction:
When a wave changes speed as it passes from one medium to another, it changes direction (unless it hits the boundary at 90°).

When light enters a denser medium (e.g., air to glass):
• Light slows down
• Light bends towards the normal

When light enters a less dense medium (e.g., glass to air):
• Light speeds up
• Light bends away from the normal

Refractive Index:
n = sin i / sin r = c / v

Where n is the refractive index, and c is speed of light in vacuum.

Total Internal Reflection:
When light travels from a denser to less dense medium at an angle greater than the critical angle, all light is reflected internally. Used in optical fibers.''',
        keyPoints: [
          'Angle of incidence = Angle of reflection',
          'Refraction occurs when waves change speed at a boundary',
          'Light bends towards normal when entering denser medium',
          'Light bends away from normal when entering less dense medium',
          'Total internal reflection occurs above the critical angle',
        ],
        formulas: [
          'Angle of incidence = Angle of reflection',
          'n = sin i / sin r',
          'n = c / v',
        ],
      ),
      const Lesson(
        id: 'w_lenses',
        title: 'Lenses',
        content: '''Lenses use refraction to focus or spread light. They are used in glasses, cameras, microscopes, and telescopes.

Types of Lenses:

1. Convex (Converging) Lens:
• Thicker in the middle
• Brings parallel light rays to a focus
• Creates real, inverted images (when object beyond focal point)
• Creates virtual, upright, magnified images (when object within focal point)
• Used in: magnifying glasses, cameras, projectors, the eye

2. Concave (Diverging) Lens:
• Thinner in the middle
• Spreads parallel light rays apart
• Always creates virtual, upright, diminished images
• Used in: treating short-sightedness, peepholes

Key Terms:
• Principal axis: Horizontal line through centre of lens
• Focal point (F): Where parallel rays converge (convex) or appear to diverge from (concave)
• Focal length (f): Distance from lens to focal point

Ray Diagrams:
For convex lenses, draw rays:
1. Parallel to axis → through focal point
2. Through centre → continues straight
3. Through focal point → parallel to axis

Magnification:
Magnification = Image height / Object height
Magnification = Image distance / Object distance''',
        keyPoints: [
          'Convex lenses converge (focus) light',
          'Concave lenses diverge (spread) light',
          'Focal length is distance from lens to focal point',
          'Real images can be projected onto a screen',
          'Virtual images cannot be projected',
        ],
        formulas: [
          'Magnification = Image height / Object height',
          '1/f = 1/u + 1/v (lens equation)',
        ],
      ),
    ],
    quizzes: [
      Quiz(
        id: 'w_quiz_1',
        title: 'Waves Quiz',
        questions: [
          const Question(
            id: 'w_q1',
            question: 'Which type of wave is sound?',
            options: ['Transverse', 'Longitudinal', 'Electromagnetic', 'Surface'],
            correctIndex: 1,
            explanation: 'Sound is a longitudinal wave where particles vibrate parallel to the direction of wave travel, creating compressions and rarefactions.',
          ),
          const Question(
            id: 'w_q2',
            question: 'What is the speed of light in a vacuum?',
            options: ['340 m/s', '1500 m/s', '3 × 10⁶ m/s', '3 × 10⁸ m/s'],
            correctIndex: 3,
            explanation: 'The speed of light in a vacuum is 3 × 10⁸ m/s (300,000,000 metres per second). This is constant for all electromagnetic waves.',
          ),
          const Question(
            id: 'w_q3',
            question: 'A wave has frequency 200 Hz and wavelength 1.5m. What is its speed?',
            options: ['133 m/s', '300 m/s', '201.5 m/s', '198.5 m/s'],
            correctIndex: 1,
            explanation: 'Using the wave equation: v = f × λ = 200 × 1.5 = 300 m/s',
            formula: 'v = f × λ',
          ),
          const Question(
            id: 'w_q4',
            question: 'Which EM wave has the highest frequency?',
            options: ['Radio waves', 'Visible light', 'X-rays', 'Gamma rays'],
            correctIndex: 3,
            explanation: 'Gamma rays have the highest frequency (and shortest wavelength) in the EM spectrum, which is why they carry the most energy.',
          ),
          const Question(
            id: 'w_q5',
            question: 'When light passes from air into glass, what happens?',
            options: [
              'It speeds up and bends away from normal',
              'It slows down and bends towards normal',
              'It speeds up and bends towards normal',
              'It slows down and bends away from normal'
            ],
            correctIndex: 1,
            explanation: 'Glass is denser than air, so light slows down. When light slows down entering a denser medium, it bends towards the normal.',
          ),
          const Question(
            id: 'w_q6',
            question: 'What type of lens is used in a magnifying glass?',
            options: ['Concave', 'Convex', 'Plane', 'Cylindrical'],
            correctIndex: 1,
            explanation: 'A magnifying glass uses a convex (converging) lens. When an object is placed within the focal length, it creates a virtual, upright, magnified image.',
          ),
          const Question(
            id: 'w_q7',
            question: 'What is the human hearing range?',
            options: ['1 Hz to 100 Hz', '20 Hz to 20,000 Hz', '100 Hz to 100,000 Hz', '200 Hz to 2000 Hz'],
            correctIndex: 1,
            explanation: 'Humans can typically hear sounds with frequencies between 20 Hz and 20,000 Hz (20 kHz). Below this is infrasound, above is ultrasound.',
          ),
          const Question(
            id: 'w_q8',
            question: 'What determines the loudness of a sound?',
            options: ['Frequency', 'Wavelength', 'Amplitude', 'Speed'],
            correctIndex: 2,
            explanation: 'The amplitude of a sound wave determines its loudness. Greater amplitude means louder sound because more energy is transferred.',
          ),
          const Question(
            id: 'w_q9',
            question: 'The law of reflection states that:',
            options: [
              'Angle of incidence > Angle of reflection',
              'Angle of incidence = Angle of reflection',
              'Angle of incidence < Angle of reflection',
              'Angles are always 45°'
            ],
            correctIndex: 1,
            explanation: 'The law of reflection states that the angle of incidence equals the angle of reflection. Both angles are measured from the normal.',
          ),
          const Question(
            id: 'w_q10',
            question: 'Which EM wave is used in thermal imaging?',
            options: ['Ultraviolet', 'Infrared', 'Microwaves', 'X-rays'],
            correctIndex: 1,
            explanation: 'Infrared radiation is emitted by all warm objects. Thermal imaging cameras detect this infrared to create images showing heat patterns.',
          ),
        ],
      ),
    ],
    simulations: [
      const PhysicsSimulation(
        id: 'w_sim_waves',
        title: 'Wave Properties Simulator',
        description: 'Explore wavelength, frequency, and amplitude with interactive waves',
        type: SimulationType.waves,
      ),
      const PhysicsSimulation(
        id: 'w_sim_light',
        title: 'Light & Lenses Simulator',
        description: 'Experiment with reflection, refraction, and lens ray diagrams',
        type: SimulationType.light,
      ),
      const PhysicsSimulation(
        id: 'w_sim_diffraction',
        title: 'Diffraction',
        description: 'Explore single slit, double slit, and diffraction grating patterns',
        type: SimulationType.diffraction,
      ),
      const PhysicsSimulation(
        id: 'w_sim_standing',
        title: 'Standing Waves',
        description: 'Visualize nodes, antinodes, and harmonics in standing wave patterns',
        type: SimulationType.standingWaves,
      ),
      const PhysicsSimulation(
        id: 'w_sim_tir',
        title: 'Total Internal Reflection',
        description: 'Investigate critical angle and total internal reflection with different materials',
        type: SimulationType.totalInternalReflection,
      ),
      const PhysicsSimulation(
        id: 'w_sim_sound',
        title: 'Sound Waves',
        description: 'Explore sound wave properties, frequency, and amplitude',
        type: SimulationType.soundWaves,
      ),
      const PhysicsSimulation(
        id: 'w_sim_doppler',
        title: 'Doppler Effect',
        description: 'Observe how motion affects wave frequency and pitch',
        type: SimulationType.dopplerEffect,
      ),
      const PhysicsSimulation(
        id: 'w_sim_refraction',
        title: 'Refraction',
        description: 'Explore light bending as it passes between different media',
        type: SimulationType.refraction,
      ),
      const PhysicsSimulation(
        id: 'w_sim_em_spectrum',
        title: 'Electromagnetic Spectrum',
        description: 'Explore all types of electromagnetic radiation from radio to gamma',
        type: SimulationType.electromagneticSpectrum,
      ),
      const PhysicsSimulation(
        id: 'w_sim_interference',
        title: 'Wave Interference',
        description: 'Observe constructive and destructive interference patterns',
        type: SimulationType.waveInterference,
      ),
      const PhysicsSimulation(
        id: 'w_sim_lenses',
        title: 'Lenses',
        description: 'Explore convex and concave lenses with ray diagrams',
        type: SimulationType.lenses,
      ),
      const PhysicsSimulation(
        id: 'w_sim_mirrors',
        title: 'Mirrors',
        description: 'Investigate reflection in plane, concave, and convex mirrors',
        type: SimulationType.mirrors,
      ),
    ],
  );

  // ==================== ELECTRICITY ====================
  static final Topic _electricityTopic = Topic(
    id: 'electricity',
    title: 'Electricity',
    description: 'Understand circuits, current, voltage, resistance, and electrical power',
    icon: Icons.bolt,
    color: const Color(0xFFFF9800),
    lessons: [
      const Lesson(
        id: 'e_current_voltage',
        title: 'Current & Voltage',
        content: '''Electricity involves the flow of charge through a conductor. Understanding current and voltage is essential.

Electric Current (I):
Current is the rate of flow of electric charge.

I = Q / t

Where:
• I = current (Amperes, A)
• Q = charge (Coulombs, C)
• t = time (seconds, s)

Current flows from positive to negative (conventional current), though electrons actually flow from negative to positive.

Potential Difference (Voltage, V):
Voltage is the energy transferred per unit charge. It's like "electrical pressure" that pushes current around a circuit.

V = E / Q   or   V = W / Q

Where:
• V = potential difference (Volts, V)
• E or W = energy transferred (Joules, J)
• Q = charge (Coulombs, C)

Key Points:
• Voltage is measured across components (in parallel)
• Current is measured through components (in series)
• A voltmeter measures voltage (connected in parallel)
• An ammeter measures current (connected in series)

Power Supply:
The power supply (battery or mains) provides the energy. Voltage tells us how much energy each coulomb of charge carries.''',
        keyPoints: [
          'Current is rate of flow of charge (I = Q/t)',
          'Voltage is energy per unit charge (V = E/Q)',
          'Current measured in Amperes (A)',
          'Voltage measured in Volts (V)',
          'Ammeter in series, Voltmeter in parallel',
        ],
        formulas: [
          'I = Q / t',
          'V = E / Q',
        ],
      ),
      const Lesson(
        id: 'e_resistance',
        title: 'Resistance & Ohm\'s Law',
        content: '''Resistance is the opposition to the flow of current in a circuit. It determines how much current flows for a given voltage.

Ohm's Law:
V = I × R

Where:
• V = potential difference (Volts, V)
• I = current (Amperes, A)
• R = resistance (Ohms, Ω)

Rearranged:
• R = V / I (to find resistance)
• I = V / R (to find current)

Ohmic Conductors:
For an ohmic conductor (like a resistor at constant temperature):
• Current is directly proportional to voltage
• Graph of V against I is a straight line through origin
• Resistance stays constant

Non-Ohmic Components:
• Filament lamp: Resistance increases as it heats up
• Diode: Only allows current in one direction
• LDR: Resistance decreases in brighter light
• Thermistor: Resistance decreases when hotter

Factors Affecting Resistance:
• Length: Longer wire = more resistance
• Cross-sectional area: Thinner wire = more resistance
• Material: Some materials conduct better than others
• Temperature: Higher temperature usually = more resistance''',
        keyPoints: [
          'Resistance opposes current flow',
          'V = I × R (Ohm\'s Law)',
          'Resistance measured in Ohms (Ω)',
          'Ohmic conductors have constant resistance',
          'Longer/thinner wires have more resistance',
        ],
        formulas: [
          'V = I × R',
          'R = V / I',
          'I = V / R',
        ],
      ),
      const Lesson(
        id: 'e_circuits',
        title: 'Series & Parallel Circuits',
        content: '''Components can be connected in series (one after another) or parallel (on separate branches).

Series Circuits:
• Same current flows through all components
• Total voltage shared between components
• Total resistance = R₁ + R₂ + R₃ ...
• If one component breaks, circuit is broken

Rules for Series:
• I_total = I₁ = I₂ = I₃
• V_total = V₁ + V₂ + V₃
• R_total = R₁ + R₂ + R₃

Parallel Circuits:
• Voltage same across all branches
• Current splits between branches
• Total resistance less than smallest individual resistance
• If one branch breaks, others still work

Rules for Parallel:
• V_total = V₁ = V₂ = V₃
• I_total = I₁ + I₂ + I₃
• 1/R_total = 1/R₁ + 1/R₂ + 1/R₃

Example Calculation:
Two 6Ω resistors in series:
R_total = 6 + 6 = 12Ω

Two 6Ω resistors in parallel:
1/R = 1/6 + 1/6 = 2/6 = 1/3
R_total = 3Ω''',
        keyPoints: [
          'Series: same current, voltage divides',
          'Parallel: same voltage, current divides',
          'Series resistance adds up',
          'Parallel resistance formula: 1/R = 1/R₁ + 1/R₂',
          'Parallel circuits are more reliable',
        ],
        formulas: [
          'Series: R_total = R₁ + R₂ + R₃',
          'Parallel: 1/R_total = 1/R₁ + 1/R₂ + 1/R₃',
        ],
      ),
      const Lesson(
        id: 'e_power',
        title: 'Electrical Power & Energy',
        content: '''Electrical power is the rate at which electrical energy is transferred.

Power Equations:
P = E / t (power = energy / time)
P = I × V (power = current × voltage)
P = I² × R (power = current² × resistance)
P = V² / R (power = voltage² / resistance)

Where:
• P = power (Watts, W)
• E = energy (Joules, J)
• t = time (seconds, s)
• I = current (A)
• V = voltage (V)
• R = resistance (Ω)

Energy Transferred:
E = P × t
E = I × V × t
E = Q × V (since Q = I × t)

Units:
• Power: Watts (W) or Kilowatts (kW)
• Energy: Joules (J) or Kilowatt-hours (kWh)
• 1 kWh = 3,600,000 J

Calculating Electricity Costs:
Cost = Energy used (kWh) × Price per kWh

Example:
A 2000W heater running for 3 hours:
Energy = 2 kW × 3 h = 6 kWh
If price is 15p per kWh:
Cost = 6 × 15 = 90p''',
        keyPoints: [
          'Power is rate of energy transfer',
          'P = I × V = I²R = V²/R',
          'Energy = Power × Time',
          '1 kWh = 1000W for 1 hour',
          'Cost = kWh × price per kWh',
        ],
        formulas: [
          'P = I × V',
          'P = I² × R',
          'P = V² / R',
          'E = P × t',
        ],
      ),
      const Lesson(
        id: 'e_electrolysis',
        title: 'Electrolysis & Electrochemistry',
        content: '''What is Electrolysis?
Electrolysis is the process of using direct current (DC) electricity to decompose (break down) an ionic compound into its elements. It requires the compound to be either molten or dissolved in solution so that the ions are free to move.

Electrodes:
• Electrode – A conductor (usually metal or graphite) placed in the electrolyte and connected to the power supply.
• Cathode – The negative electrode (connected to the negative terminal of the battery). This is where positive ions gain electrons.
• Anode – The positive electrode (connected to the positive terminal). This is where negative ions lose electrons.

Ions:
• Cation – A positive ion (e.g. Cu²⁺, H⁺, Na⁺). Cations are attracted to the cathode (negative electrode).
• Anion – A negative ion (e.g. Cl⁻, OH⁻, SO₄²⁻). Anions are attracted to the anode (positive electrode).
Memory aid: CATions go to the CAThode. ANions go to the ANode.

Electrolytes vs Non-electrolytes:
• Electrolyte – A substance that conducts electricity when molten or dissolved because it contains free-moving ions. Examples: molten NaCl, CuSO₄ solution, dilute H₂SO₄.
• Non-electrolyte – A substance that does NOT conduct electricity because it has no free ions. Examples: pure water, sugar solution, oil.

Conductors:
A conductor is a material through which electric charge can flow freely. Metals are excellent conductors because they have a "sea" of free (delocalised) electrons. Graphite also conducts due to free electrons between its layers.

The Voltmeter:
A voltmeter measures the potential difference (voltage) between two points in a circuit.
• It must be connected in PARALLEL across the component being measured.
• It has very high internal resistance so that it draws negligible current and does not affect the circuit.
• The unit is Volts (V).

Electrolysis of Water:
Pure water is a very poor conductor. Adding dilute sulfuric acid (H₂SO₄) provides free ions.
• At the cathode: 2H⁺ + 2e⁻ → H₂ (hydrogen gas – twice the volume)
• At the anode: 4OH⁻ → 2H₂O + O₂ + 4e⁻ (oxygen gas)
• The ratio of hydrogen to oxygen is 2 : 1, matching the formula H₂O.

How Electrolysis Works Step-by-Step:
1. The electrolyte contains free positive ions (cations) and negative ions (anions).
2. When DC is applied, cations are attracted toward the cathode (negative electrode).
3. Anions are attracted toward the anode (positive electrode).
4. At the cathode: cations gain electrons (REDUCTION) — metals or hydrogen are deposited.
5. At the anode: anions lose electrons (OXIDATION) — non-metals are released.''',
        keyPoints: [
          'Electrolysis decomposes ionic compounds using DC electricity',
          'Cathode is the negative electrode; Anode is the positive electrode',
          'Cations (positive ions) move to cathode; Anions (negative ions) move to anode',
          'Electrolytes conduct electricity (free ions); Non-electrolytes do not',
          'Conductors allow electric charge to flow (metals have free electrons)',
          'A voltmeter is connected in parallel and has high resistance',
          'Electrolysis of water produces H₂ at cathode and O₂ at anode (2:1 ratio)',
        ],
        formulas: [
          'Cathode (reduction): Mⁿ⁺ + ne⁻ → M',
          'Anode (oxidation): X⁻ → X + e⁻',
          'Water cathode: 2H⁺ + 2e⁻ → H₂',
          'Water anode: 4OH⁻ → 2H₂O + O₂ + 4e⁻',
        ],
      ),
      const Lesson(
        id: 'e_electroplating',
        title: 'Electroplating & Electro-Refining',
        content: '''Electroplating:
Electroplating uses electrolysis to coat an object with a thin layer of metal. It is one of the most important industrial applications of electrolysis.

Electroplating Setup:
• Cathode (−) : The object to be plated (e.g. a spoon, car bumper, or piece of jewellery).
• Anode (+) : A piece of the plating metal (e.g. pure copper, silver, or gold).
• Electrolyte: A solution containing ions of the plating metal (e.g. copper sulfate solution for copper plating).

How Electroplating Works:
1. Metal atoms at the anode lose electrons and dissolve into the electrolyte as metal ions (oxidation).
   Example: Cu → Cu²⁺ + 2e⁻
2. The metal ions travel through the electrolyte toward the cathode.
3. At the cathode, the metal ions gain electrons and are deposited as solid metal atoms (reduction).
   Example: Cu²⁺ + 2e⁻ → Cu
4. Over time, a thin, even metallic coating forms on the object.
5. The anode gradually gets smaller as metal dissolves; the cathode gains a metal layer.

Why Electroplate?
• Appearance – Gold or silver plating makes jewellery attractive.
• Corrosion protection – Chrome plating on car parts prevents rust.
• Hardness – Nickel plating makes tools more durable.
• Electrical conductivity – Silver plating on electrical contacts.
• Cost saving – A thin layer of expensive metal over a cheap base metal.

Electro-Refining:
Electro-refining uses electrolysis to purify metals, especially copper for electrical wiring where high purity is essential.

Electro-Refining Setup:
• Anode: Impure copper (contains impurities like zinc, iron, silver, gold).
• Cathode: A thin strip of pure copper.
• Electrolyte: Copper sulfate solution (CuSO₄).

Process:
1. Copper atoms at the impure anode dissolve as Cu²⁺ ions.
2. Cu²⁺ ions travel to the pure copper cathode and deposit as pure copper.
3. Impurities that are less reactive than copper (e.g. gold, silver) do not dissolve — they fall to the bottom of the cell as "anode sludge."
4. Impurities that are more reactive than copper (e.g. zinc, iron) dissolve but do not deposit at the cathode — they remain in solution.
5. The result is 99.99% pure copper at the cathode.''',
        keyPoints: [
          'In electroplating, the object to be plated is always the cathode',
          'The anode is made of the plating metal',
          'The electrolyte contains ions of the plating metal',
          'Applications: jewellery, corrosion protection, hardness, conductivity',
          'Electro-refining purifies metals (especially copper)',
          'Impurities fall as anode sludge or remain in solution',
          'Electro-refined copper is 99.99% pure',
        ],
        formulas: [
          'Anode: Cu → Cu²⁺ + 2e⁻ (dissolves)',
          'Cathode: Cu²⁺ + 2e⁻ → Cu (deposits)',
        ],
      ),
    ],
    quizzes: [
      Quiz(
        id: 'e_quiz_1',
        title: 'Electricity Quiz',
        questions: [
          const Question(
            id: 'e_q1',
            question: 'What is the unit of electrical resistance?',
            options: ['Ampere', 'Volt', 'Ohm', 'Watt'],
            correctIndex: 2,
            explanation: 'Electrical resistance is measured in Ohms (Ω), named after Georg Ohm who discovered the relationship V = IR.',
          ),
          const Question(
            id: 'e_q2',
            question: 'A current of 3A flows through a 4Ω resistor. What is the voltage?',
            options: ['0.75 V', '1.33 V', '7 V', '12 V'],
            correctIndex: 3,
            explanation: 'Using Ohm\'s Law: V = I × R = 3 × 4 = 12 V',
            formula: 'V = I × R',
          ),
          const Question(
            id: 'e_q3',
            question: 'In a series circuit, what happens to the current?',
            options: [
              'It is different in each component',
              'It is the same throughout',
              'It doubles at each component',
              'It halves at each component'
            ],
            correctIndex: 1,
            explanation: 'In a series circuit, the same current flows through all components because there is only one path for the current to flow.',
          ),
          const Question(
            id: 'e_q4',
            question: 'Two 10Ω resistors are connected in parallel. What is the total resistance?',
            options: ['20 Ω', '10 Ω', '5 Ω', '0.2 Ω'],
            correctIndex: 2,
            explanation: '1/R = 1/10 + 1/10 = 2/10 = 1/5, so R = 5Ω. In parallel, total resistance is always less than the smallest individual resistance.',
            formula: '1/R_total = 1/R₁ + 1/R₂',
          ),
          const Question(
            id: 'e_q5',
            question: 'What power is dissipated by a device with 2A current and 12V supply?',
            options: ['6 W', '14 W', '24 W', '48 W'],
            correctIndex: 2,
            explanation: 'Power = Current × Voltage = 2 × 12 = 24 W',
            formula: 'P = I × V',
          ),
          const Question(
            id: 'e_q6',
            question: 'How is an ammeter connected in a circuit?',
            options: ['In series', 'In parallel', 'Across the battery', 'It doesn\'t matter'],
            correctIndex: 0,
            explanation: 'An ammeter must be connected in series because it needs to measure the current flowing through the circuit.',
          ),
          const Question(
            id: 'e_q7',
            question: 'What happens to the resistance of an LDR when light intensity increases?',
            options: ['Increases', 'Decreases', 'Stays the same', 'Becomes zero'],
            correctIndex: 1,
            explanation: 'LDR (Light Dependent Resistor) has high resistance in darkness and low resistance in bright light. More light = more charge carriers = less resistance.',
          ),
          const Question(
            id: 'e_q8',
            question: 'A 3kW heater runs for 2 hours. How much energy in kWh?',
            options: ['1.5 kWh', '5 kWh', '6 kWh', '1 kWh'],
            correctIndex: 2,
            explanation: 'Energy = Power × Time = 3 kW × 2 h = 6 kWh',
            formula: 'E = P × t',
          ),
          const Question(
            id: 'e_q9',
            question: 'What is current?',
            options: [
              'Energy transferred per unit charge',
              'Rate of flow of charge',
              'Opposition to flow of charge',
              'Energy transferred per second'
            ],
            correctIndex: 1,
            explanation: 'Current is defined as the rate of flow of electric charge. I = Q/t, measured in Amperes (Coulombs per second).',
          ),
          const Question(
            id: 'e_q10',
            question: 'In a parallel circuit, what is the same across all branches?',
            options: ['Current', 'Resistance', 'Voltage', 'Power'],
            correctIndex: 2,
            explanation: 'In a parallel circuit, all branches are connected directly across the power supply, so they all have the same potential difference (voltage).',
          ),
        ],
      ),
    ],
    simulations: [
      const PhysicsSimulation(
        id: 'e_sim_circuits',
        title: 'Circuit Builder',
        description: 'Build circuits and measure voltage, current, and resistance',
        type: SimulationType.circuits,
      ),
      const PhysicsSimulation(
        id: 'e_sim_potential_divider',
        title: 'Potential Divider',
        description: 'Explore voltage division with fixed resistors, LDRs, and thermistors',
        type: SimulationType.potentialDivider,
      ),
      const PhysicsSimulation(
        id: 'e_sim_ohms_law',
        title: 'Ohm\'s Law',
        description: 'Investigate the relationship between voltage, current, and resistance',
        type: SimulationType.ohmsLaw,
      ),
      const PhysicsSimulation(
        id: 'e_sim_series',
        title: 'Resistors in Series',
        description: 'Explore how resistance adds up in series circuits',
        type: SimulationType.resistorsInSeries,
      ),
      const PhysicsSimulation(
        id: 'e_sim_parallel',
        title: 'Resistors in Parallel',
        description: 'Discover how parallel resistors reduce total resistance',
        type: SimulationType.resistorsInParallel,
      ),
      const PhysicsSimulation(
        id: 'e_sim_capacitor',
        title: 'Capacitor Charging',
        description: 'Watch capacitors charge and discharge over time',
        type: SimulationType.capacitorCharging,
      ),
      const PhysicsSimulation(
        id: 'e_sim_electrolysis',
        title: 'Electrolysis',
        description: 'Watch ions move during electrolysis — explore cathode, anode, cations and anions',
        type: SimulationType.electrolysis,
      ),
      const PhysicsSimulation(
        id: 'e_sim_voltmeter',
        title: 'Voltmeter',
        description: 'Learn how to connect and read a voltmeter in parallel across a component',
        type: SimulationType.voltmeter,
      ),
      const PhysicsSimulation(
        id: 'e_sim_electroplating',
        title: 'Electroplating & Electro-Refining',
        description: 'See how electrolysis coats objects with metal and purifies copper',
        type: SimulationType.electroplating,
      ),
    ],
  );

  // ==================== MAGNETISM ====================
  static final Topic _magnetismTopic = Topic(
    id: 'magnetism',
    title: 'Magnetism & Electromagnetism',
    description: 'Explore magnetic fields, electromagnets, motors, and transformers',
    icon: Icons.compass_calibration,
    color: const Color(0xFF9C27B0),
    lessons: [
      const Lesson(
        id: 'm_magnetic_fields',
        title: 'Magnetic Forces & Fields',
        content: '''Magnets produce magnetic fields - regions where magnetic materials experience a force.

Magnetic Poles:
• Every magnet has a North pole and South pole
• Like poles repel (N-N, S-S)
• Opposite poles attract (N-S)
• Magnetic field lines go from North to South outside the magnet

Magnetic Field Lines:
• Show direction a north pole would move
• Closer lines = stronger field
• Never cross each other
• Form complete loops (through magnet inside)

The Earth's Magnetic Field:
• Earth acts like a giant bar magnet
• Geographic North Pole is near Magnetic South Pole
• This is why compass north poles point north!
• Field protects us from solar radiation

Permanent vs Induced Magnets:
• Permanent magnets: Always magnetic (iron, nickel, cobalt)
• Induced magnets: Become magnetic when near a magnet
• Induced magnetism is temporary

Magnetic vs Non-Magnetic Materials:
Magnetic: Iron, Steel, Nickel, Cobalt
Non-magnetic: Copper, Aluminium, Wood, Plastic''',
        keyPoints: [
          'Like poles repel, opposite poles attract',
          'Field lines go from North to South',
          'Closer field lines = stronger field',
          'Earth\'s magnetic field protects us',
          'Only iron, nickel, cobalt are magnetic',
        ],
        formulas: [],
      ),
      const Lesson(
        id: 'm_electromagnetism',
        title: 'Electromagnetism',
        content: '''When current flows through a wire, it creates a magnetic field around the wire. This is electromagnetism.

Magnetic Field Around a Wire:
• Field forms concentric circles around wire
• Direction found using right-hand grip rule:
  - Thumb points in current direction
  - Fingers curl in field direction

Solenoid (Coil):
A coil of wire produces a stronger, uniform magnetic field inside.
• Field inside is like a bar magnet
• Field lines parallel inside coil
• One end is North, other is South

Strength of Electromagnet:
The magnetic field strength can be increased by:
• Increasing the current
• Increasing number of coils
• Adding an iron core

Advantages of Electromagnets:
• Can be switched on/off
• Strength can be varied
• Polarity can be reversed

Uses of Electromagnets:
• Scrapyard cranes
• MRI scanners
• Electric bells
• Maglev trains
• Speakers and microphones''',
        keyPoints: [
          'Current-carrying wire creates magnetic field',
          'Right-hand grip rule shows field direction',
          'Solenoid field like bar magnet',
          'Increase current/coils/iron core = stronger field',
          'Electromagnets can be switched on/off',
        ],
        formulas: [],
      ),
      const Lesson(
        id: 'm_motor_effect',
        title: 'The Motor Effect',
        content: '''When a current-carrying conductor is placed in a magnetic field, it experiences a force. This is the motor effect.

The Motor Effect:
A wire carrying current in a magnetic field experiences a force because two magnetic fields interact - the field from the magnet and the field from the current.

Fleming's Left-Hand Rule:
Use your LEFT hand:
• First finger = Field direction (N to S)
• Second finger = Current direction (+ to -)
• Thumb = Thrust (force/movement)

All three are at right angles to each other.

Force on a Wire:
F = B × I × L

Where:
• F = force (Newtons, N)
• B = magnetic flux density (Tesla, T)
• I = current (Amperes, A)
• L = length of wire in field (metres, m)

Factors Affecting Force:
The force is increased by:
• Stronger magnetic field (larger B)
• Larger current (larger I)
• Longer wire in field (larger L)

The force is zero when:
• Wire is parallel to field lines
• Maximum when wire is perpendicular to field''',
        keyPoints: [
          'Current in magnetic field experiences force',
          'Use Fleming\'s Left-Hand Rule for direction',
          'F = B × I × L',
          'Force maximum when wire perpendicular to field',
          'Basis of electric motors',
        ],
        formulas: [
          'F = B × I × L',
        ],
      ),
      const Lesson(
        id: 'm_motors',
        title: 'Electric Motors',
        content: '''Electric motors convert electrical energy into kinetic (movement) energy using the motor effect.

How a DC Motor Works:
1. Current flows through coil in magnetic field
2. Motor effect creates forces on each side of coil
3. Forces are in opposite directions (one up, one down)
4. This creates rotation

The Split-Ring Commutator:
• Reverses current direction every half turn
• Keeps motor spinning in same direction
• Without it, motor would oscillate back and forth

Increasing Motor Speed:
• Increase current
• Use stronger magnets
• Increase number of coils
• Add iron core to coil

Parts of a DC Motor:
• Permanent magnets (provide field)
• Coil (armature)
• Split-ring commutator
• Carbon brushes (connect to power)
• Axle

Applications:
• Electric vehicles
• Power tools
• Washing machines
• Computer fans
• DVD drives''',
        keyPoints: [
          'Motors convert electrical to kinetic energy',
          'Based on motor effect (F = BIL)',
          'Split-ring commutator reverses current',
          'More current/stronger magnets = faster',
          'Used in many everyday devices',
        ],
        formulas: [
          'F = B × I × L',
        ],
      ),
      const Lesson(
        id: 'm_transformers',
        title: 'Transformers',
        content: '''Transformers change the voltage of an alternating current (AC) supply. They only work with AC, not DC.

How Transformers Work:
1. AC in primary coil creates changing magnetic field
2. Iron core carries this field to secondary coil
3. Changing field induces voltage in secondary coil
4. Voltage depends on number of turns

The Transformer Equation:
Vₚ / Vₛ = Nₚ / Nₛ

Where:
• Vₚ = primary voltage
• Vₛ = secondary voltage
• Nₚ = number of turns on primary
• Nₛ = number of turns on secondary

Types of Transformers:
Step-Up Transformer:
• More turns on secondary than primary
• Increases voltage
• Decreases current
• Used in power stations

Step-Down Transformer:
• Fewer turns on secondary than primary
• Decreases voltage
• Increases current
• Used in phone chargers

Power in Transformers:
For 100% efficient transformer:
Vₚ × Iₚ = Vₛ × Iₛ

Power in = Power out

National Grid:
• Uses step-up transformers to increase voltage for transmission
• High voltage = low current = less energy lost as heat
• Step-down transformers reduce voltage for homes (230V)''',
        keyPoints: [
          'Transformers only work with AC',
          'Vₚ/Vₛ = Nₚ/Nₛ',
          'Step-up: increases voltage, decreases current',
          'Step-down: decreases voltage, increases current',
          'National Grid uses high voltage to reduce losses',
        ],
        formulas: [
          'Vₚ / Vₛ = Nₚ / Nₛ',
          'Vₚ × Iₚ = Vₛ × Iₛ (100% efficiency)',
        ],
      ),
    ],
    quizzes: [
      Quiz(
        id: 'm_quiz_1',
        title: 'Magnetism Quiz',
        questions: [
          const Question(
            id: 'm_q1',
            question: 'What happens when two north poles are brought together?',
            options: ['They attract', 'They repel', 'Nothing happens', 'They stick together'],
            correctIndex: 1,
            explanation: 'Like poles repel each other. Two north poles (or two south poles) will push apart. Only opposite poles (N-S) attract.',
          ),
          const Question(
            id: 'm_q2',
            question: 'Which rule is used to find the direction of force on a current-carrying wire?',
            options: [
              'Right-hand grip rule',
              'Fleming\'s left-hand rule',
              'Fleming\'s right-hand rule',
              'Newton\'s third law'
            ],
            correctIndex: 1,
            explanation: 'Fleming\'s Left-Hand Rule is used for the motor effect. First finger = Field, Second finger = Current, Thumb = Thrust (force).',
          ),
          const Question(
            id: 'm_q3',
            question: 'What is the purpose of the split-ring commutator in a DC motor?',
            options: [
              'To increase speed',
              'To reverse current direction every half turn',
              'To create the magnetic field',
              'To reduce friction'
            ],
            correctIndex: 1,
            explanation: 'The split-ring commutator reverses the current direction every half rotation, ensuring the motor continues spinning in the same direction.',
          ),
          const Question(
            id: 'm_q4',
            question: 'A transformer has 100 turns on the primary and 500 turns on the secondary. If primary voltage is 20V, what is the secondary voltage?',
            options: ['4 V', '100 V', '2500 V', '0.4 V'],
            correctIndex: 1,
            explanation: 'Using Vₚ/Vₛ = Nₚ/Nₛ: 20/Vₛ = 100/500, so Vₛ = 20 × 500/100 = 100V. This is a step-up transformer.',
            formula: 'Vₚ / Vₛ = Nₚ / Nₛ',
          ),
          const Question(
            id: 'm_q5',
            question: 'Why do transformers only work with AC?',
            options: [
              'DC is too dangerous',
              'AC creates a changing magnetic field needed to induce voltage',
              'DC cannot flow through wires',
              'Transformers get too hot with DC'
            ],
            correctIndex: 1,
            explanation: 'Transformers work by electromagnetic induction, which requires a changing magnetic field. AC constantly changes direction, creating this changing field. DC is constant and would not induce a voltage.',
          ),
          const Question(
            id: 'm_q6',
            question: 'How can you increase the strength of an electromagnet?',
            options: [
              'Decrease the current',
              'Use fewer coils',
              'Add an iron core',
              'Use aluminium instead of copper wire'
            ],
            correctIndex: 2,
            explanation: 'Adding an iron core significantly increases the magnetic field strength because iron is easily magnetized. Also: increase current, increase number of coils.',
          ),
          const Question(
            id: 'm_q7',
            question: 'What does F = BIL calculate?',
            options: [
              'Voltage in a circuit',
              'Force on a current-carrying wire in a magnetic field',
              'Power of a motor',
              'Magnetic field strength'
            ],
            correctIndex: 1,
            explanation: 'F = BIL gives the force on a current-carrying wire in a magnetic field. F = force, B = magnetic flux density, I = current, L = length of wire.',
          ),
          const Question(
            id: 'm_q8',
            question: 'Why does the National Grid use high voltages?',
            options: [
              'Electricity travels faster at high voltage',
              'High voltage is safer',
              'Less current means less energy lost as heat',
              'Power stations only produce high voltage'
            ],
            correctIndex: 2,
            explanation: 'Power = Voltage × Current. For the same power, higher voltage means lower current. Since heat loss = I²R, lower current means much less energy wasted as heat in cables.',
          ),
          const Question(
            id: 'm_q9',
            question: 'Which materials are magnetic?',
            options: [
              'Iron, copper, aluminium',
              'Iron, nickel, cobalt',
              'Steel, plastic, wood',
              'Silver, gold, copper'
            ],
            correctIndex: 1,
            explanation: 'Only iron, nickel, and cobalt (and their alloys like steel) are magnetic materials. Most metals like copper, aluminium, gold, and silver are not magnetic.',
          ),
          const Question(
            id: 'm_q10',
            question: 'In Fleming\'s Left-Hand Rule, what does the thumb represent?',
            options: ['Field direction', 'Current direction', 'Thrust (force/motion)', 'Voltage'],
            correctIndex: 2,
            explanation: 'In Fleming\'s Left-Hand Rule: First finger = Field, Second finger = Current, Thumb = Thrust (the direction of force or motion).',
          ),
        ],
      ),
    ],
    simulations: [
      const PhysicsSimulation(
        id: 'm_sim_magnet',
        title: 'Magnetic Field Visualizer',
        description: 'See magnetic field lines and explore magnet interactions',
        type: SimulationType.magnetism,
      ),
      const PhysicsSimulation(
        id: 'm_sim_electromagnet',
        title: 'Electromagnet Strength',
        description: 'Explore how current, coils, and core material affect electromagnet strength',
        type: SimulationType.electromagnetStrength,
      ),
      const PhysicsSimulation(
        id: 'm_sim_motor',
        title: 'Motor Effect',
        description: 'See how current-carrying conductors experience force in magnetic fields',
        type: SimulationType.motorEffect,
      ),
      const PhysicsSimulation(
        id: 'm_sim_generator',
        title: 'Generator',
        description: 'Explore electromagnetic induction and AC/DC generation',
        type: SimulationType.generator,
      ),
      const PhysicsSimulation(
        id: 'm_sim_transformer',
        title: 'Transformer',
        description: 'Investigate how transformers step voltage up and down',
        type: SimulationType.transformer,
      ),
    ],
  );

  // ==================== SPACE ====================
  static final Topic _spaceTopic = Topic(
    id: 'space',
    title: 'Space Physics',
    description: 'Discover our solar system, stars, galaxies, and the expanding universe',
    icon: Icons.rocket_launch,
    color: const Color(0xFF3F51B5),
    lessons: [
      const Lesson(
        id: 's_solar_system',
        title: 'Our Solar System',
        content: '''Our solar system consists of the Sun and everything that orbits around it, held together by gravity.

The Sun:
• A medium-sized star
• Contains 99.8% of solar system's mass
• Produces energy by nuclear fusion (hydrogen → helium)
• Surface temperature: about 5,500°C
• Core temperature: about 15 million °C

The Planets (in order from Sun):
1. Mercury - smallest, closest to Sun, no atmosphere
2. Venus - hottest planet (greenhouse effect), similar size to Earth
3. Earth - only known planet with life, has liquid water
4. Mars - the "red planet", has largest volcano (Olympus Mons)
5. Jupiter - largest planet, Great Red Spot storm
6. Saturn - famous rings made of ice and rock
7. Uranus - rotates on its side
8. Neptune - windiest planet, furthest from Sun

Other Objects:
• Dwarf planets (e.g., Pluto)
• Asteroids (rocky, mostly between Mars and Jupiter)
• Comets (ice and dust, have tails near Sun)
• Moons (natural satellites)

Orbital Motion:
• Planets orbit the Sun in ellipses (slightly squashed circles)
• Closer planets orbit faster
• Gravity provides the centripetal force for orbits
• Orbital period increases with distance from Sun''',
        keyPoints: [
          'Sun contains 99.8% of solar system\'s mass',
          '8 planets: Mercury, Venus, Earth, Mars, Jupiter, Saturn, Uranus, Neptune',
          'Inner planets are rocky, outer planets are gas giants',
          'Gravity keeps objects in orbit',
          'Closer planets orbit faster',
        ],
        formulas: [],
      ),
      const Lesson(
        id: 's_life_cycle_stars',
        title: 'The Life Cycle of Stars',
        content: '''Stars are born, live, and die over billions of years. Their fate depends on their initial mass.

Birth of a Star:
1. Nebula (cloud of gas and dust) begins to collapse under gravity
2. Temperature and pressure increase
3. Protostar forms
4. When core reaches ~15 million °C, nuclear fusion begins
5. Star is born - now a main sequence star

Main Sequence:
• Most of star's life spent here
• Hydrogen fuses to form helium
• Outward radiation pressure balances inward gravity
• Sun will be main sequence for ~10 billion years total

Death of Stars Like Our Sun:
1. Hydrogen runs out in core
2. Core contracts, outer layers expand → Red Giant
3. Outer layers blown off → Planetary Nebula
4. Core left behind → White Dwarf
5. Eventually cools to Black Dwarf

Death of Massive Stars:
1. After main sequence → Red Supergiant
2. Heavier elements fuse (up to iron)
3. Core collapses suddenly → Supernova explosion
4. If remaining core < 3 solar masses → Neutron Star
5. If remaining core > 3 solar masses → Black Hole

Elements:
• Elements up to iron formed by fusion in stars
• Elements heavier than iron formed in supernovae
• We are made of "star stuff"!''',
        keyPoints: [
          'Stars form from nebulae (gas and dust clouds)',
          'Nuclear fusion powers stars',
          'Small stars → White dwarf',
          'Massive stars → Supernova → Neutron star or Black hole',
          'Heavy elements created in supernovae',
        ],
        formulas: [],
      ),
      const Lesson(
        id: 's_redshift',
        title: 'Red-Shift & The Big Bang',
        content: '''Observations of distant galaxies reveal that our universe is expanding and had a beginning.

Red-Shift:
When a light source moves away from us, the light waves are stretched, shifting towards the red end of the spectrum.
• All distant galaxies show red-shift
• More distant galaxies show greater red-shift
• Galaxies are moving away from us

Hubble's Law:
The speed at which a galaxy moves away is proportional to its distance.
v = H₀ × d

Where:
• v = recession velocity
• H₀ = Hubble constant
• d = distance to galaxy

This means the universe is expanding!

The Big Bang Theory:
Evidence suggests the universe began as an infinitely hot, dense point about 13.8 billion years ago.

Evidence for Big Bang:
1. Red-shift of galaxies (universe expanding)
2. Cosmic Microwave Background Radiation (CMBR)
   - Leftover heat from Big Bang
   - Same temperature in all directions
   - Discovered in 1965

Dark Matter and Dark Energy:
• Dark matter: Invisible matter that affects galaxy rotation
• Dark energy: Causes accelerating expansion
• Together they make up ~95% of universe!

Composition of Universe:
• Ordinary matter: ~5%
• Dark matter: ~27%
• Dark energy: ~68%''',
        keyPoints: [
          'Red-shift shows galaxies moving away from us',
          'Greater distance = greater red-shift',
          'Universe is expanding',
          'Big Bang occurred ~13.8 billion years ago',
          'CMBR is evidence for Big Bang',
        ],
        formulas: [
          'v = H₀ × d (Hubble\'s Law)',
        ],
      ),
    ],
    quizzes: [
      Quiz(
        id: 's_quiz_1',
        title: 'Space Quiz',
        questions: [
          const Question(
            id: 's_q1',
            question: 'What force keeps planets in orbit around the Sun?',
            options: ['Magnetism', 'Friction', 'Gravity', 'Nuclear force'],
            correctIndex: 2,
            explanation: 'Gravity is the force that keeps planets in orbit. The Sun\'s gravitational pull provides the centripetal force needed for orbital motion.',
          ),
          const Question(
            id: 's_q2',
            question: 'What will our Sun eventually become?',
            options: ['Black hole', 'Neutron star', 'White dwarf', 'Red supergiant forever'],
            correctIndex: 2,
            explanation: 'Our Sun is a medium-sized star. After becoming a red giant, it will shed its outer layers and the core will become a white dwarf.',
          ),
          const Question(
            id: 's_q3',
            question: 'What process powers the Sun?',
            options: ['Nuclear fission', 'Nuclear fusion', 'Burning of gas', 'Chemical reactions'],
            correctIndex: 1,
            explanation: 'Nuclear fusion powers the Sun. Hydrogen nuclei fuse together to form helium, releasing enormous amounts of energy.',
          ),
          const Question(
            id: 's_q4',
            question: 'What is red-shift evidence of?',
            options: [
              'Galaxies getting hotter',
              'Galaxies moving towards us',
              'Galaxies moving away from us',
              'Light slowing down'
            ],
            correctIndex: 2,
            explanation: 'Red-shift occurs when a light source moves away from the observer. Distant galaxies showing red-shift proves they are moving away from us.',
          ),
          const Question(
            id: 's_q5',
            question: 'What is the CMBR evidence for?',
            options: ['Existence of black holes', 'The Big Bang', 'Life on other planets', 'The Sun\'s power'],
            correctIndex: 1,
            explanation: 'The Cosmic Microwave Background Radiation (CMBR) is leftover thermal radiation from the Big Bang, detected uniformly across the sky.',
          ),
          const Question(
            id: 's_q6',
            question: 'Which planet is the largest in our solar system?',
            options: ['Saturn', 'Neptune', 'Jupiter', 'Uranus'],
            correctIndex: 2,
            explanation: 'Jupiter is the largest planet, with a mass greater than all other planets combined. It\'s a gas giant with the famous Great Red Spot.',
          ),
          const Question(
            id: 's_q7',
            question: 'Approximately how old is the universe?',
            options: ['4.5 billion years', '13.8 billion years', '100 million years', '1 billion years'],
            correctIndex: 1,
            explanation: 'Based on measurements of cosmic background radiation and the expansion rate, the universe is approximately 13.8 billion years old.',
          ),
          const Question(
            id: 's_q8',
            question: 'What forms when a massive star dies in a supernova?',
            options: [
              'White dwarf only',
              'Neutron star or black hole',
              'Another main sequence star',
              'A nebula only'
            ],
            correctIndex: 1,
            explanation: 'After a supernova, the remaining core forms either a neutron star (if less than ~3 solar masses) or a black hole (if greater than ~3 solar masses).',
          ),
          const Question(
            id: 's_q9',
            question: 'What are elements heavier than iron created by?',
            options: ['Nuclear fusion in the Sun', 'The Big Bang', 'Supernova explosions', 'Planet formation'],
            correctIndex: 2,
            explanation: 'Elements heavier than iron require more energy to form than fusion provides. They are created in the extreme conditions of supernova explosions.',
          ),
          const Question(
            id: 's_q10',
            question: 'What makes up most of the universe?',
            options: [
              'Stars and planets',
              'Dark matter and dark energy',
              'Hydrogen gas',
              'Black holes'
            ],
            correctIndex: 1,
            explanation: 'Dark energy (~68%) and dark matter (~27%) make up about 95% of the universe. Ordinary matter (stars, planets, us) is only about 5%.',
          ),
        ],
      ),
    ],
    simulations: [
      const PhysicsSimulation(
        id: 's_sim_solar',
        title: 'Solar System Explorer',
        description: 'Explore planets, their orbits, and learn about each world',
        type: SimulationType.solarSystem,
      ),
      const PhysicsSimulation(
        id: 's_sim_satellites',
        title: 'Satellites & Orbits',
        description: 'Explore LEO, MEO, GEO, and polar satellite orbits',
        type: SimulationType.satellites,
      ),
      const PhysicsSimulation(
        id: 's_sim_orbits',
        title: 'Planetary Orbits',
        description: 'Visualize orbital mechanics and Kepler\'s laws',
        type: SimulationType.orbits,
      ),
    ],
  );

  // ==================== ENERGY ====================
  static final Topic _energyTopic = Topic(
    id: 'energy',
    title: 'Energy & Forces',
    description: 'Learn about energy transfers, work, pressure, and simple machines',
    icon: Icons.local_fire_department,
    color: const Color(0xFFFF5722),
    lessons: [
      const Lesson(
        id: 'en_energy_stores',
        title: 'Energy Stores & Transfers',
        content: '''Energy cannot be created or destroyed, only transferred between stores. This is the law of conservation of energy.

Energy Stores:
1. Kinetic - energy of moving objects
2. Gravitational Potential - energy due to height
3. Elastic Potential - energy in stretched/compressed objects
4. Chemical - energy in bonds (food, fuels, batteries)
5. Thermal (Internal) - energy due to temperature
6. Nuclear - energy in atomic nuclei
7. Magnetic - energy in magnetic fields
8. Electrostatic - energy in electric fields

Energy Transfers:
Energy moves between stores by:
• Mechanically (by forces)
• Electrically (by current)
• By heating (conduction, convection, radiation)
• By radiation (light, sound)

Key Equations:

Kinetic Energy:
KE = ½ × m × v²

Gravitational Potential Energy:
GPE = m × g × h

Where:
• m = mass (kg)
• v = velocity (m/s)
• g = gravitational field strength (10 N/kg on Earth)
• h = height (m)

Elastic Potential Energy:
EPE = ½ × k × e²

Where k = spring constant, e = extension''',
        keyPoints: [
          'Energy is conserved - cannot be created or destroyed',
          '8 energy stores to remember',
          'KE = ½mv²',
          'GPE = mgh',
          'Energy transfers by forces, current, heating, or radiation',
        ],
        formulas: [
          'KE = ½ × m × v²',
          'GPE = m × g × h',
          'EPE = ½ × k × e²',
        ],
      ),
      const Lesson(
        id: 'en_work_power',
        title: 'Work & Power',
        content: '''Work is done when a force moves an object. Power is the rate of doing work.

Work Done:
When a force moves an object through a distance:
W = F × d

Where:
• W = work done (Joules, J)
• F = force (Newtons, N)
• d = distance moved in direction of force (metres, m)

Work done = energy transferred

Power:
Power is how quickly work is done (or energy is transferred):
P = W / t  or  P = E / t

Where:
• P = power (Watts, W)
• W = work done (J)
• E = energy transferred (J)
• t = time (s)

1 Watt = 1 Joule per second

Alternative Power Equation:
P = F × v

Where v = velocity

Example:
A crane lifts a 500kg load through 20m.
Work done = Force × distance = (500 × 10) × 20 = 100,000 J

If this takes 25 seconds:
Power = 100,000 / 25 = 4000 W = 4 kW''',
        keyPoints: [
          'Work done = Force × Distance',
          'Work done = Energy transferred',
          'Power = Work done ÷ Time',
          '1 Watt = 1 Joule per second',
          'P = F × v for moving objects',
        ],
        formulas: [
          'W = F × d',
          'P = W / t',
          'P = E / t',
          'P = F × v',
        ],
      ),
      const Lesson(
        id: 'en_pressure',
        title: 'Pressure',
        content: '''Pressure is the force per unit area. It explains why sharp objects cut better than blunt ones.

Pressure Equation:
P = F / A

Where:
• P = pressure (Pascals, Pa)
• F = force (Newtons, N)
• A = area (square metres, m²)

1 Pascal = 1 N/m²

Everyday Examples:
• Sharp knife: small area = high pressure = cuts easily
• Snowshoes: large area = low pressure = don't sink in snow
• Drawing pins: small point = high pressure = goes into board easily

Pressure in Liquids:
Pressure in a liquid:
• Acts in all directions
• Increases with depth
• Depends on density of liquid

P = ρ × g × h

Where:
• ρ (rho) = density of liquid (kg/m³)
• g = gravitational field strength (N/kg)
• h = depth (m)

Atmospheric Pressure:
• Caused by weight of air above us
• About 101,000 Pa at sea level
• Decreases with altitude
• Acts in all directions''',
        keyPoints: [
          'Pressure = Force ÷ Area',
          'Smaller area = higher pressure',
          'Pressure in liquids increases with depth',
          'P = ρgh for liquid pressure',
          'Atmospheric pressure ≈ 101,000 Pa',
        ],
        formulas: [
          'P = F / A',
          'P = ρ × g × h',
        ],
      ),
      const Lesson(
        id: 'en_levers_gears',
        title: 'Levers & Gears',
        content: '''Simple machines like levers and gears help us apply forces more effectively.

Levers:
A lever is a rigid bar that rotates around a pivot (fulcrum).

Moment = Force × Perpendicular distance from pivot
M = F × d

For a balanced lever:
Clockwise moment = Anticlockwise moment
F₁ × d₁ = F₂ × d₂

This is the principle of moments.

Types of Levers:
• Class 1: Pivot in middle (e.g., seesaw, scissors)
• Class 2: Load in middle (e.g., wheelbarrow, nutcracker)
• Class 3: Effort in middle (e.g., tweezers, fishing rod)

Mechanical Advantage:
Some levers multiply force (but reduce distance moved).

Gears:
Gears are toothed wheels that interlock.

• Smaller gear driving larger gear: Force multiplied, speed reduced
• Larger gear driving smaller gear: Speed multiplied, force reduced

Gear Ratio = Teeth on driven gear / Teeth on driver gear

When gears interlock, they rotate in opposite directions.

Uses:
• Bicycles (changing gear ratio)
• Cars (gearbox)
• Clocks (precise movement)''',
        keyPoints: [
          'Moment = Force × Distance from pivot',
          'Principle of moments: Clockwise = Anticlockwise',
          'Levers can multiply force',
          'Gears change speed and force',
          'Interlocking gears rotate in opposite directions',
        ],
        formulas: [
          'M = F × d',
          'F₁ × d₁ = F₂ × d₂ (balanced)',
          'Gear ratio = Driven teeth / Driver teeth',
        ],
      ),
      const Lesson(
        id: 'en_simple_machines',
        title: 'Simple Machines & Efficiency',
        content: '''What is a Simple Machine?
A simple machine is a device that makes work easier by changing the magnitude or direction of a force. Examples include levers, pulleys, inclined planes, and wheel-and-axles.

Key Definitions:
• Load – The force being overcome (e.g. the weight of the object being lifted).
• Effort – The force applied by the user to operate the machine.
• Velocity Ratio (V.R.) – The ratio of the distance moved by the effort to the distance moved by the load: V.R. = Distance moved by effort ÷ Distance moved by load.
• Mechanical Advantage (M.A.) – The ratio of the load to the effort: M.A. = Load ÷ Effort. A higher M.A. means you need less effort.
• Efficiency – The percentage of input work converted to useful output work: Efficiency = (M.A. ÷ V.R.) × 100%, or equivalently Efficiency = (Useful work output ÷ Total work input) × 100%.

Why is Efficiency Always Less Than 100% in Real Machines?
In practice, friction between moving parts converts some energy to heat, air resistance wastes energy, and some energy is used to move parts of the machine itself. These energy losses mean the useful work output is always less than the total work input.

Improving Efficiency:
• Lubricate moving parts to reduce friction.
• Streamline shapes to reduce air resistance.
• Use lighter materials for the machine components.

Examples of V.R.:
• Lever: V.R. = effort arm ÷ load arm
• Pulley system: V.R. = number of supporting ropes
• Inclined plane: V.R. = length of slope ÷ vertical height
• Wheel and axle: V.R. = radius of wheel ÷ radius of axle

Worked Example:
A machine lifts a 400 N load using 100 N of effort. The effort moves 2 m while the load rises 0.5 m.
M.A. = 400 ÷ 100 = 4
V.R. = 2 ÷ 0.5 = 4
Efficiency = (4 ÷ 4) × 100% = 100% (ideal)
In reality, friction would make the efficiency lower.''',
        keyPoints: [
          'Load is the force to overcome; Effort is the force applied',
          'M.A. = Load ÷ Effort',
          'V.R. = Distance moved by effort ÷ Distance moved by load',
          'Efficiency = (M.A. ÷ V.R.) × 100%',
          'Real machines always have efficiency less than 100% due to friction',
          'Types: lever, pulley, inclined plane, wheel and axle',
        ],
        formulas: [
          'M.A. = Load / Effort',
          'V.R. = Distance (effort) / Distance (load)',
          'Efficiency = (M.A. / V.R.) × 100%',
          'Efficiency = (Useful output / Total input) × 100%',
        ],
      ),
    ],
    quizzes: [
      Quiz(
        id: 'en_quiz_1',
        title: 'Energy Quiz',
        questions: [
          const Question(
            id: 'en_q1',
            question: 'What is the kinetic energy of a 2kg ball moving at 5 m/s?',
            options: ['5 J', '10 J', '25 J', '50 J'],
            correctIndex: 2,
            explanation: 'KE = ½mv² = ½ × 2 × 5² = ½ × 2 × 25 = 25 J',
            formula: 'KE = ½ × m × v²',
          ),
          const Question(
            id: 'en_q2',
            question: 'A 10kg mass is lifted 5m. What is its gravitational potential energy? (g = 10 N/kg)',
            options: ['50 J', '100 J', '250 J', '500 J'],
            correctIndex: 3,
            explanation: 'GPE = mgh = 10 × 10 × 5 = 500 J',
            formula: 'GPE = m × g × h',
          ),
          const Question(
            id: 'en_q3',
            question: 'What is work done measured in?',
            options: ['Watts', 'Newtons', 'Joules', 'Pascals'],
            correctIndex: 2,
            explanation: 'Work done is measured in Joules (J). 1 Joule = 1 Newton × 1 metre.',
          ),
          const Question(
            id: 'en_q4',
            question: 'A machine does 2000J of work in 4 seconds. What is its power?',
            options: ['8000 W', '500 W', '2004 W', '1996 W'],
            correctIndex: 1,
            explanation: 'Power = Work ÷ Time = 2000 ÷ 4 = 500 W',
            formula: 'P = W / t',
          ),
          const Question(
            id: 'en_q5',
            question: 'A force of 50N acts on an area of 0.1m². What is the pressure?',
            options: ['5 Pa', '50 Pa', '500 Pa', '0.002 Pa'],
            correctIndex: 2,
            explanation: 'Pressure = Force ÷ Area = 50 ÷ 0.1 = 500 Pa',
            formula: 'P = F / A',
          ),
          const Question(
            id: 'en_q6',
            question: 'Which energy store does a compressed spring have?',
            options: ['Kinetic', 'Gravitational potential', 'Elastic potential', 'Chemical'],
            correctIndex: 2,
            explanation: 'A compressed (or stretched) spring stores elastic potential energy. This is released when the spring returns to its original shape.',
          ),
          const Question(
            id: 'en_q7',
            question: 'What is the moment of a 20N force applied 0.5m from a pivot?',
            options: ['10 Nm', '40 Nm', '20.5 Nm', '0.025 Nm'],
            correctIndex: 0,
            explanation: 'Moment = Force × Distance = 20 × 0.5 = 10 Nm',
            formula: 'M = F × d',
          ),
          const Question(
            id: 'en_q8',
            question: 'For a balanced lever, what must be equal?',
            options: ['Forces', 'Distances', 'Clockwise and anticlockwise moments', 'Areas'],
            correctIndex: 2,
            explanation: 'The principle of moments states that for a balanced lever, the sum of clockwise moments equals the sum of anticlockwise moments.',
          ),
          const Question(
            id: 'en_q9',
            question: 'What happens when a small gear drives a larger gear?',
            options: [
              'Speed increases, force decreases',
              'Speed decreases, force increases',
              'Both speed and force increase',
              'Both speed and force decrease'
            ],
            correctIndex: 1,
            explanation: 'When a small gear drives a larger gear, the larger gear rotates more slowly but with more force. This is a gear reduction.',
          ),
          const Question(
            id: 'en_q10',
            question: 'What is the law of conservation of energy?',
            options: [
              'Energy can be created from nothing',
              'Energy is always lost',
              'Energy cannot be created or destroyed, only transferred',
              'Energy increases over time'
            ],
            correctIndex: 2,
            explanation: 'The law of conservation of energy states that energy cannot be created or destroyed, only transferred from one store to another.',
          ),
        ],
      ),
    ],
    simulations: [
      const PhysicsSimulation(
        id: 'en_sim_energy',
        title: 'Energy Transfer Simulator',
        description: 'See how energy transfers between different stores',
        type: SimulationType.energy,
      ),
      const PhysicsSimulation(
        id: 'en_sim_pressure',
        title: 'Pressure Demonstrator',
        description: 'Explore how force and area affect pressure',
        type: SimulationType.pressure,
      ),
      const PhysicsSimulation(
        id: 'en_sim_efficiency',
        title: 'Energy Efficiency',
        description: 'Visualize energy efficiency with Sankey diagrams for various devices',
        type: SimulationType.energyEfficiency,
      ),
      const PhysicsSimulation(
        id: 'en_sim_latent_heat',
        title: 'Latent Heat',
        description: 'Explore phase changes and latent heat with heating curves',
        type: SimulationType.latentHeat,
      ),
      const PhysicsSimulation(
        id: 'en_sim_specific_heat',
        title: 'Specific Heat Capacity',
        description: 'Compare how different materials heat up at different rates',
        type: SimulationType.specificHeatCapacity,
      ),
      const PhysicsSimulation(
        id: 'en_sim_density',
        title: 'Density',
        description: 'Explore mass, volume, and density of different materials',
        type: SimulationType.density,
      ),
      const PhysicsSimulation(
        id: 'en_sim_simple_machines',
        title: 'Simple Machines',
        description: 'Explore levers, pulleys, and inclined planes — calculate M.A., V.R. and efficiency',
        type: SimulationType.simpleMachines,
      ),
    ],
  );

  // ==================== NUCLEAR PHYSICS ====================
  static final Topic _nuclearPhysicsTopic = Topic(
    id: 'nuclear_physics',
    title: 'Nuclear Physics',
    description: 'Explore atoms, radioactivity, nuclear fission and fusion',
    icon: Icons.blur_circular,
    color: const Color(0xFFFF5722),
    lessons: [
      const Lesson(
        id: 'np_atom',
        title: 'The Atom',
        content: '''All matter is made up of atoms. Understanding atomic structure is fundamental to nuclear physics.

Structure of the Atom:
• Nucleus - The tiny, dense centre containing protons and neutrons
• Electrons - Negative particles orbiting the nucleus in shells
• Protons - Positive particles in the nucleus
• Neutrons - Neutral particles in the nucleus

Key Numbers:
• Atomic number (Z) = Number of protons
• Mass number (A) = Protons + Neutrons
• Atoms are neutral: number of protons = number of electrons

Size of the Atom:
• Atom diameter: approximately 1 × 10⁻¹⁰ m
• Nucleus diameter: approximately 1 × 10⁻¹⁴ m
• The nucleus is about 10,000 times smaller than the atom
• Most of an atom is empty space!

Isotopes:
Isotopes are atoms of the same element with different numbers of neutrons.
• Same atomic number (same element)
• Different mass number (different number of neutrons)
• Example: Carbon-12, Carbon-13, Carbon-14 are all carbon isotopes

Development of the Atomic Model:
1. Dalton's model - solid spheres
2. Thomson's plum pudding model - electrons embedded in positive charge
3. Rutherford's nuclear model - small positive nucleus with orbiting electrons
4. Bohr's model - electrons in fixed energy levels
5. Modern quantum model - electron clouds/probability distributions''',
        keyPoints: [
          'Atoms have a small, dense nucleus containing protons and neutrons',
          'Electrons orbit the nucleus in energy levels/shells',
          'Atomic number = number of protons',
          'Mass number = protons + neutrons',
          'Isotopes have the same protons but different neutrons',
          'Most of an atom is empty space',
        ],
        formulas: [
          'Mass number (A) = Protons + Neutrons',
          'Atomic notation: ᴬ_Z X',
        ],
      ),
      const Lesson(
        id: 'np_radioactive_decay',
        title: 'Radioactive Decay',
        content: '''Radioactive decay is the process by which unstable atomic nuclei release energy by emitting radiation.

Types of Radiation:

Alpha (α) Decay:
• Particle: 2 protons + 2 neutrons (helium nucleus)
• Charge: +2
• Mass: 4
• Penetration: Stopped by paper or skin
• Ionising ability: Strongly ionising
• Effect: Atomic number decreases by 2, mass number decreases by 4

Beta (β) Decay:
• Particle: High-speed electron
• Charge: -1
• Mass: Nearly zero (1/1836 of proton)
• Penetration: Stopped by aluminium (few mm)
• Ionising ability: Moderately ionising
• Effect: Atomic number increases by 1, mass number stays same
• A neutron converts into a proton and electron

Gamma (γ) Decay:
• Type: Electromagnetic radiation (photon)
• Charge: 0
• Mass: 0
• Penetration: Reduced by thick lead or concrete
• Ionising ability: Weakly ionising
• Effect: No change to atomic or mass number
• Releases excess energy from nucleus

Nuclear Equations:
Alpha: ²²⁶₈₈Ra → ²²²₈₆Rn + ⁴₂He
Beta: ¹⁴₆C → ¹⁴₇N + ⁰₋₁e
Gamma: Excited nucleus → Ground state + γ''',
        keyPoints: [
          'Alpha particles are helium nuclei (2p + 2n)',
          'Beta particles are high-speed electrons',
          'Gamma rays are electromagnetic radiation',
          'Alpha is most ionising but least penetrating',
          'Gamma is least ionising but most penetrating',
          'Radioactive decay is random and spontaneous',
        ],
        formulas: [
          'Alpha decay: A decreases by 4, Z decreases by 2',
          'Beta decay: A stays same, Z increases by 1',
          'Gamma decay: No change to A or Z',
        ],
      ),
      const Lesson(
        id: 'np_half_life',
        title: 'Half-Life',
        content: '''Half-life is the time taken for half of the radioactive nuclei in a sample to decay.

Key Concepts:
• Half-life is constant for a given isotope
• It cannot be changed by physical or chemical conditions
• Decay is random - we cannot predict which atom will decay next
• We can only predict the probability of decay

Calculating Half-Life:
After 1 half-life: 50% remains (½)
After 2 half-lives: 25% remains (¼)
After 3 half-lives: 12.5% remains (⅛)
After n half-lives: (½)ⁿ remains

Example:
If a sample has 1000 atoms and half-life of 10 minutes:
• After 10 min: 500 atoms
• After 20 min: 250 atoms
• After 30 min: 125 atoms

Activity:
Activity is the number of decays per second, measured in becquerels (Bq).
• 1 Bq = 1 decay per second
• Activity decreases as the sample decays
• Activity halves every half-life

Uses of Different Half-Lives:
• Short half-life: Medical tracers (decays quickly, less exposure)
• Long half-life: Carbon dating (detectable over thousands of years)
• Very long half-life: Nuclear waste (remains dangerous for millennia)''',
        keyPoints: [
          'Half-life is constant for each isotope',
          'Cannot be changed by temperature, pressure or chemical reactions',
          'Decay is random and spontaneous',
          'Activity is measured in becquerels (Bq)',
          'After n half-lives, fraction remaining = (½)ⁿ',
        ],
        formulas: [
          'Remaining fraction = (½)ⁿ where n = number of half-lives',
          'Activity (Bq) = decays per second',
          'n = total time ÷ half-life',
        ],
      ),
      const Lesson(
        id: 'np_hazards_uses',
        title: 'Hazards & Uses of Radiation',
        content: '''Radiation can be both harmful and useful. Understanding the risks and benefits is crucial.

Hazards of Radiation:

Irradiation:
• Exposure to radiation from an external source
• The body is exposed but not contaminated
• Risk ends when source is removed
• Can be controlled with shielding and distance

Contamination:
• Radioactive material gets onto or into the body
• Continues to irradiate from inside/on the body
• More dangerous as source cannot be easily removed
• Requires decontamination procedures

Health Effects:
• Cell damage and death
• DNA mutations leading to cancer
• Radiation sickness at high doses
• Damage to reproductive cells (genetic effects)

Safety Measures:
• Minimise time of exposure
• Maximise distance from source
• Use appropriate shielding
• Monitor exposure with dosimeters

Uses of Radiation:

Medical Uses:
• Cancer treatment (radiotherapy) - gamma rays kill cancer cells
• Medical imaging (PET scans, gamma cameras)
• Sterilising medical equipment
• Tracers to diagnose conditions

Industrial Uses:
• Checking welds in pipelines (gamma radiography)
• Measuring thickness of materials
• Sterilising food
• Smoke detectors (alpha sources)

Scientific Uses:
• Carbon dating (determining age of organic materials)
• Studying chemical reactions with tracers
• Power generation (nuclear power stations)''',
        keyPoints: [
          'Irradiation is exposure; contamination is when material gets on/in you',
          'Contamination is more dangerous than irradiation',
          'Minimise time, maximise distance, use shielding',
          'Different types of radiation have different uses',
          'Medical uses include diagnosis and treatment',
        ],
        formulas: [],
      ),
      const Lesson(
        id: 'np_fission_fusion',
        title: 'Nuclear Fission & Fusion',
        content: '''Nuclear reactions release enormous amounts of energy by converting mass into energy.

Nuclear Fission:
Fission is the splitting of a large, unstable nucleus into two smaller nuclei, releasing energy.

Process:
1. A neutron is absorbed by a large nucleus (e.g., Uranium-235)
2. The nucleus becomes unstable
3. It splits into two smaller nuclei (fission products)
4. 2-3 neutrons are released
5. Large amount of energy is released

Chain Reaction:
• Released neutrons can cause more fissions
• Uncontrolled chain reaction = nuclear explosion
• Controlled chain reaction = nuclear power station

In a nuclear reactor:
• Control rods absorb excess neutrons
• Moderator slows down neutrons
• Coolant removes heat to generate electricity

Nuclear Fusion:
Fusion is the joining of two small nuclei to form a larger nucleus, releasing energy.

Process:
• Two hydrogen nuclei combine to form helium
• Mass of products is less than reactants
• Missing mass is converted to energy (E = mc²)

Conditions Required:
• Extremely high temperature (millions of degrees)
• High pressure
• To overcome electrostatic repulsion between positive nuclei

Fusion in Stars:
• Stars like our Sun are powered by fusion
• Hydrogen fuses to form helium
• Releases the energy we receive as light and heat

Fusion on Earth:
• Very difficult to achieve and sustain
• Experimental reactors being developed (ITER)
• Potential for clean, abundant energy''',
        keyPoints: [
          'Fission splits large nuclei; fusion joins small nuclei',
          'Both release energy by converting mass (E = mc²)',
          'Chain reactions in fission must be controlled',
          'Fusion requires extremely high temperatures',
          'Stars are powered by fusion',
          'Control rods and moderators manage fission reactors',
        ],
        formulas: [
          'E = mc² (mass-energy equivalence)',
          'Example fusion: ²H + ³H → ⁴He + n + energy',
          'Example fission: ²³⁵U + n → ¹⁴¹Ba + ⁹²Kr + 3n + energy',
        ],
      ),
    ],
    quizzes: [
      const Quiz(
        id: 'np_quiz',
        title: 'Nuclear Physics Quiz',
        questions: [
          Question(
            id: 'np_q1',
            question: 'What particles are found in the nucleus of an atom?',
            options: [
              'Electrons and protons',
              'Protons and neutrons',
              'Electrons and neutrons',
              'Only protons'
            ],
            correctIndex: 1,
            explanation: 'The nucleus contains protons (positive charge) and neutrons (no charge). Electrons orbit outside the nucleus.',
          ),
          Question(
            id: 'np_q2',
            question: 'What is an alpha particle made of?',
            options: [
              'An electron',
              '2 protons and 2 neutrons',
              'A neutron',
              'A photon'
            ],
            correctIndex: 1,
            explanation: 'An alpha particle consists of 2 protons and 2 neutrons, which is the same as a helium nucleus.',
          ),
          Question(
            id: 'np_q3',
            question: 'Which type of radiation is most penetrating?',
            options: [
              'Alpha',
              'Beta',
              'Gamma',
              'All equal'
            ],
            correctIndex: 2,
            explanation: 'Gamma radiation is most penetrating - it can pass through paper, aluminium, and requires thick lead or concrete to stop it.',
          ),
          Question(
            id: 'np_q4',
            question: 'After 3 half-lives, what fraction of a radioactive sample remains?',
            options: [
              '1/2',
              '1/4',
              '1/8',
              '1/16'
            ],
            correctIndex: 2,
            explanation: 'After each half-life, half remains. After 3 half-lives: (1/2)³ = 1/8 of the original sample remains.',
          ),
          Question(
            id: 'np_q5',
            question: 'In beta decay, what happens to the atomic number?',
            options: [
              'Decreases by 2',
              'Stays the same',
              'Increases by 1',
              'Decreases by 1'
            ],
            correctIndex: 2,
            explanation: 'In beta decay, a neutron converts to a proton (releasing an electron), so the atomic number increases by 1 while mass number stays the same.',
          ),
          Question(
            id: 'np_q6',
            question: 'What is nuclear fission?',
            options: [
              'Joining small nuclei together',
              'Splitting a large nucleus into smaller nuclei',
              'Emission of gamma rays',
              'Electron capture'
            ],
            correctIndex: 1,
            explanation: 'Nuclear fission is the splitting of a large, unstable nucleus (like Uranium-235) into two smaller nuclei, releasing energy and neutrons.',
          ),
          Question(
            id: 'np_q7',
            question: 'What powers the Sun?',
            options: [
              'Nuclear fission',
              'Chemical burning',
              'Nuclear fusion',
              'Radioactive decay'
            ],
            correctIndex: 2,
            explanation: 'The Sun is powered by nuclear fusion, where hydrogen nuclei fuse together to form helium, releasing enormous amounts of energy.',
          ),
          Question(
            id: 'np_q8',
            question: 'What are isotopes?',
            options: [
              'Atoms with different numbers of protons',
              'Atoms with different numbers of electrons',
              'Atoms with different numbers of neutrons',
              'Different elements'
            ],
            correctIndex: 2,
            explanation: 'Isotopes are atoms of the same element (same protons) with different numbers of neutrons, giving them different mass numbers.',
          ),
          Question(
            id: 'np_q9',
            question: 'Which is more dangerous: irradiation or contamination?',
            options: [
              'Irradiation',
              'Contamination',
              'Both equally dangerous',
              'Neither is dangerous'
            ],
            correctIndex: 1,
            explanation: 'Contamination is more dangerous because the radioactive source is on or inside the body, continuing to irradiate. Irradiation stops when you move away from the source.',
          ),
          Question(
            id: 'np_q10',
            question: 'What do control rods do in a nuclear reactor?',
            options: [
              'Speed up the reaction',
              'Absorb neutrons to control the reaction',
              'Produce electricity',
              'Cool the reactor'
            ],
            correctIndex: 1,
            explanation: 'Control rods absorb neutrons to control the rate of the chain reaction. Raising the rods speeds up the reaction; lowering them slows it down.',
          ),
        ],
      ),
    ],
    simulations: [
      const PhysicsSimulation(
        id: 'np_sim_decay',
        title: 'Radioactive Decay Simulator',
        description: 'Watch atoms decay and observe half-life patterns with alpha, beta, and gamma radiation',
        type: SimulationType.radioactiveDecay,
      ),
      const PhysicsSimulation(
        id: 'np_sim_particles',
        title: 'Particle Model',
        description: 'Explore how particles behave in different states of matter',
        type: SimulationType.particles,
      ),
      const PhysicsSimulation(
        id: 'np_sim_radiation',
        title: 'Radiation Types',
        description: 'Compare alpha, beta, and gamma radiation penetration and deflection in fields',
        type: SimulationType.radiationTypes,
      ),
      const PhysicsSimulation(
        id: 'np_sim_fission',
        title: 'Nuclear Fission',
        description: 'Visualize uranium fission and chain reactions in nuclear reactors',
        type: SimulationType.nuclearFission,
      ),
      const PhysicsSimulation(
        id: 'np_sim_fusion',
        title: 'Nuclear Fusion',
        description: 'See how hydrogen fuses into helium, powering the Sun',
        type: SimulationType.nuclearFusion,
      ),
      const PhysicsSimulation(
        id: 'np_sim_half_life',
        title: 'Half-Life',
        description: 'Watch radioactive decay and understand half-life graphically',
        type: SimulationType.halfLife,
      ),
    ],
  );

  // ==================== THERMAL PHYSICS ====================
  static final Topic _thermalPhysicsTopic = Topic(
    id: 'thermal_physics',
    title: 'Thermal Physics',
    description: 'Understand heat, temperature, energy transfer and changes of state',
    icon: Icons.thermostat,
    color: const Color(0xFFE91E63),
    lessons: [
      const Lesson(
        id: 'tp_states_matter',
        title: 'States of Matter',
        content: '''Matter exists in three main states: solid, liquid, and gas. The particle model explains their properties.

Solid:
• Particles are closely packed in a regular arrangement
• Particles vibrate about fixed positions
• Strong forces of attraction between particles
• Fixed shape and volume
• Cannot be compressed

Liquid:
• Particles are close together but irregularly arranged
• Particles can move past each other
• Moderate forces of attraction
• Fixed volume but takes shape of container
• Cannot be easily compressed

Gas:
• Particles are far apart and randomly arranged
• Particles move quickly in all directions
• Very weak forces of attraction
• No fixed shape or volume
• Can be compressed easily

Changes of State:
• Melting: Solid → Liquid (absorbs energy)
• Freezing: Liquid → Solid (releases energy)
• Boiling/Evaporation: Liquid → Gas (absorbs energy)
• Condensation: Gas → Liquid (releases energy)
• Sublimation: Solid → Gas directly

During a change of state:
• Temperature remains constant
• Energy is used to break/form bonds between particles
• This energy is called latent heat''',
        keyPoints: [
          'Solids have fixed shape and volume - particles vibrate in place',
          'Liquids have fixed volume but take container shape - particles can flow',
          'Gases fill their container - particles move freely',
          'Changes of state require or release energy',
          'Temperature stays constant during state changes',
        ],
        formulas: [],
      ),
      const Lesson(
        id: 'tp_internal_energy',
        title: 'Internal Energy',
        content: '''Internal energy is the total energy stored inside a system by the particles that make it up.

Components of Internal Energy:
1. Kinetic Energy - energy due to particle movement
2. Potential Energy - energy stored in bonds between particles

Internal Energy = Total Kinetic Energy + Total Potential Energy

Temperature and Kinetic Energy:
• Temperature is a measure of the average kinetic energy of particles
• Higher temperature = particles moving faster = more kinetic energy
• At absolute zero (-273°C or 0 K), particles have minimum energy

Heating a Substance:
When you heat a substance, you increase its internal energy by either:
1. Increasing temperature (particles move faster)
2. Changing state (breaking bonds between particles)

Energy Transfer:
• Conduction: Energy passed between particles in contact
• Convection: Movement of hot fluid (liquid or gas)
• Radiation: Energy transferred by electromagnetic waves

Specific Heat Capacity:
The energy needed to raise 1 kg of a substance by 1°C

Different materials have different specific heat capacities:
• Water: 4200 J/kg°C (high - good for storing heat)
• Copper: 385 J/kg°C (low - heats up quickly)
• Air: 1000 J/kg°C''',
        keyPoints: [
          'Internal energy = kinetic energy + potential energy of particles',
          'Temperature measures average kinetic energy',
          'Heating increases internal energy',
          'Energy can raise temperature OR change state, not both at once',
          'Specific heat capacity varies between materials',
        ],
        formulas: [
          'Internal Energy = KE + PE of all particles',
          'Temperature (K) = Temperature (°C) + 273',
        ],
      ),
      const Lesson(
        id: 'tp_specific_heat',
        title: 'Specific Heat Capacity',
        content: '''Specific heat capacity (c) is the amount of energy needed to raise the temperature of 1 kg of a substance by 1°C.

The Formula:
Energy = mass × specific heat capacity × temperature change
E = m × c × ΔT

Where:
• E = energy transferred (J)
• m = mass (kg)
• c = specific heat capacity (J/kg°C)
• ΔT = change in temperature (°C)

Common Specific Heat Capacities:
• Water: 4200 J/kg°C
• Ice: 2100 J/kg°C
• Copper: 385 J/kg°C
• Aluminium: 900 J/kg°C
• Lead: 130 J/kg°C

Example Calculation:
How much energy is needed to heat 2 kg of water from 20°C to 100°C?
E = m × c × ΔT
E = 2 × 4200 × (100 - 20)
E = 2 × 4200 × 80
E = 672,000 J = 672 kJ

Why Water Has High Specific Heat Capacity:
• Takes a lot of energy to heat up
• Also releases a lot of energy when cooling
• Useful for: central heating systems, cooling systems, regulating climate''',
        keyPoints: [
          'Specific heat capacity is energy per kg per degree',
          'Water has a high specific heat capacity (4200 J/kg°C)',
          'E = mcΔT is the key equation',
          'Different materials heat up at different rates',
          'High SHC means slow to heat and slow to cool',
        ],
        formulas: [
          'E = m × c × ΔT',
          'c = E ÷ (m × ΔT)',
          'ΔT = E ÷ (m × c)',
        ],
      ),
      const Lesson(
        id: 'tp_latent_heat',
        title: 'Specific Latent Heat',
        content: '''Specific latent heat is the energy needed to change the state of 1 kg of a substance without changing its temperature.

Two Types:

Latent Heat of Fusion (Lf):
• Energy to change 1 kg from solid to liquid (or vice versa)
• At melting/freezing point
• Water: 334,000 J/kg

Latent Heat of Vaporisation (Lv):
• Energy to change 1 kg from liquid to gas (or vice versa)
• At boiling point
• Water: 2,260,000 J/kg

The Formula:
Energy = mass × specific latent heat
E = m × L

Where:
• E = energy transferred (J)
• m = mass (kg)
• L = specific latent heat (J/kg)

Why No Temperature Change?
• During state change, energy breaks/forms bonds between particles
• Potential energy changes, not kinetic energy
• Since temperature measures kinetic energy, it stays constant

Heating Curve:
When heating ice from -20°C to steam at 120°C:
1. Ice heats up (temperature rises)
2. Ice melts at 0°C (temperature constant - latent heat of fusion)
3. Water heats up (temperature rises)
4. Water boils at 100°C (temperature constant - latent heat of vaporisation)
5. Steam heats up (temperature rises)

The flat sections of a heating curve show state changes where latent heat is being absorbed.''',
        keyPoints: [
          'Latent heat changes state without changing temperature',
          'Latent heat of fusion: solid ↔ liquid',
          'Latent heat of vaporisation: liquid ↔ gas',
          'E = mL is the key equation',
          'Energy goes into breaking bonds, not increasing kinetic energy',
        ],
        formulas: [
          'E = m × L',
          'Lf (water) = 334,000 J/kg',
          'Lv (water) = 2,260,000 J/kg',
        ],
      ),
      const Lesson(
        id: 'tp_static_electricity',
        title: 'Static Electricity',
        content: '''Static electricity is the build-up of electric charge on the surface of objects.

How Static Charge Builds Up:
• When two insulating materials are rubbed together
• Electrons transfer from one material to the other
• One becomes positively charged (loses electrons)
• One becomes negatively charged (gains electrons)

Examples:
• Rubbing a balloon on hair (balloon becomes negative)
• Walking on carpet (you become charged)
• Rubbing a polythene rod with a cloth

Electric Fields:
• A charged object creates an electric field around it
• Other charged objects in the field experience a force
• Field lines show the direction of force on a positive charge
• Lines go from positive to negative

Forces Between Charges:
• Like charges repel (positive-positive or negative-negative)
• Opposite charges attract (positive-negative)
• Force depends on charge and distance

Dangers of Static:
• Sparks can ignite fuel vapours
• Electric shocks
• Damage to electronic components

Uses of Static:
• Photocopiers and laser printers
• Spray painting (even coating)
• Electrostatic precipitators (removing pollution)
• Crop sprayers

Earthing:
• Connecting a charged object to the ground
• Allows charge to flow away safely
• Prevents dangerous build-up of charge''',
        keyPoints: [
          'Static electricity is caused by transfer of electrons',
          'Like charges repel, opposite charges attract',
          'Electrons are transferred, not created',
          'Earthing removes excess charge safely',
          'Static can be both dangerous and useful',
        ],
        formulas: [],
      ),
    ],
    quizzes: [
      const Quiz(
        id: 'tp_quiz',
        title: 'Thermal Physics Quiz',
        questions: [
          Question(
            id: 'tp_q1',
            question: 'What happens to particles when a solid is heated?',
            options: [
              'They slow down',
              'They vibrate more',
              'They get smaller',
              'Nothing changes'
            ],
            correctIndex: 1,
            explanation: 'When a solid is heated, particles gain kinetic energy and vibrate more vigorously about their fixed positions.',
          ),
          Question(
            id: 'tp_q2',
            question: 'What is specific heat capacity?',
            options: [
              'The temperature at which a substance melts',
              'The energy to change state',
              'The energy to raise 1 kg by 1°C',
              'The maximum temperature possible'
            ],
            correctIndex: 2,
            explanation: 'Specific heat capacity is the amount of energy needed to raise the temperature of 1 kg of a substance by 1°C.',
          ),
          Question(
            id: 'tp_q3',
            question: 'Why does temperature stay constant during melting?',
            options: [
              'No energy is being added',
              'Energy is used to break bonds, not increase kinetic energy',
              'The thermometer is broken',
              'Heat is being lost to surroundings'
            ],
            correctIndex: 1,
            explanation: 'During melting, energy (latent heat) is used to break bonds between particles rather than increase their kinetic energy, so temperature stays constant.',
          ),
          Question(
            id: 'tp_q4',
            question: 'How much energy is needed to heat 0.5 kg of water by 10°C? (c = 4200 J/kg°C)',
            options: [
              '2100 J',
              '21000 J',
              '4200 J',
              '42000 J'
            ],
            correctIndex: 1,
            explanation: 'E = mcΔT = 0.5 × 4200 × 10 = 21,000 J',
            formula: 'E = m × c × ΔT',
          ),
          Question(
            id: 'tp_q5',
            question: 'When you rub a balloon on your hair, electrons move from:',
            options: [
              'Hair to balloon',
              'Balloon to hair',
              'Neither - no electrons move',
              'Both directions equally'
            ],
            correctIndex: 0,
            explanation: 'Electrons transfer from hair to the balloon, making the balloon negatively charged and hair positively charged.',
          ),
          Question(
            id: 'tp_q6',
            question: 'Which has the higher latent heat for water: fusion or vaporisation?',
            options: [
              'Fusion',
              'Vaporisation',
              'They are equal',
              'It depends on pressure'
            ],
            correctIndex: 1,
            explanation: 'Latent heat of vaporisation (2,260,000 J/kg) is much higher than latent heat of fusion (334,000 J/kg) because more energy is needed to completely separate particles into a gas.',
          ),
          Question(
            id: 'tp_q7',
            question: 'What happens when two negatively charged objects are brought close together?',
            options: [
              'They attract',
              'They repel',
              'Nothing happens',
              'They neutralise'
            ],
            correctIndex: 1,
            explanation: 'Like charges repel each other. Two negative charges will push away from each other.',
          ),
          Question(
            id: 'tp_q8',
            question: 'What is internal energy?',
            options: [
              'Only kinetic energy of particles',
              'Only potential energy of particles',
              'Total kinetic and potential energy of particles',
              'Temperature of a substance'
            ],
            correctIndex: 2,
            explanation: 'Internal energy is the total kinetic energy (from particle movement) and potential energy (from bonds between particles) of all particles in a system.',
          ),
          Question(
            id: 'tp_q9',
            question: 'Why is earthing used?',
            options: [
              'To build up more charge',
              'To safely remove excess charge',
              'To create static electricity',
              'To heat objects'
            ],
            correctIndex: 1,
            explanation: 'Earthing provides a path for excess charge to flow safely to the ground, preventing dangerous build-up of static charge.',
          ),
          Question(
            id: 'tp_q10',
            question: 'In which state of matter are particles furthest apart?',
            options: [
              'Solid',
              'Liquid',
              'Gas',
              'All the same'
            ],
            correctIndex: 2,
            explanation: 'In a gas, particles are far apart and move randomly in all directions, filling their container.',
          ),
        ],
      ),
    ],
    simulations: [
      const PhysicsSimulation(
        id: 'tp_sim_thermal',
        title: 'Heating & Cooling Simulator',
        description: 'Watch particles change state as you heat and cool substances',
        type: SimulationType.thermal,
      ),
      const PhysicsSimulation(
        id: 'tp_sim_static',
        title: 'Static Electricity Simulator',
        description: 'Explore charge transfer and electric forces between objects',
        type: SimulationType.staticElectricity,
      ),
      const PhysicsSimulation(
        id: 'tp_sim_particles',
        title: 'Particle Model',
        description: 'See how particles behave in solids, liquids, and gases',
        type: SimulationType.particles,
      ),
    ],
  );
}
