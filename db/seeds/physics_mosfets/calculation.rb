# frozen_string_literal: true

physics = Topic.find_by!(name: 'Physics - MOSFETs & Circuits')
feynman = Source.find_by(name: 'Feynman Lectures on Physics Vol. 2')

puts '  - Physics calculations...'

Question.create!(
  topic: physics,
  source: feynman,
  source_reference: 'Chapter 14, Example 3',
  content: 'A MOSFET circuit has a threshold voltage (Vth) of 2.4 V. The gate is connected to a 12V supply through a potential divider consisting of a 1 MOhm resistor and the resistance of water between two copper strips. Calculate the resistance of the water when the MOSFET just turns on.',
  answer: 'Using a potential divider: Vgate = 12 * Rwater / (Rwater + 1 MOhm). When the MOSFET turns on, Vgate equals Vth (2.4 V). Therefore: 2.4 = 12 * Rwater / (Rwater + 1). Solving: 2.4(Rwater + 1) = 12Rwater, 2.4Rwater + 2.4 = 12Rwater, 2.4 = 9.6Rwater, so Rwater = 0.25 MOhm.',
  points: 3,
  answer_size: 'medium',
  question_type: 'calculation',
  answer_label: 'resistance',
  unit: 'MOhm'
)

Question.create!(
  topic: physics,
  content: 'An inductor of 2.0 H is used in a parallel LC resonant circuit designed to filter out 50 Hz mains interference. Calculate the required capacitance.',
  answer: 'Using the resonance formula f0 = 1/(2 * pi * sqrt(L * C)). Rearranging gives C = 1/(4 * pi^2 * f0^2 * L) = 1/(4 * pi^2 * 50^2 * 2.0), which is approximately 5.07 microfarads.',
  points: 2,
  answer_size: 'short',
  question_type: 'calculation',
  answer_label: 'capacitance',
  unit: 'microfarads'
)

Question.create!(
  topic: physics,
  content: 'A temperature sensor produces 10 mV per degree Celsius, with 0 mV at 0 degrees. It feeds an inverting amplifier with Ri = 22 kOhm and Rf = 270 kOhm. Calculate the output voltage when the sensor reads 50 degrees Celsius.',
  answer: 'Sensor voltage at 50 degrees: Vin = 50 * 10 mV = 0.5 V. For an inverting amplifier: Vout = -(Rf/Ri) * Vin = -(270/22) * 0.5, which is approximately -6.14 V.',
  points: 2,
  answer_size: 'short',
  question_type: 'calculation',
  answer_label: 'Vout',
  unit: 'V'
)

Question.create!(
  topic: physics,
  content: 'A capacitor of 10 μF is charged to 5 V. How much energy is stored?',
  answer: 'E = 1/2 C V^2 = 0.5 × 10e‑6 × 25 = 125 μJ',
  points: 2,
  answer_size: 'short',
  question_type: 'calculation',
  answer_label: 'E',
  unit: 'μJ'
)

