# frozen_string_literal: true

thermal = Topic.find_by!(name: 'Introduction to Thermal & Quantum Physics')

puts '  - Thermal & Quantum calculations...'

Question.create!(
  topic: thermal,
  content: 'Calculate the energy of a photon with wavelength 500 nm. (h = 6.63 × 10⁻³⁴ J·s, c = 3 × 10⁸ m/s)',
  answer: 'E = hf = hc/λ = (6.63 × 10⁻³⁴ × 3 × 10⁸) / (500 × 10⁻⁹) = 3.98 × 10⁻¹⁹ J',
  points: 2,
  answer_size: 'short',
  question_type: 'calculation',
  answer_label: 'E',
  unit: 'J'
)

Question.create!(
  topic: thermal,
  content: 'A gas expands at constant pressure 2 × 10⁵ Pa from volume 0.1 m³ to 0.3 m³. Calculate the work done by the gas.',
  answer: 'W = PΔV = 2 × 10⁵ × (0.3 - 0.1) = 2 × 10⁵ × 0.2 = 4 × 10⁴ J',
  points: 2,
  answer_size: 'short',
  question_type: 'calculation',
  answer_label: 'W',
  unit: 'J'
)

