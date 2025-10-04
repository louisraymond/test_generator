# frozen_string_literal: true

ActiveRecord::Base.transaction do
  ExamQuestion.destroy_all
  Exam.destroy_all
  Question.destroy_all
  Source.destroy_all
  Topic.destroy_all

  puts 'Creating topics...'
  physics = Topic.create!(name: 'Physics - MOSFETs & Circuits')
  toc = Topic.create!(name: 'Theory of Constraints')
  programming = Topic.create!(name: 'Ruby on Rails')
  electronics = Topic.create!(name: 'Electronics - Signal Processing')

  puts 'Creating sources...'
  feynman = Source.create!(
    name: 'Feynman Lectures on Physics Vol. 2',
    source_type: 'book',
    notes: 'Classic physics textbook'
  )

  goldratt = Source.create!(
    name: 'The Goal by Eliyahu Goldratt',
    source_type: 'book',
    notes: 'Business novel about TOC'
  )

  rails_guides = Source.create!(
    name: 'Rails Guides',
    source_type: 'documentation',
    notes: 'Official Rails documentation'
  )

  commons = Source.create!(
    name: 'Wikimedia Commons',
    source_type: 'website',
    notes: 'Public domain / Creative Commons images; see individual file pages for license and attribution.'
  )

  puts 'Creating questions...'

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
    topic: physics,
    content: 'Explain how a parallel LC resonant circuit can be used as a filter to reduce mains interference at 50 Hz.',
    answer: 'At resonance, a parallel LC circuit presents very high impedance. By tuning L and C values so that the resonant frequency equals 50 Hz, the circuit blocks the interference signal while allowing other frequencies to pass. The high impedance at 50 Hz means the interference voltage is dropped across the LC circuit rather than reaching the output. The quality factor Q determines the sharpness of the filtering.',
    points: 3,
    answer_size: 'medium',
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
    topic: toc,
    source: goldratt,
    source_reference: 'Chapter 15',
    content: 'Define what is meant by a constraint in the Theory of Constraints.',
    answer: 'A constraint is anything that limits a system from achieving higher performance relative to its goal. It is the weakest link that determines the overall system throughput. In manufacturing, it is typically the resource (machine, process, or policy) with the least capacity relative to demand.',
    points: 2,
    answer_size: 'short',
    question_type: 'written'
  )

  Question.create!(
    topic: toc,
    source: goldratt,
    source_reference: 'Chapter 20',
    content: 'Explain the Five Focusing Steps of the Theory of Constraints.',
    answer: '1. Identify the system constraint. 2. Exploit the constraint to get maximum output without major investment. 3. Subordinate everything else to support the constraint. 4. Elevate the constraint by increasing its capacity if needed. 5. Repeat once the constraint moves to maintain continuous improvement.',
    points: 5,
    answer_size: 'long',
    question_type: 'written'
  )

  Question.create!(
    topic: toc,
    content: 'Explain why local optimization can be harmful to overall system performance in TOC.',
    answer: 'Local optimization maximizes efficiency at non-constraint resources. This creates excess inventory when non-constraints produce faster than the constraint can process, wastes resources on improvements that do not increase throughput, and can starve the constraint if upstream processes optimize batch sizes instead of flow. Only improving the constraint increases system throughput.',
    points: 3,
    answer_size: 'medium',
    question_type: 'written'
  )

  Question.create!(
    topic: programming,
    source: rails_guides,
    source_reference: 'Active Record Basics',
    content: 'Explain the difference between has_many and belongs_to associations in Rails.',
    answer: 'belongs_to defines the relationship from the side that holds the foreign key (the child record). has_many defines the relationship from the referenced side (the parent). For example: a Comment belongs_to :post (comment has post_id), while a Post has_many :comments (post is referenced by multiple comments).',
    points: 2,
    answer_size: 'short',
    question_type: 'written'
  )

  Question.create!(
    topic: programming,
    content: 'Describe the purpose of database migrations in Rails and explain why they are important.',
    answer: 'Migrations are version control for your database schema. They allow you to modify database structure incrementally using Ruby code rather than SQL. They are reversible, reproducible across environments, tracked in version control, database-agnostic, and keep schema changes synchronized across the team.',
    points: 3,
    answer_size: 'medium',
    question_type: 'written'
  )

  Question.create!(
    topic: programming,
    source: rails_guides,
    content: 'Explain what the asset pipeline does in Rails and why it is useful.',
    answer: 'The asset pipeline concatenates, minifies, and fingerprints CSS and JavaScript files. Benefits include fewer HTTP requests (concatenation), smaller file sizes (minification), better caching (fingerprinting), preprocessing support (SCSS, CoffeeScript), and an organized asset structure.',
    points: 3,
    answer_size: 'medium',
    question_type: 'written'
  )

  Question.create!(
    topic: toc,
    content: 'Which of the following best describes the goal of the Theory of Constraints?',
    answer: 'B - To maximize throughput while minimizing inventory and operating expense.',
    points: 1,
    answer_size: 'short',
    question_type: 'multiple_choice',
    options: [
      'To minimize costs across all departments equally',
      'To maximize throughput while minimizing inventory and operating expense',
      'To achieve 100% utilization of all resources',
      'To reduce cycle time at non-constraint resources'
    ]
  )

  Question.create!(
    topic: programming,
    source: rails_guides,
    content: 'In Rails, which method would you use to find a record by its primary key, raising an exception if not found?',
    answer: 'C - Model.find(id)',
    points: 1,
    answer_size: 'short',
    question_type: 'multiple_choice',
    options: [
      'Model.where(id: id).first',
      'Model.find_by(id: id)',
      'Model.find(id)',
      'Model.get(id)'
    ]
  )

  Question.create!(
    topic: physics,
    content: 'Which of the following best describes spaced repetition in learning?',
    answer: 'B - Reviewing material at increasing intervals over time.',
    points: 1,
    answer_size: 'short',
    question_type: 'multiple_choice',
    options: [
      'Studying material once intensively before an exam',
      'Reviewing material at increasing intervals over time',
      'Reading material multiple times in one session',
      'Creating summary notes from textbooks'
    ]
  )

  Question.create!(
    topic: electronics,
    content: 'What is the primary advantage of frequency modulation (FM) over amplitude modulation (AM)?',
    answer: 'C - Better immunity to noise and interference.',
    points: 1,
    answer_size: 'short',
    question_type: 'multiple_choice',
    options: [
      'Requires less bandwidth',
      'Simpler circuit design',
      'Better immunity to noise and interference',
      'Lower transmission power requirements'
    ]
  )

  Question.create!(
    topic: programming,
    content: 'Outline the main steps in the Rails request lifecycle from HTTP request to response.',
    answer: '1. Rack receives the HTTP request and passes it to Rails. 2. The router matches the request to a controller action. 3. The controller runs callbacks, loads data, and executes the action. 4. The action renders a view (or redirects), combining it with the layout. 5. The middleware stack finalizes headers and body before the response is returned to the web server.',
    points: 4,
    answer_size: 'medium',
    question_type: 'written'
  )

  # --- Additional question types and examples ---

  # Matching (electronics)
  Question.create!(
    topic: electronics,
    content: 'Match each unit with its physical quantity.',
    answer: "Ohm → Resistance; Farad → Capacitance; Henry → Inductance",
    points: 3,
    answer_size: 'short',
    question_type: 'matching',
    options: {
      'left' => ['Ohm (Ω)', 'Farad (F)', 'Henry (H)'],
      'right' => ['Inductance', 'Resistance', 'Capacitance']
    }
  )

  # Matching (programming)
  Question.create!(
    topic: programming,
    content: 'Match each Rails component to its responsibility.',
    answer: "Controller → Coordinates request flow; Model → Business/data logic; View → Presentation",
    points: 3,
    answer_size: 'short',
    question_type: 'matching',
    options: {
      'left' => ['Controller', 'Model', 'View'],
      'right' => ['Presentation', 'Business/data logic', 'Coordinates request flow']
    }
  )

  # Cloze (physics)
  Question.create!(
    topic: physics,
    content: 'In a MOSFET, the gate is [[insulated]] from the channel by a thin layer of [[oxide]].',
    answer: 'insulated; oxide',
    points: 2,
    answer_size: 'short',
    question_type: 'cloze'
  )

  # Cloze (TOC)
  Question.create!(
    topic: toc,
    content: 'The Five Focusing Steps begin with [[identify]] the constraint and end with [[repeat]].',
    answer: 'identify; repeat',
    points: 2,
    answer_size: 'short',
    question_type: 'cloze'
  )

  # Ordering (programming)
  Question.create!(
    topic: programming,
    content: 'Place the Rails request lifecycle steps in order.',
    answer: 'Router → Controller → View → Response',
    points: 2,
    answer_size: 'short',
    question_type: 'ordering',
    options: ['Controller', 'View', 'Router', 'Response']
  )

  # Ordering (electronics)
  Question.create!(
    topic: electronics,
    content: 'Order these EM spectrum bands from lowest to highest frequency.',
    answer: 'Radio → Microwave → Infrared → Visible',
    points: 2,
    answer_size: 'short',
    question_type: 'ordering',
    options: ['Visible', 'Infrared', 'Microwave', 'Radio']
  )

  # Ranking (TOC)
  Question.create!(
    topic: toc,
    content: 'Rank the actions by priority when a single bottleneck is the primary constraint.',
    answer: 'Exploit > Subordinate > Elevate (initially)',
    points: 2,
    answer_size: 'short',
    question_type: 'ranking',
    options: ['Elevate', 'Exploit', 'Subordinate']
  )

  # Ranking (programming)
  Question.create!(
    topic: programming,
    content: 'Rank caching layers by typical hit speed (fastest → slowest).',
    answer: 'In‑memory → Redis → Database',
    points: 2,
    answer_size: 'short',
    question_type: 'ranking',
    options: ['Database', 'In-memory', 'Redis']
  )

  # Diagram labeling (electronics)
  Question.create!(
    topic: electronics,
    content: 'Label the MOSFET terminals on the diagram.',
    answer: 'Gate, Source, Drain (positions depend on symbol orientation)',
    points: 2,
    answer_size: 'short',
    question_type: 'diagram_label',
    options: { 'image' => 'placeholder.svg', 'labels' => ['Gate', 'Source', 'Drain'] }
  )

  # Diagram labeling (programming)
  Question.create!(
    topic: programming,
    content: 'Label MVC on the Rails architecture diagram.',
    answer: 'Model, View, Controller',
    points: 2,
    answer_size: 'short',
    question_type: 'diagram_label',
    options: { 'image' => 'placeholder.svg', 'labels' => ['Model', 'View', 'Controller'] }
  )

  # Image occlusion (electronics)
  Question.create!(
    topic: electronics,
    content: 'Identify the hidden component in the circuit diagram.',
    answer: 'Operational amplifier (op‑amp)',
    points: 2,
    answer_size: 'short',
    question_type: 'image_occlusion',
    options: { 'image' => 'placeholder.svg', 'masks' => [ { 'x' => 35, 'y' => 30, 'w' => 25, 'h' => 15 } ] }
  )

  # Image occlusion (physics)
  Question.create!(
    topic: physics,
    content: 'Identify the hidden label on the transistor symbol.',
    answer: 'Gate (for MOSFET diagram)',
    points: 2,
    answer_size: 'short',
    question_type: 'image_occlusion',
    options: { 'image' => 'placeholder.svg', 'masks' => [ { 'x' => 20, 'y' => 55, 'w' => 20, 'h' => 12 } ] }
  )

  # Composite (TOC)
  Question.create!(
    topic: toc,
    content: 'Answer the following about TOC.',
    answer: 'a) Definition of constraint; b) Step 2 is Exploit; c) Example bottleneck: heat‑treating oven',
    points: 5,
    answer_size: 'medium',
    question_type: 'composite',
    options: {
      'parts' => [
        { 'type' => 'written', 'content' => 'a) Define a constraint.', 'answer_size' => 'short', 'points' => 1 },
        { 'type' => 'multiple_choice', 'content' => 'b) What is step 2 of the Five Focusing Steps?', 'options' => ['Identify', 'Exploit', 'Elevate'], 'points' => 2 },
        { 'type' => 'written', 'content' => 'c) Give one example of a typical manufacturing bottleneck.', 'answer_size' => 'short', 'points' => 2 }
      ]
    }
  )

  # Composite (programming)
  Question.create!(
    topic: programming,
    content: 'Rails fundamentals composite question.',
    answer: 'a) MVC responsibilities; b) Strong params; c) id param',
    points: 5,
    answer_size: 'medium',
    question_type: 'composite',
    options: {
      'parts' => [
        { 'type' => 'written', 'content' => 'a) Briefly describe MVC in Rails.', 'answer_size' => 'short', 'points' => 2 },
        { 'type' => 'written', 'content' => 'b) What are strong parameters used for?', 'answer_size' => 'short', 'points' => 2 },
        { 'type' => 'multiple_choice', 'content' => 'c) Which key holds the resource id by convention?', 'options' => ['id', 'uuid', 'key'], 'points' => 1 }
      ]
    }
  )

  # Extra: calculation
  Question.create!(
    topic: electronics,
    content: 'A 10 kΩ resistor carries a current of 2 mA. Calculate the voltage across it.',
    answer: 'V = IR = 0.002 × 10,000 = 20 V',
    points: 2,
    answer_size: 'short',
    question_type: 'calculation',
    answer_label: 'V',
    unit: 'V'
  )

  # Extra: written
  Question.create!(
    topic: programming,
    content: 'Explain the purpose of database indexes and trade‑offs when overusing them.',
    answer: 'Indexes speed up reads at the cost of extra writes and storage. Overuse can slow insert/update performance and increase maintenance overhead.',
    points: 3,
    answer_size: 'medium',
    question_type: 'written'
  )

  # Extra: multiple choice
  Question.create!(
    topic: physics,
    content: 'What does the symbol Ω represent?',
    answer: 'A - Ohms, the unit of electrical resistance',
    points: 1,
    answer_size: 'short',
    question_type: 'multiple_choice',
    options: ['Ohms', 'Webers', 'Siemens', 'Tesla']
  )

  # Extra: written
  Question.create!(
    topic: toc,
    content: 'Why can increasing local efficiency reduce system throughput?',
    answer: 'Non‑constraints can build inventory and starve the true constraint, lowering overall throughput despite local improvements.',
    points: 3,
    answer_size: 'medium',
    question_type: 'written'
  )

  # Extra: calculation
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

  # Extra: multiple choice
  Question.create!(
    topic: electronics,
    content: 'Which component primarily stores energy in a magnetic field?',
    answer: 'B - Inductor',
    points: 1,
    answer_size: 'short',
    question_type: 'multiple_choice',
    options: ['Resistor', 'Inductor', 'Capacitor', 'Diode']
  )

  # --------------------------------------------------
  # Image-based questions (diagram_label / image_occlusion)
  # --------------------------------------------------

  # Diagram labeling: MOSFET terminals
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

  # Diagram labeling: Alternative MOSFET symbol
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

  # Diagram labeling: NPN BJT terminals
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

  # Diagram labeling: NPN transistor, variant
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

  # Diagram labeling: Op-amp pins
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

  # Diagram labeling: Op-amp simplified
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

  # Diagram labeling: Resistor symbol (American)
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

  # Diagram labeling: Resistor symbol (European)
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

  # Diagram labeling: RC low-pass filter
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

  # Diagram labeling: RC low-pass (variant)
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

  # Converted: MOSFET terminals as labeling instead of occlusion
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

  # Converted: NPN terminals as labeling
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

  # Converted: op-amp pins as labeling (with callouts)
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

  # Converted: resistor symbol as labeling
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

  # Image occlusion: RC low-pass symbol areas (two occlusions)
  Question.create!(
    topic: electronics,
    source: commons,
    source_reference: 'File:RC_lowpass_filter.svg',
    content: 'In the RC low-pass diagram, which components are occluded? (1 and 2)',
    answer: '1. Capacitor (C); 2. Resistor (R).',
    points: 2,
    answer_size: 'short',
    question_type: 'image_occlusion',
    options: { 'image' => 'RC_lowpass_filter.svg', 'masks' => [ { 'x' => 35, 'y' => 60, 'w' => 12, 'h' => 12 }, { 'x' => 63, 'y' => 23, 'w' => 10, 'h' => 18 } ] }
  )

  # Converted: op-amp simplified as labeling (with callouts)
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


  puts 'Seed data created successfully!'
  puts "#{Topic.count} topics"
  puts "#{Source.count} sources"
  puts "#{Question.count} questions"
  puts "  - #{Question.where(question_type: 'written').count} written"
  puts "  - #{Question.where(question_type: 'calculation').count} calculation"
  puts "  - #{Question.where(question_type: 'multiple_choice').count} multiple choice"
end
