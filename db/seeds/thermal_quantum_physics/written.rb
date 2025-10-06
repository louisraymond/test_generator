# frozen_string_literal: true

thermal = Topic.find_by!(name: 'Introduction to Thermal & Quantum Physics')
feynman = Source.find_by(name: 'Feynman Lectures on Physics Vol. 2')

puts '  - Thermal & Quantum written questions...'

Question.create!(
  topic: thermal,
  source: feynman,
  source_reference: 'Chapter 41',
  content: 'Explain the concept of wave-particle duality in quantum mechanics.',
  answer: 'Wave-particle duality states that quantum objects (e.g., photons, electrons) exhibit both wave-like properties (interference, diffraction) and particle-like properties (discrete energy packets, localized impacts). The behavior observed depends on the experimental setup - a particle detector sees particles, while an interference pattern reveals wave properties.',
  points: 3,
  answer_size: 'medium',
  question_type: 'written'
)

Question.create!(
  topic: thermal,
  content: 'Describe the first law of thermodynamics and give the equation.',
  answer: 'The first law states that energy cannot be created or destroyed, only converted. For a system: ΔU = Q - W, where ΔU is the change in internal energy, Q is heat added to the system, and W is work done by the system.',
  points: 2,
  answer_size: 'short',
  question_type: 'written'
)

Question.create!(
  topic: thermal,
  content: 'Explain what is meant by blackbody radiation.',
  answer: 'Blackbody radiation is electromagnetic radiation emitted by an ideal absorber (a blackbody) due to its temperature. The spectrum depends only on temperature, not material composition. Real objects approximate this behavior. Blackbody radiation led to the development of quantum theory (Planck\'s law).',
  points: 3,
  answer_size: 'medium',
  question_type: 'written'
)

