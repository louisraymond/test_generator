# frozen_string_literal: true

electronics = Topic.find_by!(name: 'Electronics - Signal Processing')
commons = Source.find_by(name: 'Wikimedia Commons')

puts '  - Electronics diagram labeling...'

Question.create!(
  topic: electronics,
  content: 'Label the MOSFET terminals on the diagram.',
  answer: 'Gate, Source, Drain (positions depend on symbol orientation)',
  points: 2,
  answer_size: 'short',
  question_type: 'diagram_label',
  options: { 'image' => 'placeholder.svg', 'labels' => ['Gate', 'Source', 'Drain'] }
)

Question.create!(
  topic: electronics,
  source: commons,
  source_reference: 'File:MOSFET N Channel symbol.svg',
  content: 'Label the MOSFET terminals on the diagram.',
  answer: 'Gate, Source, Drain',
  points: 2,
  answer_size: 'short',
  question_type: 'diagram_label',
  options: { 'image' => 'MOSFET_N_Channel_symbol.svg', 'labels' => ['Gate', 'Source', 'Drain'] }
)

Question.create!(
  topic: electronics,
  source: commons,
  source_reference: 'File:Mosfet-wn.svg',
  content: 'Identify the channel direction and label terminals for the MOSFET symbol.',
  answer: 'Label: Gate (G), Drain (D), Source (S). Channel arrow indicates n-channel.',
  points: 2,
  answer_size: 'short',
  question_type: 'diagram_label',
  options: { 'image' => 'Mosfet-wn.svg', 'labels' => ['G', 'D', 'S'] }
)

Question.create!(
  topic: electronics,
  source: commons,
  source_reference: 'File:NPN_transistor_symbol_jp.svg',
  content: 'Label the terminals on the NPN transistor symbol.',
  answer: 'Collector (C), Base (B), Emitter (E).',
  points: 2,
  answer_size: 'short',
  question_type: 'diagram_label',
  options: { 'image' => 'NPN_transistor_symbol_jp.svg', 'labels' => ['C', 'B', 'E'] }
)

Question.create!(
  topic: electronics,
  source: commons,
  source_reference: 'File:Transistor_symbol_npn_no_circle.svg',
  content: 'Label the NPN transistor symbol (variant).',
  answer: 'Collector (C), Base (B), Emitter (E).',
  points: 2,
  answer_size: 'short',
  question_type: 'diagram_label',
  options: { 'image' => 'Transistor_symbol_npn_no_circle.svg', 'labels' => ['C', 'B', 'E'] }
)

Question.create!(
  topic: electronics,
  source: commons,
  source_reference: 'File:Op-amp_symbol.svg',
  content: 'Label the op-amp symbol with +, − inputs and output.',
  answer: 'Non-inverting (+), Inverting (−), Output.',
  points: 2,
  answer_size: 'short',
  question_type: 'diagram_label',
  options: { 'image' => 'Op-amp_symbol.svg', 'labels' => ['+', '−', 'Out'] }
)

Question.create!(
  topic: electronics,
  source: commons,
  source_reference: 'File:Op-amp_symbol_simplified.svg',
  content: 'Label the simplified op-amp symbol pins.',
  answer: 'Non-inverting (+), Inverting (−), Output.',
  points: 2,
  answer_size: 'short',
  question_type: 'diagram_label',
  options: { 'image' => 'Op-amp_symbol_simplified.svg', 'labels' => ['+', '−', 'Out'] }
)

Question.create!(
  topic: electronics,
  source: commons,
  source_reference: 'File:Resistor_symbol_America.svg',
  content: 'Identify the symbol and label it with R.',
  answer: 'Resistor (R).',
  points: 1,
  answer_size: 'short',
  question_type: 'diagram_label',
  options: { 'image' => 'Resistor_symbol_America.svg', 'labels' => ['R'] }
)

Question.create!(
  topic: electronics,
  source: commons,
  source_reference: 'File:Resistor_symbol_Europe.svg',
  content: 'Identify the symbol and label it with R.',
  answer: 'Resistor (R).',
  points: 1,
  answer_size: 'short',
  question_type: 'diagram_label',
  options: { 'image' => 'Resistor_symbol_Europe.svg', 'labels' => ['R'] }
)

Question.create!(
  topic: electronics,
  source: commons,
  source_reference: 'File:1st_Order_Lowpass_Filter_RC.svg',
  content: 'Label the RC low-pass filter elements.',
  answer: 'Input (Vin), Resistor (R), Capacitor (C), Output (Vout).',
  points: 3,
  answer_size: 'medium',
  question_type: 'diagram_label',
  options: { 'image' => '1st_Order_Lowpass_Filter_RC.svg', 'labels' => ['Vin', 'R', 'C', 'Vout'] }
)

Question.create!(
  topic: electronics,
  source: commons,
  source_reference: 'File:RC_lowpass_filter.svg',
  content: 'Label the RC low-pass filter diagram.',
  answer: 'Input, R, C, Output.',
  points: 2,
  answer_size: 'short',
  question_type: 'diagram_label',
  options: { 'image' => 'RC_lowpass_filter.svg', 'labels' => ['Vin', 'R', 'C', 'Vout'] }
)

Question.create!(
  topic: electronics,
  source: commons,
  source_reference: 'File:MOSFET N Channel symbol.svg',
  content: 'Label the MOSFET symbol terminals.',
  answer: 'G (Gate), D (Drain), S (Source).',
  points: 2,
  answer_size: 'short',
  question_type: 'diagram_label',
  options: { 'image' => 'MOSFET_N_Channel_symbol.svg', 'labels' => ['G', 'D', 'S'] }
)

Question.create!(
  topic: electronics,
  source: commons,
  source_reference: 'File:Transistor_symbol_npn_no_circle.svg',
  content: 'Label the NPN transistor symbol terminals.',
  answer: 'C (Collector), B (Base), E (Emitter).',
  points: 2,
  answer_size: 'short',
  question_type: 'diagram_label',
  options: { 'image' => 'Transistor_symbol_npn_no_circle.svg', 'labels' => ['C', 'B', 'E'] }
)

Question.create!(
  topic: electronics,
  source: commons,
  source_reference: 'File:Op-amp_symbol.svg',
  content: 'Label the op-amp symbol pins.',
  answer: 'Non-inverting (+), Inverting (−), Output.',
  points: 2,
  answer_size: 'short',
  question_type: 'diagram_label',
  options: { 'image' => 'Op-amp_symbol.svg', 'labels' => ['+', '−', 'Out'], 'markers' => [ { 'x' => 26, 'y' => 35 }, { 'x' => 26, 'y' => 65 }, { 'x' => 75, 'y' => 50 } ] }
)

Question.create!(
  topic: electronics,
  source: commons,
  source_reference: 'File:Resistor_symbol_America.svg',
  content: 'Label this symbol with its schematic letter.',
  answer: 'R (Resistor).',
  points: 1,
  answer_size: 'short',
  question_type: 'diagram_label',
  options: { 'image' => 'Resistor_symbol_America.svg', 'labels' => ['R'] }
)

Question.create!(
  topic: electronics,
  source: commons,
  source_reference: 'File:Op-amp_symbol_simplified.svg',
  content: 'Label the op-amp (simplified) pins.',
  answer: 'Out, +, −',
  points: 2,
  answer_size: 'short',
  question_type: 'diagram_label',
  options: { 'image' => 'Op-amp_symbol_simplified.svg', 'labels' => ['+', '−', 'Out'], 'markers' => [ { 'x' => 26, 'y' => 35 }, { 'x' => 26, 'y' => 65 }, { 'x' => 75, 'y' => 50 } ] }
)

