require 'rails_helper'

# Editor #49 — KaTeX widget perf budget at >20 inline math spans.
#
# Background: Editor #42 added the KaTeX widget rendering for `$…$` and
# `$$…$$` math spans inside cm_markdown_preview.js, with a TODO flagging
# "~20 inline math spans per editor" as an unverified pragmatic limit.
# Editor #43 deferred the perf budget because Capybara wall-clock asserts
# are flaky.
#
# This spec measures decoration-set rebuild time for a 25-inline-math
# fixture and pins a budget so a future refactor that regresses the
# widget pipeline (e.g. unmemoised KaTeX HTML, missing eq() impl) is
# caught in CI rather than in production.
#
# Inline math only for v1 — display math (`$$…$$`) is excluded because
# it has its own block-level layout cost that warrants a separate budget.
RSpec.describe 'CM editor performance', type: :system do
  before { driven_by(:selenium_chrome_headless) }

  let(:selector) { '[data-cm-editor-save-field-value="question[content]"]' }

  it 'renders 25 inline math spans within budget' do
    topic = Topic.create!(name: 'Perf topic')
    lo = topic.learning_objectives.create!(
      description: 'perf',
      category: 'cat',
      position: 1,
    )
    content = (1..25).map { |i| "Equation $#{i}: x^2 + #{i} = #{i**2}$" }.join("\n\n")
    q = topic.questions.create!(
      content: content,
      answer: 'placeholder',
      points: 1,
      question_type: 'written',
      options: [],
    )
    q.learning_objectives << lo

    visit edit_question_path(q)
    wait_for_cm_ready(selector)

    # Force a rebuild via a no-op selection dispatch, which `update()`
    # treats as a selectionSet trigger -> buildDecorations runs end-to-end
    # (syntax-tree pass + math-span regex pass + KatexWidget.toDOM for any
    # off-cursor span). performance.now() brackets that synchronous path.
    elapsed = page.evaluate_script(<<~JS)
      (() => {
        const el = document.querySelector('#{selector}');
        const view = el?.cmView;
        if (!view) return -1;
        const t0 = performance.now();
        view.requestMeasure();
        view.dispatch({ selection: { anchor: 0 } });
        const t1 = performance.now();
        return t1 - t0;
      })()
    JS

    puts "[perf] 25 inline math spans rebuild = #{elapsed.round(2)} ms"
    expect(elapsed).to be >= 0
    # Budget: 100ms gives ~2x headroom over the measured baseline. Tightening
    # below this risks headless-Chrome jitter false positives; loosening
    # above defeats the point of pinning a budget.
    expect(elapsed).to be < 100
  end
end
