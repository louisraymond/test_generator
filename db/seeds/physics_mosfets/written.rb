# frozen_string_literal: true

physics = Topic.find_by!(name: 'Physics - MOSFETs & Circuits')
feynman = Source.find_by(name: 'Feynman Lectures on Physics Vol. 2')

puts '  - Physics written questions...'

Question.create!(
  topic: physics,
  source: feynman,
  source_reference: 'Chapter 14, p.237',
  content: 'State and explain the property of MOSFET devices that makes them useful in low power circuits.',
  answer: 'MOSFETs have very high input impedance (essentially infinite at DC) because the gate is insulated from the channel. This means negligible current flows into the gate, resulting in minimal power consumption in the control circuit.',
  points: 2,
  answer_size: 'short',
  question_type: 'written'
)

Question.create!(
  topic: physics,
  content: 'Describe what is meant by amplitude modulation (AM).',
  answer: 'Amplitude modulation is a technique where the amplitude of a high-frequency carrier wave is varied in proportion to the instantaneous amplitude of the modulating signal (usually audio). The frequency of the carrier remains constant.',
  points: 1,
  answer_size: 'short',
  question_type: 'written'
)

Question.create!(
  topic: physics,
  content: 'Explain how a parallel LC resonant circuit can be used as a filter to reduce mains interference at 50 Hz.',
  answer: 'At resonance, a parallel LC circuit presents very high impedance. By tuning L and C values so that the resonant frequency equals 50 Hz, the circuit blocks the interference signal while allowing other frequencies to pass. The high impedance at 50 Hz means the interference voltage is dropped across the LC circuit rather than reaching the output. The quality factor Q determines the sharpness of the filtering.',
  points: 3,
  answer_size: 'medium',
  question_type: 'written'
)

