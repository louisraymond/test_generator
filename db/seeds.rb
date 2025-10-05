# frozen_string_literal: true

ActiveRecord::Base.transaction do
  ExamQuestion.destroy_all
  Exam.destroy_all
  Question.destroy_all
  Source.destroy_all
  Topic.destroy_all

  puts 'Creating topics...'
  thermal = Topic.create!(
    name: 'Introduction to Thermal & Quantum Physics',
    epigraph_quote: '"The future truths of physical science are to be looked for in the sixth place of decimals."',
    epigraph_attribution: 'William Thomson, the 1st Baron of Kelvin',
    module_aims: [
      'To explore first the macroscopic and then the microscopic contents of heat, temperature and work, including heat transfer by radiation, convection and conduction.',
      'To analyse the zeroth and first Laws of thermodynamics with emphasis on cyclic transformations and adiabatic systems.',
      'To develop kinetic theory explanations for bulk properties of gases in terms of molecular motion.',
      'To study fluid mechanics from a macroscopic viewpoint using only an A-level mathematics background.',
      'To classify crystalline solids by determining lattice structures, packing fractions and bonding types.',
      'To motivate the transition from classical to quantum mechanics through key experiments and introduce fundamental quantum concepts in one dimension.'
    ],
    learning_outcomes: [
      {
        title: 'Heat and Kinetic Theory',
        items: [
          'Be familiar with the model system of an ideal gas and the principles of kinetic theory.',
          'Understand the physical concepts of radiation, convection and conduction.',
          'Apply knowledge of thermal transport and phase changes to calculate heat flow due to radiation, convection and thermal conduction.',
          'Understand the components of the 1st Law of Thermodynamics and apply it to simple systems such as cyclic transformations.',
          'Use kinetic theory to derive expressions for the behaviour of gases such as pressure, molecular kinetic energies, root-mean-square speeds, mean free path and collision cross-section.',
          'Be familiar with the principles of equipartition of energy and use these ideas to calculate the specific heat capacities of monatomic and polyatomic gases.',
          'Understand the concept of a distribution function and apply this to the speeds of molecules.'
        ]
      },
      {
        title: 'Fluids',
        items: [
          'Use Archimedes Principle and pressure variation in fluids in elementary hydrostatic problems.',
          'Apply Bernoulli\'s equation to simple applications such as the Venturi metre.'
        ]
      },
      {
        title: 'The Solid State',
        items: [
          'Describe crystal structures in terms of the space lattice plus basis and be familiar with cubic and hexagonal crystal structures.',
          'Determine the nearest neighbour distance and packing fraction for the cubic systems.',
          'Describe the different types of defects and dislocations that result from disorder in a crystal.',
          'Understand the origin of the interatomic forces in solids and distinguish between ionic, covalent, molecular (van der Waals), metallic and hydrogen bonding.'
        ]
      },
      {
        title: 'Quantum Physics',
        items: [
          'Describe experimental evidence that demonstrates the particle properties of electromagnetic radiation ([[Photoelectric effect]] and [[Compton scattering]]) and the wave properties of particles ([[Davisson and Germer experiment]]).',
          'Derive the [[Compton scattering]] formula, recall the photoelectric effect equation and use them to solve quantitative problems.',
          'State, explain and utilise the energy and momentum forms of the [[Heisenberg Uncertainty Principle|Uncertainty Principle]].',
          'Explain isotopes, isotones and isobars in nuclei and identify examples.',
          'Describe the [[Rutherford scattering]] experiment and calculate the distance of closest approach for head-on nuclear collisions.',
          'Explain the origin of [[atomic emission and absorption spectra]].',
          'Discuss evidence for quantisation in atoms (e.g. line spectra, [[Franck-Hertz experiment]]).',
          'Explain the origins of the hydrogen emission series and describe the [[Bohr model]] and its postulates.',
          'Derive the Rydberg equation with the Bohr model, use it to predict transition wavelengths and compute radii and energies for hydrogen-like atoms.',
          'Explain the effect of finite nuclear mass on Bohr model predictions using the modified Rydberg constant.',
          'Discuss the limitations of the Bohr model for multi-electron atoms and atomic stability.',
          'Outline the Schrödinger quantum approach, quote the time-independent Schrödinger equation and apply boundary conditions to one-dimensional systems.',
          'Solve the TISE for simple 1D potentials, normalise wavefunctions and compute transmission and reflection coefficients for steps and barriers.',
          'Explain the significance of [[Operator (Physics)|operators]], list operators for position, momentum and energy, and interpret eigenvalues as measurement outcomes.',
          'Utilise the hydrogen atom operator to show that selected solutions are eigenfunctions.'
        ]
      }
    ],
    syllabus_outline: [
      {
        title: 'Term 1: Heat and Matter',
        items: [
          'Heat: temperature scales, heat flow, specific heat capacity and phase changes; the "zeroth" law of thermodynamics; defining temperature via ideal gases.',
          'Radiative transfer: Wien displacement Law, spectral emissivity, Kirchoff\'s Law, Planck\'s Law and Stefan\'s Law with applications to the sun and hot bodies ([[Black Body Radiation & "The UV Catastrophe"]]).',
          'Conduction: steady state heat conduction in simple composites and gases.',
          'Convection: defining the convective heat transfer coefficient and the factors controlling it.',
          'First Law of Thermodynamics: linking work and heat, cyclic transformations and adiabatic processes.',
          'Kinetic theory foundations: ideal gas assumptions, molecular impacts on surfaces, derivation of pressure, equipartition, heat capacity breakdown of classical theory, Maxwell speed distribution, collision probability and mean free path.',
          'Fluid statics: Archimedes Principle and pressure gradients in hydrostatics.',
          'Fluid dynamics: Bernoulli\'s equation and classic applications including the Venturi metre.',
          'Bonding and structure: interatomic forces, bonding classifications and common crystal structures with packing fractions.'
        ]
      },
      {
        title: 'Term 2: Introduction to Quantum Physics',
        items: [
          'Particle properties of radiation and light as quanta: [[Photoelectric effect]], [[Compton scattering]].',
          'Dual nature of light and matter: summary discussions, [[Double Slit Experiment]], [[de Broglie\'s postulate]], [[Davisson and Germer experiment]].',
          'Wave-particle duality reinforcement and [[Heisenberg Uncertainty Principle]] in space, time, momentum and energy domains.',
          'Atomic structure and constituents: scale, mass distribution, isotopes and isotones.',
          'Scattering experiments: [[Rutherford scattering]] and distance of closest approach.',
          'Atomic stability and quantisation: [[Atomic spectra]], hydrogen emission series, [[Franck-Hertz experiment]].',
          'Bohr model and corrections: postulates, series predictions, finite nuclear mass adjustments, [[Failure of classical mechanics]] for atomic phenomena.',
          'Quantum mechanics foundations: [[The Schrödinger equation]], main [[Postulates of quantum mechanics]], stationary states, boundary conditions and probability interpretation.',
          'Applications: wavefunctions for free particles, [[Wave-particle duality]], [[Youngs two slit experiment]], expectation values, infinite and finite square wells, tunnelling and 1D Coulomb potentials.'
        ]
      }
    ],
    reference_links: [
      'Photoelectric effect',
      'Compton scattering',
      'Davisson and Germer experiment',
      'Heisenberg Uncertainty Principle',
      'Rutherford scattering',
      'Atomic emission and absorption spectra',
      'Franck-Hertz experiment',
      'Bohr model',
      'Black Body Radiation & "The UV Catastrophe"',
      'Double Slit Experiment',
      'de Broglie\'s postulate',
      'Postulates of quantum mechanics',
      'Wave-particle duality',
      'Youngs two slit experiment',
      'Operator (Physics)',
      'Failure of classical mechanics',
      'The Schrödinger equation'
    ]
  )

  thermal.replace_learning_objectives!(thermal.learning_outcome_sections)

  Topic.create!(name: 'Photoelectric Effect', parent_topic: thermal)
  Topic.create!(name: 'Compton Scattering', parent_topic: thermal)

  physics = Topic.create!(name: 'Physics - MOSFETs & Circuits')
  toc = Topic.create!(name: 'Theory of Constraints')
  programming = Topic.create!(name: 'Ruby on Rails')
  electronics = Topic.create!(name: 'Electronics - Signal Processing')
  codebase = Topic.create!(name: 'Codebase - Exam Generator')

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

  project_docs = Source.create!(
    name: 'Project Documentation',
    source_type: 'internal',
    notes: 'docs/app_exam.md in this repository'
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

  # Codebase quiz (markdown)
  Question.create!(
    topic: codebase,
    source: project_docs,
    source_reference: 'docs/app_exam.md',
    content: <<~'MD',
      Explain how strong parameters and type casting are applied before calling the service, and why `to_h` is not called on unpermitted params.

      ```ruby
      # app/controllers/exams_controller.rb:create
      p = exam_params
      title     = p[:title].presence || 'Practice Exam'
      topic_ids = Array(p[:topic_ids]).reject(&:blank?)
      count     = p[:question_count].to_i
      types = Array(p[:question_types]).reject(&:blank?)
      types &= Question::QUESTION_TYPES
      raw_weights_params = p[:topic_weights]
      raw_weights = raw_weights_params.is_a?(ActionController::Parameters) ? raw_weights_params.to_h : (raw_weights_params || {})
      weights = raw_weights
                .slice(*topic_ids.map(&:to_s))
                .transform_values { |v| v.to_s.strip }
                .reject { |_k, v| v.blank? || v.to_f <= 0 }
                .transform_values(&:to_f)
      ```
    MD
    answer: 'Strong params whitelist; intersection with known types prevents invalid input; Rails forbids to_h on unpermitted params; weights are sanitized and cast to floats.',
    points: 3,
    answer_size: 'medium',
    question_type: 'markdown'
  )

  Question.create!(
    topic: codebase,
    source: project_docs,
    source_reference: 'docs/app_exam.md',
    content: <<~'MD',
      Describe how weighted selection and repeats interact in the service. Include trade‑offs of `ORDER BY RANDOM()`.

      ```ruby
      # app/services/exam_builder.rb:35–50
      final_count = allow_repeats ? requested : [requested, available].min
      selected = if topic_weights.present?
                   allocate_by_weights(scope, topic_ids, topic_weights, [final_count, available].min)
                 else
                   scope.order(Arel.sql('RANDOM()')).limit([final_count, available].min).to_a
                 end
      if allow_repeats && selected.size < final_count
        needed = final_count - selected.size
        selected += selected.cycle.take(needed)
      end
      ```
    MD
    answer: 'Weights apportion counts by topic; ORDER BY RANDOM() samples simply but can be slow; repeats pad to target by cycling.',
    points: 3,
    answer_size: 'medium',
    question_type: 'markdown'
  )

  Question.create!(
    topic: codebase,
    source: project_docs,
    source_reference: 'docs/app_exam.md',
    content: <<~'MD',
      Explain the matching UI layout and why it improves clarity over checkboxes.

      ```erb
      <!-- app/views/questions/_matching.html.erb -->
      <div class="matching-table">
        <% left.each_with_index do |l, i| %>
          <div class="matching-row">
            <div class="match-left"><%= l %></div>
            <div class="match-line"></div>
            <div class="match-right"><strong><%= right[i] %></strong></div>
          </div>
        <% end %>
      </div>
      ```
    MD
    answer: 'Two columns with a connecting line create an obvious affordance and uniform alignment; better than checkbox guessing.',
    points: 2,
    answer_size: 'short',
    question_type: 'markdown'
  )

  Question.create!(
    topic: codebase,
    source: project_docs,
    source_reference: 'docs/app_exam.md',
    content: <<~'MD',
      How do diagram labeling markers affect rendering and the number of blanks?

      ```erb
      <!-- app/views/questions/_diagram_label.html.erb -->
      <% markers.each_with_index do |m, i| %>
        <div class="callout" style="left:<%= m['x'] %>%; top:<%= m['y'] %>%">
          <span class="callout-dot"><%= i + 1 %></span>
        </div>
      <% end %>
      ```
    MD
    answer: 'Markers put visible numbered dots on the image and define the number of blanks; without markers, label count or default is used.',
    points: 2,
    answer_size: 'short',
    question_type: 'markdown'
  )

  Question.create!(
    topic: codebase,
    source: project_docs,
    source_reference: 'docs/app_exam.md',
    content: <<~'MD',
      Explain the CSS used to stabilize ruled line thickness and cadence in PDFs.

      ```css
      .answer-lines {
        background-image: repeating-linear-gradient(
          to bottom,
          rgba(0,0,0,0) 0,
          rgba(0,0,0,0) 6.65mm,
          rgba(0,0,0,0.26) 6.65mm,
          rgba(0,0,0,0.26) 7mm
        );
        background-size: 100% 7mm;
      }
      ```
    MD
    answer: 'Anchoring repeat to 7mm controls cadence; slightly thicker stripe improves consistency across print engines.',
    points: 2,
    answer_size: 'short',
    question_type: 'markdown'
  )

  Question.create!(
    topic: codebase,
    source: project_docs,
    source_reference: 'docs/app_exam.md',
    content: <<~'MD',
      What options are set for PDF generation and why?

      ```ruby
      pdf = Grover.new(
        html,
        base_url: request.base_url,
        emulate_media: 'print',
        print_background: true,
        prefer_css_page_size: true
      ).to_pdf
      ```
    MD
    answer: 'Apply print CSS; include backgrounds (ruled lines); obey CSS page size; base_url for asset resolution.',
    points: 2,
    answer_size: 'short',
    question_type: 'markdown'
  )

  Question.create!(
    topic: codebase,
    source: project_docs,
    source_reference: 'docs/app_exam.md',
    content: <<~'MD',
      Show the routes for exams and questions and describe each endpoint.

      ```ruby
      root 'exams#new'
      resources :exams, only: %i[new create show] do
        member { get :marking_scheme }
      end
      resources :questions, only: [:index]
      ```
    MD
    answer: 'Root form; create builds exam; show renders HTML/PDF; marking_scheme returns marking PDF; questions#index is a dev browser.',
    points: 2,
    answer_size: 'short',
    question_type: 'markdown'
  )

  Question.create!(
    topic: codebase,
    source: project_docs,
    source_reference: 'docs/app_exam.md',
    content: <<~'MD',
      Why is the markdown renderer intentionally minimal and sanitized? What tags/attributes are allowed?

      ```ruby
      sanitize(html, tags: %w[p br pre code strong em a ul ol li span], attributes: %w[class href])
      ```
    MD
    answer: 'Safety and portability for print/HTML; only safe tags and attributes are allowed to avoid XSS.',
    points: 2,
    answer_size: 'short',
    question_type: 'markdown'
  )

  # More codebase markdown questions (~20)
  Question.create!(
    topic: codebase,
    source: project_docs,
    source_reference: 'docs/app_exam.md',
    content: <<~'MD',
      Show the `QUESTION_TYPES` constant and explain why inclusion validation helps controllers and seeds catch mistakes early.

      ```ruby
      # app/models/question.rb
      QUESTION_TYPES = %w[
        written multiple_choice calculation matching cloze ordering ranking
        diagram_label image_occlusion composite markdown
      ].freeze
      ```
    MD
    answer: 'Single source of truth for allowed types; controllers intersect with this list; inclusion validation prevents invalid data.',
    points: 2,
    answer_size: 'short',
    question_type: 'markdown'
  )

  Question.create!(
    topic: codebase,
    source: project_docs,
    source_reference: 'docs/app_exam.md',
    content: <<~'MD',
      Explain the conditional validation for `multiple_choice` options and why it is placed in the model rather than controllers.

      ```ruby
      # app/models/question.rb (excerpt)
      validate :options_requirements_for_type
      def options_requirements_for_type
        case question_type
        when 'multiple_choice'
          errors.add(:options, 'must be a non-empty array') unless options.is_a?(Array) && options.any?
        end
      end
      ```
    MD
    answer: 'Model-level invariant ensures any creation path (web/seed/console) enforces shape; controller-only checks are bypassable.',
    points: 3,
    answer_size: 'medium',
    question_type: 'markdown'
  )

  Question.create!(
    topic: codebase,
    source: project_docs,
    source_reference: 'docs/app_exam.md',
    content: <<~'MD',
      How does the index on `(exam_id, position)` affect ordering guarantees? What happens if two rows share the same position?

      ```ruby
      # db/migrate/20251003210938_create_exam_questions.rb
      add_index :exam_questions, [:exam_id, :position]
      ```
    MD
    answer: 'Index supports order queries; later migration makes it unique to prevent duplicates, ensuring a stable ordering.',
    points: 2,
    answer_size: 'short',
    question_type: 'markdown'
  )

  Question.create!(
    topic: codebase,
    source: project_docs,
    source_reference: 'docs/app_exam.md',
    content: <<~'MD',
      Detail the change that allowed repeated questions in an exam and why the unique index was removed.

      ```ruby
      # db/migrate/20251004000500_allow_repeated_questions_in_exam.rb
      remove_index :exam_questions, name: 'index_exam_questions_on_exam_id_and_question_id'
      ```
    MD
    answer: 'Removing the uniqueness constraint on (exam_id, question_id) permits intentional repeats for longer quizzes.',
    points: 2,
    answer_size: 'short',
    question_type: 'markdown'
  )

  Question.create!(
    topic: codebase,
    source: project_docs,
    source_reference: 'docs/app_exam.md',
    content: <<~'MD',
      Explain why `questions.options` moved to a DB default of `[]` and `NOT NULL`, in addition to the model default.

      ```ruby
      # db/migrate/20251003223000_harden_db_constraints.rb
      change_column_default :questions, :options, from: nil, to: []
      execute "UPDATE questions SET options = '[]'::jsonb WHERE options IS NULL"
      change_column_null :questions, :options, false
      ```
    MD
    answer: 'Guards against NULLs from non-AR paths and simplifies JSON handling; DB becomes source of truth for default.',
    points: 3,
    answer_size: 'medium',
    question_type: 'markdown'
  )

  Question.create!(
    topic: codebase,
    source: project_docs,
    source_reference: 'docs/app_exam.md',
    content: <<~'MD',
      What does `base_url: request.base_url` accomplish for Grover when generating PDFs?
    MD
    answer: 'Makes relative asset and link paths resolvable by the headless browser; required for embedded CSS/images.',
    points: 2,
    answer_size: 'short',
    question_type: 'markdown'
  )

  Question.create!(
    topic: codebase,
    source: project_docs,
    source_reference: 'docs/app_exam.md',
    content: <<~'MD',
      Show the helper that embeds images as data URIs and explain why this is robust for PDF generation.

      ```ruby
      # app/helpers/asset_embed_helper.rb (excerpt)
      def embedded_image_tag(path, alt: '', **html_options)
        file_path = Rails.root.join('app','assets','images', path)
        if File.file?(file_path)
          mime = Rack::Mime.mime_type(File.extname(file_path))
          data = Base64.strict_encode64(File.binread(file_path))
          image_tag("data:#{mime};base64,#{data}", alt: alt, **html_options)
        else
          image_tag(asset_path(path), alt: alt, **html_options)
        end
      end
      ```
    MD
    answer: 'Avoids network fetches inside headless Chrome; PDFs become self-contained; fallback to asset pipeline when file missing.',
    points: 3,
    answer_size: 'medium',
    question_type: 'markdown'
  )

  Question.create!(
    topic: codebase,
    source: project_docs,
    source_reference: 'docs/app_exam.md',
    content: <<~'MD',
      Why is exam creation wrapped in a transaction in `ExamBuilder`? Provide a failure scenario it protects against.
    MD
    answer: 'Ensures exam and all exam_questions are created atomically; protects against partial exams on validation or DB errors.',
    points: 2,
    answer_size: 'short',
    question_type: 'markdown'
  )

  Question.create!(
    topic: codebase,
    source: project_docs,
    source_reference: 'docs/app_exam.md',
    content: <<~'MD',
      What exceptions can the builder raise and how should the controller surface them to the user?
    MD
    answer: 'MissingTopicsError when no topics selected; NotEnoughQuestionsError when not enough items; controller rescues and flashes alert.',
    points: 2,
    answer_size: 'short',
    question_type: 'markdown'
  )

  Question.create!(
    topic: codebase,
    source: project_docs,
    source_reference: 'docs/app_exam.md',
    content: <<~'MD',
      Show how `questions#index` filters by topic, source, and type, and describe why it is capped to 200.

      ```ruby
      # app/controllers/questions_controller.rb#index (excerpt)
      scope = Question.includes(:topic, :source)
      scope = scope.where(topic_id: params[:topic_id]) if params[:topic_id].present?
      scope = scope.where(source_id: params[:source_id]) if params[:source_id].present?
      scope = scope.where(question_type: params[:question_type]) if params[:question_type].present?
      @questions = scope.order(created_at: :desc).limit(200)
      ```
    MD
    answer: 'Simple browse/debug tool; limit prevents huge result sets in dev preview.',
    points: 2,
    answer_size: 'short',
    question_type: 'markdown'
  )

  Question.create!(
    topic: codebase,
    source: project_docs,
    source_reference: 'docs/app_exam.md',
    content: <<~'MD',
      Explain the MC layout grid and why a grid is more robust than floats.

      ```css
      .mc-option {
        display: grid;
        grid-template-columns: 7mm 7mm auto;
        column-gap: 4mm; align-items: center;
      }
      ```
    MD
    answer: 'Grid guarantees alignment of box, letter, and text, even when labels wrap; avoids float overlap/clearfix issues.',
    points: 2,
    answer_size: 'short',
    question_type: 'markdown'
  )

  Question.create!(
    topic: codebase,
    source: project_docs,
    source_reference: 'docs/app_exam.md',
    content: <<~MD,
      Why did we change the A4 screen container from fixed `height` to `min-height`?
    MD
    answer: 'Fixed height clipped overflow to one page; min-height lets content grow naturally while preserving A4 width preview.',
    points: 2,
    answer_size: 'short',
    question_type: 'markdown'
  )

  Question.create!(
    topic: codebase,
    source: project_docs,
    source_reference: 'docs/app_exam.md',
    content: <<~MD,
      Show how the exam form preserves state on validation failure and why `render :new` is preferable to redirect in this case.
    MD
    answer: 'Controller rescues builder errors and calls render :new with flash.now; fields use params to repopulate; redirect would lose state.',
    points: 2,
    answer_size: 'short',
    question_type: 'markdown'
  )

  Question.create!(
    topic: codebase,
    source: project_docs,
    source_reference: 'docs/app_exam.md',
    content: <<~MD,
      Why is `exam_questions.position` 1‑based in creation? What display or ordering benefits does it have?
    MD
    answer: 'Matches user-facing numbering and simplifies ORDER BY position ASC without translating 0-based indexes.',
    points: 1,
    answer_size: 'short',
    question_type: 'markdown'
  )

  Question.create!(
    topic: codebase,
    source: project_docs,
    source_reference: 'docs/app_exam.md',
    content: <<~MD,
      Where is the RSpec configuration included and how are factories mixed in?

      ```ruby
      # spec/rails_helper.rb (excerpt)
      config.include FactoryBot::Syntax::Methods
      ```
    MD
    answer: 'In rails_helper; FactoryBot methods are available without prefix, simplifying test code.',
    points: 1,
    answer_size: 'short',
    question_type: 'markdown'
  )

  Question.create!(
    topic: codebase,
    source: project_docs,
    source_reference: 'docs/app_exam.md',
    content: <<~MD,
      In the request spec for exam generation, how is topic scoping verified?

      ```ruby
      # spec/requests/exams_spec.rb (excerpt)
      expect(Exam.last.questions.pluck(:topic_id).uniq).to eq([topic.id])
      ```
    MD
    answer: 'Ensures all selected questions belong to the chosen topic; guards against leakage across topics.',
    points: 1,
    answer_size: 'short',
    question_type: 'markdown'
  )

  Question.create!(
    topic: codebase,
    source: project_docs,
    source_reference: 'docs/app_exam.md',
    content: <<~MD,
      For diagram questions, why are images kept as SVGs instead of raster formats where possible?
    MD
    answer: 'SVGs scale crisply to print and screen without blurring; smaller payloads for line art; ideal for symbols and schematics.',
    points: 1,
    answer_size: 'short',
    question_type: 'markdown'
  )

  Question.create!(
    topic: codebase,
    source: project_docs,
    source_reference: 'docs/app_exam.md',
    content: <<~MD,
      Describe how the `diagram_label` blank count is determined when both `labels` and `markers` are present.
    MD
    answer: 'Marker count wins (ensures parity with on‑image callouts); falls back to labels count, then to a default.',
    points: 1,
    answer_size: 'short',
    question_type: 'markdown'
  )

  Question.create!(
    topic: codebase,
    source: project_docs,
    source_reference: 'docs/app_exam.md',
    content: <<~MD,
      Explain why `.marks` was toned down and how that helps the visual hierarchy on paper.
    MD
    answer: 'Marks remain visible but stop competing with the prompt; reduces noise in right-aligned header.',
    points: 1,
    answer_size: 'short',
    question_type: 'markdown'
  )

  Question.create!(
    topic: codebase,
    source: project_docs,
    source_reference: 'docs/app_exam.md',
    content: <<~MD,
      Show how the form allows topic weighting and explain what happens if all weights are blank.
    MD
    answer: 'Weights are optional; if none provided or all blank/zero, equal distribution is assumed across selected topics.',
    points: 2,
    answer_size: 'short',
    question_type: 'markdown'
  )

  Question.create!(
    topic: codebase,
    source: project_docs,
    source_reference: 'docs/app_exam.md',
    content: <<~MD,
      Why do we prefer `Arel.sql('RANDOM()')` here instead of passing a raw string?
    MD
    answer: 'Signals intentional SQL usage to Rails to avoid automatic quoting and silence safety warnings.',
    points: 1,
    answer_size: 'short',
    question_type: 'markdown'
  )

  Question.create!(
    topic: codebase,
    source: project_docs,
    source_reference: 'docs/app_exam.md',
    content: <<~MD,
      What does `prefer_css_page_size: true` change in Grover’s PDF output compared to default page sizing?
    MD
    answer: 'Instructs the renderer to respect CSS @page sizes/margins (A4), not the browser default page size.',
    points: 1,
    answer_size: 'short',
    question_type: 'markdown'
  )



  puts 'Seed data created successfully!'
  puts "#{Topic.count} topics"
  puts "#{Source.count} sources"
  puts "#{Question.count} questions"
  puts "  - #{Question.where(question_type: 'written').count} written"
  puts "  - #{Question.where(question_type: 'calculation').count} calculation"
  puts "  - #{Question.where(question_type: 'multiple_choice').count} multiple choice"
end
