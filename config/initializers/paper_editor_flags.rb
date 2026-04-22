# Per-type feature flags for the paper-is-editor (Wave 3).
# Each flag defaults ON in development/test so the redesigned editors
# are exercised by the suite; flip individual flags via ENV in production
# until each type's PR ships.
Rails.application.config.x.paper_editor = ActiveSupport::OrderedOptions.new.tap do |o|
  defaults = {
    mcq:             true,
    cloze:           true,
    written:         true,
    markdown:        true,
    calculation:     true,
    matching:        true,
    ordering:        true,
    ranking:         true,
    diagram_label:   true,
    image_occlusion: true,
    composite:       true,
    code_analysis:   true
  }
  defaults.each do |flag, default_on|
    env_key = "PAPER_EDITOR_#{flag.to_s.upcase}"
    o[flag] = ENV.fetch(env_key, default_on.to_s) == 'true'
  end
end
