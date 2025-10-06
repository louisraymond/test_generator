# frozen_string_literal: true

electronics = Topic.find_by!(name: 'Electronics - Signal Processing')
feynman = Source.find_by(name: 'Feynman Lectures on Physics Vol. 2')

puts '  - Electronics written questions...'

Question.create!(
  topic: electronics,
  source: feynman,
  source_reference: 'Chapter 22',
  content: "Explain the meaning of the term 'virtual earth' in an inverting operational amplifier circuit.",
  answer: 'A virtual earth is a point in the circuit that is maintained at approximately 0V (earth potential) by the feedback mechanism of the op-amp, even though it is not directly connected to ground. The inverting input is held at the same voltage as the non-inverting input (0V) due to the high gain of the op-amp.',
  points: 2,
  answer_size: 'short',
  question_type: 'written'
)

Question.create!(
  topic: electronics,
  content: 'Explain why frequency modulation (FM) is not used for commercial radio transmissions in the medium and long wave bands.',
  answer: 'FM requires significantly more bandwidth than AM - typically around 200 kHz per channel compared to about 10 kHz for AM. The medium and long wave bands have limited available spectrum and lower frequencies. At these frequencies, the large bandwidth required for FM would mean very few stations could broadcast. Additionally, FM works better at VHF frequencies for propagation characteristics.',
  points: 3,
  answer_size: 'medium',
  question_type: 'written'
)

Question.create!(
  topic: electronics,
  content: 'Compare the advantages and disadvantages of optical fibre and copper wire for transmitting information over long distances.',
  answer: 'Advantages of optical fibre: Much higher bandwidth capacity, immunity to electromagnetic interference, lower signal attenuation over distance, lighter weight, no electrical conduction (safer), more secure (harder to tap). Disadvantages: More expensive to install, more fragile and requires careful handling, requires specialized equipment for installation and maintenance, cannot carry electrical power. Copper advantages: Lower initial cost, easier to work with and repair, can carry power, existing infrastructure. Copper disadvantages: Limited bandwidth, susceptible to EMI, higher attenuation requiring more repeaters, heavier.',
  points: 6,
  answer_size: 'long',
  question_type: 'written'
)

