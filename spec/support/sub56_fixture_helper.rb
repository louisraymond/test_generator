# frozen_string_literal: true

# Sub-56 system specs need rendered DOM that simulates sub-2 (toolbar) and
# sub-55 (module cards with data-mod-name / data-cat-name / data-lo-text).
# Those issues haven't landed yet, so this helper builds a self-contained
# fixture by:
#   1. Visiting a page that loads the importmap + Stimulus controllers
#      (any existing page works — `/topics` is fine).
#   2. Injecting a fixture HTML string into the body via execute_script.
#   3. Letting Stimulus's MutationObserver pick up the new `data-controller`
#      attributes and connect topic-search + topic-view automatically.
#
# Each top-level helper method maps to one rendering shape used by specs.
module Sub56FixtureHelper
  def visit_sub56_fixture(topic_id: 12_345, modules:, query: nil, view: 'modules')
    visit topics_path
    # Wait until the page is JS-ready (Stimulus loaded).
    expect(page).to have_css('body')
    page.execute_script(<<~JS, build_fixture_html(topic_id: topic_id, modules: modules))
      const html = arguments[0];
      const wrapper = document.createElement('div');
      wrapper.innerHTML = html;
      document.body.innerHTML = '';
      document.body.appendChild(wrapper.firstElementChild);
    JS
    # Give Stimulus a tick to wire up.
    page.has_css?('[data-controller~="topic-search"]', wait: 2)
    page.has_css?('[data-controller~="topic-view"]', wait: 2)
  end

  def build_fixture_html(topic_id:, modules:)
    modules_html = modules.each_with_index.map { |mod, mod_idx| build_module_card(mod, mod_idx) }.join("\n")
    categories_pane = build_categories_pane(modules)
    outcomes_pane = build_outcomes_flat_pane(modules)

    <<~HTML
      <div class="topic-detail premium-page-wrapper"
           data-controller="topic-search topic-view"
           data-topic-view-topic-id-value="#{topic_id}">
        <div class="topic-detail__toolbar">
          <label for="search-outcomes" class="topic-detail__visually-hidden">Search outcomes</label>
          <input type="search"
                 id="search-outcomes"
                 placeholder="Search outcomes"
                 data-topic-search-target="input"
                 data-action="input->topic-search#filter keydown.esc->topic-search#clear" />

          <div role="tablist" class="topic-detail__view-pills">
            <button role="tab" aria-selected="true" data-topic-view-target="tab"
                    data-view="modules" data-action="click->topic-view#selectView">Modules</button>
            <button role="tab" aria-selected="false" data-topic-view-target="tab"
                    data-view="categories" data-action="click->topic-view#selectView">Categories</button>
            <button role="tab" aria-selected="false" data-topic-view-target="tab"
                    data-view="outcomes" data-action="click->topic-view#selectView">Outcomes</button>
          </div>

          <div class="topic-detail__visually-hidden"
               role="status"
               aria-live="polite"
               data-topic-search-target="liveRegion"></div>
        </div>

        <div class="topic-detail__search-empty"
             data-topic-search-target="emptyState"
             hidden>
          No outcomes match "<span data-search-empty-query></span>".
          <button type="button"
                  class="topic-detail__search-empty__clear"
                  data-action="click->topic-search#clear">
            Clear search
          </button>
        </div>

        <section class="topic-detail__view topic-detail__view--modules"
                 data-topic-view-target="pane"
                 data-view="modules">
          #{modules_html}
        </section>

        #{categories_pane}
        #{outcomes_pane}

        <!-- Sub-54 heat-map cells (simulated) -->
        <div class="topic-detail__heatmap">
          #{build_heatmap_cells(modules)}
        </div>
      </div>
    HTML
  end

  # mod = { name:, categories: [{ name:, los: [{ id:, text:, nq: 0 }] }] }
  def build_module_card(mod, mod_idx)
    cats_html = mod[:categories].map do |cat|
      los = cat[:los].map do |lo|
        <<~LO
          <div class="topic-detail__module-card__lo lo-item"
               data-lo-id="#{lo[:id]}"
               data-lo-text="#{lo[:text]}">
            <span class="lo-item__text">#{lo[:text]}</span>
          </div>
        LO
      end.join

      <<~CAT
        <div class="topic-detail__module-card__category" data-cat-name="#{cat[:name]}">
          <h4>#{cat[:name]}</h4>
          #{los}
        </div>
      CAT
    end.join

    <<~MOD
      <div class="topic-detail__module-card module-card"
           data-mod-name="#{mod[:name]}"
           data-module-idx="#{mod_idx + 1}">
        <div class="topic-detail__module-card__header">
          <h3>#{mod[:name]}</h3>
          <span class="topic-detail__module-card__match-count"></span>
        </div>
        <div class="topic-detail__module-card__body">
          #{cats_html}
        </div>
      </div>
    MOD
  end

  def build_categories_pane(modules)
    rows_by_cat = Hash.new { |h, k| h[k] = [] }
    modules.each_with_index do |mod, mod_idx|
      mod[:categories].each do |cat|
        cat[:los].each { |lo| rows_by_cat[cat[:name]] << { lo: lo, mod_idx: mod_idx + 1 } }
      end
    end

    sections = rows_by_cat.sort_by { |k, _| k.to_s.downcase }.map do |cat_name, rows|
      lis = rows.map do |row|
        <<~LI
          <li class="topic-detail__lo-row"
              data-lo-id="#{row[:lo][:id]}"
              data-lo-text="#{row[:lo][:text]}">
            <span class="topic-detail__m-tag mono">M#{row[:mod_idx].to_s.rjust(2, '0')}</span>
            <span class="topic-detail__lo-text">#{row[:lo][:text]}</span>
          </li>
        LI
      end.join

      <<~SEC
        <article class="topic-detail__category-section" data-cat-name="#{cat_name}">
          <h3>#{cat_name}</h3>
          <ul class="topic-detail__category-section__list">#{lis}</ul>
        </article>
      SEC
    end.join

    <<~PANE
      <section class="topic-detail__view topic-detail__view--categories"
               data-topic-view-target="pane"
               data-view="categories"
               hidden>
        #{sections}
      </section>
    PANE
  end

  def build_outcomes_flat_pane(modules)
    rows = []
    topic_order = 0
    modules.each_with_index do |mod, mod_idx|
      mod[:categories].each do |cat|
        cat[:los].each do |lo|
          rows << { lo: lo, mod_idx: mod_idx + 1, topic_order: topic_order, cat: cat[:name] }
          topic_order += 1
        end
      end
    end

    lis = rows.map do |row|
      <<~LI
        <li class="topic-detail__lo-row"
            data-outcome-row
            data-lo-id="#{row[:lo][:id]}"
            data-lo-text="#{row[:lo][:text]}"
            data-nq="#{row[:lo][:nq] || 0}"
            data-topic-order="#{row[:topic_order]}">
          <span class="topic-detail__m-tag mono">M#{row[:mod_idx].to_s.rjust(2, '0')}</span>
          <span class="topic-detail__nq-chip">#{row[:lo][:nq] || 0}</span>
          <span class="topic-detail__lo-text">#{row[:lo][:text]}</span>
          <span class="topic-detail__cat-tag mono">#{row[:cat]}</span>
        </li>
      LI
    end.join

    <<~PANE
      <section class="topic-detail__view topic-detail__view--outcomes"
               data-topic-view-target="pane"
               data-view="outcomes"
               hidden>
        <div class="topic-detail__sort-row">
          <label for="outcomes-sort" class="topic-detail__visually-hidden">Sort outcomes</label>
          <select id="outcomes-sort"
                  data-topic-view-target="sortSelect"
                  data-action="change->topic-view#selectSort">
            <option value="topic_order">Topic order</option>
            <option value="nq_desc">Nq descending</option>
            <option value="nq_asc">Nq ascending</option>
            <option value="alpha">Alphabetical</option>
          </select>
        </div>
        <ol class="topic-detail__outcomes-flat" data-outcomes-flat>#{lis}</ol>
      </section>
    PANE
  end

  def build_heatmap_cells(modules)
    cells = []
    modules.each do |mod|
      mod[:categories].each do |cat|
        cat[:los].each do |lo|
          cells << %(<div class="topic-detail__heat-cell" data-heat-lo-id="#{lo[:id]}"></div>)
        end
      end
    end
    cells.join
  end

  # Convenience: 28-outcome topic shape with "Schrödinger" appearing in two
  # outcome descriptions and one category name.
  def sub56_canonical_modules
    [
      {
        name: 'Foundations',
        categories: [
          { name: 'Vectors',  los: build_los(1, 4, 'vector basics %d') },
          { name: 'Calculus', los: build_los(5, 7, 'calculus topic %d') }
        ]
      },
      {
        name: 'Quantum',
        categories: [
          # Category-name match
          { name: 'Schrödinger Equation', los: build_los(8, 11, 'eigenvalue example %d') },
          { name: 'Operators',            los: build_los(12, 14, 'operator example %d') }
        ]
      },
      {
        name: 'Atoms',
        categories: [
          # Two outcome-name matches with "Schrödinger"
          { name: 'Spectra', los: [
            { id: 15, text: 'Solve the time-independent Schrödinger equation', nq: 4 },
            { id: 16, text: 'Compare radial wavefunctions',                     nq: 1 },
            { id: 17, text: 'Discuss Schrödinger evolution under perturbation', nq: 0 }
          ] },
          { name: 'Bonding', los: build_los(18, 21, 'bonding example %d') }
        ]
      },
      {
        name: 'Stat Mech',
        categories: [
          { name: 'Ensembles', los: build_los(22, 24, 'ensemble topic %d') },
          { name: 'Entropy',   los: build_los(25, 28, 'entropy topic %d') }
        ]
      }
    ]
  end

  def build_los(start_id, end_id, fmt)
    (start_id..end_id).map { |i| { id: i, text: format(fmt, i), nq: i % 5 } }
  end

  # Wait helper for asserting the topic-search controller has finished a
  # filter pass — we use the live region as a synchronization signal.
  def wait_for_search_announcement(text_matcher)
    expect(page).to have_css('[data-topic-search-target="liveRegion"]',
                             text: text_matcher,
                             visible: :all,
                             wait: 4)
  end
end

RSpec.configure do |config|
  config.include Sub56FixtureHelper, type: :system
end
