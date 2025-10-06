# frozen_string_literal: true

puts 'Creating Thermal & Quantum Physics topic...'

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

