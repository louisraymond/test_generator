# Sub-52 — Backend prep: exam usage + N+1 fix

**Branch target:** `topic-detail-v2/sub-52-backend`
**Issue:** GitHub #52 — *Topic Detail: backend prep — exam usage + N+1 fix*
**Blocks:** #53, #54, #55, #56, #57

---

## 1. Goal

Expose, per `LearningObjective`, the count of distinct exams that have included a question targeting that LO, and surface the result as a hash on `TopicsController#show` without introducing N+1 fan-out. The view layer must read the count via `@exam_usage.fetch(lo.id, 0)` — never compute it per row. This is a **backend-only** change: no view markup or Stimulus changes here. It must land first because the heat-map redesign (sub-53), the module/category cards (sub-54), and the request-spec query budget enforced by later tickets all depend on `@exam_usage` being available and on the show page hitting a stable, low query count.

## 2. TDD test list

All specs below are written **before** any production change. Each spec is expected to fail red on first run, then drive the smallest production diff that flips it green.

### 2.1 Model specs — `LearningObjective#exam_appearance_count`

File: `/Users/louisraymond/projects/test_generator/spec/models/learning_objective_spec.rb` (new file)

| # | Spec name | Asserts |
|---|---|---|
| M1 | `returns 0 when the LO has no questions` | Short-circuits before joining `exam_questions`. |
| M2 | `returns 0 when LO has questions but none are in any exam` | Counts exams, not questions. |
| M3 | `returns 1 when all the LO's questions appear in a single exam` | De-duplicates exams. |
| M4 | `returns 2 when the LO's questions span two distinct exams` | Counts distinct exam ids. |
| M5 | `counts an exam once even if two of the LO's questions are both in it` | DISTINCT semantics, not raw join row count. |
| M6 | `is unaffected by another LO's questions in those exams` | Scoping. |

```ruby
# spec/models/learning_objective_spec.rb
require 'rails_helper'

RSpec.describe LearningObjective, type: :model do
  describe '#exam_appearance_count' do
    let(:topic) { create(:topic) }
    let(:lo)    { create(:learning_objective, topic: topic) }

    it 'returns 0 when the LO has no questions' do
      expect(lo.exam_appearance_count).to eq(0)
    end

    it 'returns 0 when LO has questions but none are in any exam' do
      q = create(:question, topic: topic)
      lo.questions << q
      expect(lo.exam_appearance_count).to eq(0)
    end

    it 'returns 1 when all the LO\'s questions appear in a single exam' do
      exam = create(:exam)
      q1   = create(:question, topic: topic)
      q2   = create(:question, topic: topic)
      lo.questions << q1
      lo.questions << q2
      create(:exam_question, exam: exam, question: q1, position: 1)
      create(:exam_question, exam: exam, question: q2, position: 2)
      expect(lo.exam_appearance_count).to eq(1)
    end

    it 'returns 2 when the LO\'s questions span two distinct exams' do
      exam_a = create(:exam)
      exam_b = create(:exam)
      q      = create(:question, topic: topic)
      lo.questions << q
      create(:exam_question, exam: exam_a, question: q, position: 1)
      create(:exam_question, exam: exam_b, question: q, position: 1)
      expect(lo.exam_appearance_count).to eq(2)
    end

    it 'counts an exam once even if two of the LO\'s questions both appear in it' do
      exam = create(:exam)
      q1   = create(:question, topic: topic)
      q2   = create(:question, topic: topic)
      lo.questions << q1
      lo.questions << q2
      create(:exam_question, exam: exam, question: q1, position: 1)
      create(:exam_question, exam: exam, question: q2, position: 2)
      expect(lo.exam_appearance_count).to eq(1)
    end

    it 'is not influenced by other LOs whose questions appear in the same exams' do
      exam = create(:exam)
      other_lo = create(:learning_objective, topic: topic)
      other_q  = create(:question, topic: topic)
      other_lo.questions << other_q
      create(:exam_question, exam: exam, question: other_q, position: 1)
      expect(lo.exam_appearance_count).to eq(0)
    end
  end
end
```

### 2.2 Class-method spec — `LearningObjective.exam_appearance_counts_for(scope)`

| # | Spec name | Asserts |
|---|---|---|
| C1 | `returns a Hash keyed by lo.id with default 0 for missing keys` | Predictable shape; `hash.fetch(missing_id, 0) == 0`. |
| C2 | `executes in a single SQL query` | Uses the query counter helper. |
| C3 | `returns correct counts across LOs with mixed exam exposure` | End-to-end correctness on a small fixture. |
| C4 | `omits LOs that have no questions or no exam appearances from the keys (caller uses fetch)` | Keeps the hash dense; `fetch(.., 0)` covers gaps. |

```ruby
# spec/models/learning_objective_spec.rb (continued)
describe '.exam_appearance_counts_for' do
  let(:topic) { create(:topic) }

  it 'returns a Hash mapping lo.id => count' do
    lo = create(:learning_objective, topic: topic)
    q  = create(:question, topic: topic)
    lo.questions << q
    create(:exam_question, exam: create(:exam), question: q, position: 1)

    result = LearningObjective.exam_appearance_counts_for(topic.learning_objectives)
    expect(result).to be_a(Hash)
    expect(result[lo.id]).to eq(1)
  end

  it 'executes in a single SQL query' do
    lo = create(:learning_objective, topic: topic)
    q  = create(:question, topic: topic)
    lo.questions << q
    create(:exam_question, exam: create(:exam), question: q, position: 1)

    count = QueryCounter.count_for do
      LearningObjective.exam_appearance_counts_for(topic.learning_objectives)
    end
    expect(count).to eq(1)
  end

  it 'returns correct counts across LOs with varied exam exposure' do
    lo_a = create(:learning_objective, topic: topic)
    lo_b = create(:learning_objective, topic: topic)
    lo_c = create(:learning_objective, topic: topic) # zero questions
    q_a  = create(:question, topic: topic)
    q_b  = create(:question, topic: topic)
    lo_a.questions << q_a
    lo_b.questions << q_b
    e1 = create(:exam); e2 = create(:exam)
    create(:exam_question, exam: e1, question: q_a, position: 1)
    create(:exam_question, exam: e2, question: q_a, position: 1)
    create(:exam_question, exam: e1, question: q_b, position: 2)

    result = LearningObjective.exam_appearance_counts_for(topic.learning_objectives)
    expect(result[lo_a.id]).to eq(2)
    expect(result[lo_b.id]).to eq(1)
    expect(result.fetch(lo_c.id, 0)).to eq(0)
  end
end
```

### 2.3 Controller / request specs — `TopicsController#show`

File: `/Users/louisraymond/projects/test_generator/spec/requests/topics_show_spec.rb` (new file)

| # | Spec name | Asserts |
|---|---|---|
| R1 | `assigns @exam_usage as a Hash keyed by lo.id` | Controller wiring. |
| R2 | `200 OK and renders show template` | Smoke. |
| R3 | `issues no more than 6 SQL queries on a realistic topic` | Query budget; uses `QueryCounter`. |

```ruby
# spec/requests/topics_show_spec.rb
require 'rails_helper'

RSpec.describe 'Topics show', type: :request do
  describe 'GET /topics/:id' do
    let(:topic) { create(:topic) }

    it 'assigns @exam_usage as a Hash' do
      get topic_path(topic)
      expect(controller.instance_variable_get(:@exam_usage)).to be_a(Hash)
    end

    it 'renders the page' do
      get topic_path(topic)
      expect(response).to have_http_status(:ok)
    end

    it 'issues no more than 6 SQL queries for a realistic topic' do
      # 4 modules x 7 LOs x ~4 questions/LO; some questions in exams
      4.times do |m_idx|
        mod = create(:topic_module, topic: topic, name: "Module #{m_idx}", position: m_idx)
        7.times do
          lo = create(:learning_objective, topic: topic, topic_module: mod)
          4.times do
            q = create(:question, topic: topic, topic_module: mod)
            lo.questions << q
          end
        end
      end
      # Expose ~10 questions in 3 exams
      exams = Array.new(3) { create(:exam) }
      Question.limit(10).each_with_index do |q, i|
        create(:exam_question, exam: exams[i % 3], question: q, position: i + 1)
      end

      count = QueryCounter.count_for do
        get topic_path(topic)
      end
      expect(count).to be <= 6, "expected <= 6 queries, got #{count}"
    end
  end
end
```

### 2.4 View contract spec — renders without N+1 regression

File: `/Users/louisraymond/projects/test_generator/spec/requests/topics_show_query_budget_spec.rb` (new file, optional sibling — kept separate so the view fixture can grow without polluting the controller spec).

| # | Spec name | Asserts |
|---|---|---|
| V1 | `view renders without recomputing exam_appearance_count per LO` | Ensures view never calls the instance method on each LO. |

```ruby
# spec/requests/topics_show_query_budget_spec.rb
require 'rails_helper'

RSpec.describe 'Topics show — query budget', type: :request do
  it 'does not call LearningObjective#exam_appearance_count during rendering' do
    topic = create(:topic, :with_modules)
    create_list(:learning_objective, 5, topic: topic)
    allow_any_instance_of(LearningObjective)
      .to receive(:exam_appearance_count)
      .and_call_original

    get topic_path(topic)

    expect_any_instance_of(LearningObjective)
      .not_to have_received(:exam_appearance_count)
  end
end
```

(This guard becomes meaningful in sub-53 once the view actually consumes `@exam_usage`. Kept here so it lands as part of the contract.)

## 3. Query-counter strategy

The repo has no `bullet`, no `rack-mini-profiler`, and RSpec instead of Minitest, so `assert_queries` isn't available out of the box. Three options were considered:

- **(a) Add `bullet`** — heavyweight; pollutes dev/test for one ticket; introduces noise.
- **(b) Custom helper via `ActiveSupport::Notifications`** — zero new gems, exactly the precision we need, easy to reuse across specs.
- **(c) Wrap Rails' `assert_no_queries`** — works but pulls in Minitest assertion mixins for one helper; awkward.

**Recommendation: (b).** It's six lines, has no transitive dependency cost, and matches how the existing `spec/support/*.rb` helpers are organised.

```ruby
# spec/support/query_counter.rb (new file)
module QueryCounter
  IGNORED = [/\A(BEGIN|COMMIT|ROLLBACK|SAVEPOINT|RELEASE SAVEPOINT)/i, /SCHEMA/].freeze

  def self.count_for
    queries = []
    callback = ->(_name, _start, _finish, _id, payload) do
      sql = payload[:sql]
      next if payload[:name] == 'SCHEMA'
      next if IGNORED.any? { |re| sql =~ re }
      queries << sql
    end
    ActiveSupport::Notifications.subscribed(callback, 'sql.active_record') do
      yield
    end
    queries.size
  end
end
```

Wire it in `spec/rails_helper.rb` by adding `Dir[Rails.root.join('spec/support/**/*.rb')].sort.each { |f| require f }` if it isn't already loading support. (Recon shows three support files exist but the loader isn't quoted; verify and add if missing — see Step 1.)

## 4. Implementation steps

### Step 1 — Add the query-counter helper

**Explanation:** Without a query counter, the budget tests in §2.2 (C2) and §2.3 (R3) can't be written. This is infrastructure-first because every later spec depends on it. We also confirm `spec/support/**/*.rb` is auto-loaded.

**Before:** `/Users/louisraymond/projects/test_generator/spec/rails_helper.rb` lines 1–72 (no current support autoload line per recon).

**After (new file):** `/Users/louisraymond/projects/test_generator/spec/support/query_counter.rb` — full body in §3 above.

**Patch to `rails_helper.rb`** (only if the support autoload isn't already in place; recon doesn't show the loader explicitly):

```ruby
# spec/rails_helper.rb (add near the top of the RSpec.configure block)
Dir[Rails.root.join('spec/support/**/*.rb')].sort.each { |f| require f }
```

**Test that locks it in:** A throwaway smoke spec — or simply Step 2's M-tests, which require the helper to exist.

### Step 2 — Failing model spec for `#exam_appearance_count`

**Explanation:** Write the six it-blocks in §2.1 first. They will all fail with `NoMethodError: undefined method 'exam_appearance_count'`.

**Before:** No file. `/Users/louisraymond/projects/test_generator/spec/models/learning_objective_spec.rb` does not exist.

**After (new file):** Body in §2.1.

**Test that locks it in:** Itself (M1–M6).

### Step 3 — Implement `LearningObjective#exam_appearance_count`

**Explanation:** Single-LO version. Use the existing `has_many :questions, through: :question_learning_objectives` chain plus a join into `exam_questions`. Return `0` early when there are no question links — saves a query and matches the acceptance criterion.

**Before:** `/Users/louisraymond/projects/test_generator/app/models/learning_objective.rb` lines 1–10 (recon §1):

```ruby
class LearningObjective < ApplicationRecord
  belongs_to :topic
  belongs_to :topic_module, optional: true

  has_many :question_learning_objectives, dependent: :destroy
  has_many :questions, through: :question_learning_objectives

  validates :category, presence: true
  validates :description, presence: true
end
```

**After:**

```ruby
class LearningObjective < ApplicationRecord
  belongs_to :topic
  belongs_to :topic_module, optional: true

  has_many :question_learning_objectives, dependent: :destroy
  has_many :questions, through: :question_learning_objectives

  validates :category, presence: true
  validates :description, presence: true

  # Number of distinct exams that have included a question targeting this LO.
  # Returns 0 without touching exams when the LO has no questions.
  def exam_appearance_count
    return 0 unless question_learning_objectives.exists?

    ExamQuestion
      .joins(question: :question_learning_objectives)
      .where(question_learning_objectives: { learning_objective_id: id })
      .distinct
      .count(:exam_id)
  end
end
```

**Test that locks it in:** M1–M6.

### Step 4 — Failing class-method spec

**Explanation:** Write C1–C4 from §2.2. C2 will use `QueryCounter` to assert single-query semantics — the bulk fetch must not lazy-load.

**Before:** Same file as Step 2.

**After:** Append the `describe '.exam_appearance_counts_for'` block from §2.2.

**Test that locks it in:** C1–C4.

### Step 5 — Implement `.exam_appearance_counts_for(scope)`

**Explanation:** A bulk fetch keyed by `lo.id`. Joins through `question_learning_objectives` and `exam_questions`, groups by LO, counts distinct exam ids in one SQL statement. Accepts any AR relation or Array of LOs and reduces to a hash with integer keys.

**Before:** Method does not exist.

**After (append to `learning_objective.rb`):**

```ruby
# Bulk variant of #exam_appearance_count.
# Returns { lo_id => distinct_exam_count } in a single query.
# Callers should access the hash with .fetch(lo_id, 0) — keys for LOs with
# zero exam appearances are omitted from the result.
def self.exam_appearance_counts_for(scope)
  ids = scope.respond_to?(:pluck) ? scope.pluck(:id) : Array(scope).map(&:id)
  return {} if ids.empty?

  joins(question_learning_objectives: { question: :exam_questions })
    .where(id: ids)
    .group('learning_objectives.id')
    .distinct
    .count('exam_questions.exam_id')
end
```

**Test that locks it in:** C1–C4.

### Step 6 — Failing controller spec

**Explanation:** Add R1, R2, R3 from §2.3. R3 will fail because `@exam_usage` isn't set yet and because the existing preloads issue more than 6 queries once we count exam-related work.

**Before:** No file. `/Users/louisraymond/projects/test_generator/spec/requests/topics_show_spec.rb` does not exist.

**After (new file):** Body in §2.3.

**Test that locks it in:** R1–R3.

### Step 7 — Set `@exam_usage` in `TopicsController#show`

**Explanation:** Compute the bulk hash inside `set_topic` (so we already have `@topic.learning_objectives` loaded), or in `show`. Putting it in `show` keeps `set_topic` focused on preloading; putting it in `set_topic` keeps all topic-page IVars in one place. Recon shows `set_topic` already special-cases `action_name == 'show'`, so the same conditional fits the new IVar.

**Before:** `/Users/louisraymond/projects/test_generator/app/controllers/topics_controller.rb` lines 8 and 41–52 (recon §3):

```ruby
def show; end
# ...
def set_topic
  scope = Topic.all
  if action_name == 'show'
    scope = scope.includes(
      :subtopics,
      { topic_modules: { learning_objectives: :questions } },
      { learning_objectives: :questions },
      :questions
    )
  end
  @topic = scope.find(params[:id])
end
```

**After:**

```ruby
def show
  @exam_usage = LearningObjective.exam_appearance_counts_for(@topic.learning_objectives)
end

# ...

def set_topic
  scope = Topic.all
  if action_name == 'show'
    scope = scope.includes(
      :subtopics,
      { topic_modules: { learning_objectives: :questions } },
      { learning_objectives: :questions },
      :questions
    )
  end
  @topic = scope.find(params[:id])
end
```

**Test that locks it in:** R1, R2.

### Step 8 — Failing query-budget spec

**Explanation:** R3 from §2.3 measures actual query count under a realistic fixture. With the controller change in Step 7 but before Step 9's preload tweak, the count will exceed 6 because the bulk fetch's join doesn't piggy-back off the existing `:questions` preload.

**Before:** Spec already drafted in Step 6.

**After:** Re-run the spec; observe failure with measured count (typical: 8–10).

**Test that locks it in:** R3.

### Step 9 — Drop below 6 queries

**Explanation:** The bulk fetch is already a single query. The remaining surplus comes from the existing `set_topic` preloads issuing one query per association branch. The cheapest win is to consolidate: the `{ topic_modules: { learning_objectives: :questions } }` and `{ learning_objectives: :questions }` branches both load LOs and questions; we don't need both, since the LO heat-map reads from `@topic.topic_modules.flat_map(&:learning_objectives)` once modules exist. Keep both for now (the no-modules branch needs the top-level LOs) but stop touching `:questions` from this controller — the bulk hash is the only thing that needed exam joins, and that's a single grouped query.

**Before:** Same as Step 7 "before".

**After:**

```ruby
def set_topic
  scope = Topic.all
  if action_name == 'show'
    scope = scope.includes(
      :subtopics,
      { topic_modules: { learning_objectives: :question_learning_objectives } },
      { learning_objectives: :question_learning_objectives },
      :questions
    )
  end
  @topic = scope.find(params[:id])
end
```

Rationale: the view (sub-53) needs LO + question-link presence for the coverage badge; it does **not** need each `Question` row to render the heat-map. Replacing `:questions` with `:question_learning_objectives` cuts the heaviest preload while keeping `lo.questions.size` cheap (it can use `question_learning_objectives.size` once the view is updated in sub-53). For sub-52 we can keep `:questions` if the current view depends on it — verify in step 8 by rerunning R3 after this swap; if still over budget, drop `:questions` and accept the consequence in sub-53.

**Test that locks it in:** R3, V1.

## 5. Antagonist review

### Persona A — Skeptic Engineer

> *"≤ 6 SQL queries — really?"* With four modules, 28 LOs, 100+ questions, the Rails `set_topic` `.includes` chain alone fires (a) topic, (b) subtopics, (c) topic_modules, (d) learning_objectives via modules, (e) questions via those LOs, (f) top-level LOs, (g) top-level questions, (h) loose questions. That's already 7–8 before exam usage. Topic 12 with 5 modules makes no difference — `includes` is association-count-bounded, not row-count-bounded — but the absolute floor sits at ~5 even for the empty case.

**ACCEPTED — change applied:** Step 9 reframes the budget as "≤ 6 *after* the preload swap"; if the swap doesn't get us there we drop the redundant `{ learning_objectives: :questions }` branch and document that. If 6 turns out to be unreachable without view-level changes (which belong in sub-53), bump the contract to ≤ 8 with a TODO and call out the dependency. The plan now records the concrete measured floor as an open question (§6).

> *"Is the bulk SQL correct under edge cases?"* (i) LO with no questions: `joins(...).where(id: ids).group(...)` simply omits that LO from the result hash — caller uses `.fetch(.., 0)`. Correct. (ii) LO with question used in zero exams: `INNER JOIN exam_questions` excludes — same handling. Correct. (iii) Same exam reached twice via two different questions: `count('exam_questions.exam_id')` with `distinct` collapses. Correct.

**ACCEPTED — change applied:** §2.2 includes C4 (omitted-key behaviour) and §2.1 includes M5 (same-exam-twice de-dup). The model docstring spells out the omission semantics so future maintainers don't "fix" it.

> *"`dependent: :destroy` cascade?"* Deleting an LO destroys `question_learning_objectives` rows — this is existing behaviour, not introduced here. Worth noting that destroying a Question also destroys its `exam_questions` (line in Question model from recon).

**REJECTED — rationale:** Out of scope. The cascade is pre-existing and the new code is read-only; it can't introduce new destruction. Flagged in the risk register instead.

### Persona B — Performance Reviewer

> *"Will the bulk fetch use existing indexes?"* The schema (recon §2) shows indexes on `learning_objectives(topic_id, category, position)`, `exam_questions(exam_id, position)` (uniqueness). It does **not** explicitly call out indexes on `question_learning_objectives.learning_objective_id`, `question_learning_objectives.question_id`, or `exam_questions.question_id`. Without the latter two, the join from `learning_objectives` → `question_learning_objectives` → `questions` → `exam_questions` will sequential-scan one of the join sides on a non-trivial dataset.

**ACCEPTED — change applied:** Added to risk register (§7) and open questions (§6): verify presence of indexes on `question_learning_objectives(learning_objective_id)`, `question_learning_objectives(question_id)`, and `exam_questions(question_id)`. If any are missing, open a follow-up migration ticket — not part of sub-52 because the issue explicitly says no schema changes, but the perf assertion in R3 will surface it on real data.

> *"Worst-case JOIN row count?"* 200 LOs × 10 questions × 5 exams = 10 000 rows pre-group. Postgres handles that easily for a single page render; the GROUP BY collapses to ≤ 200 rows. Acceptable.

**REJECTED — rationale:** Within tolerance. Documented as a non-issue.

> *"Counter-cache vs recompute?"* Counter cache (e.g. `learning_objectives.exam_appearance_count` integer column) gives O(1) reads but requires write-side bookkeeping in `ExamQuestion#after_save/after_destroy` and a backfill migration. The issue explicitly defers counter-cache to "if performance demands it later". Trade-off: small added write cost vs free reads forever.

**ACCEPTED — change applied:** §6 lists counter-cache as the obvious next lever if R3 ever flakes on prod-sized fixtures.

### Persona C — Test Discipline Reviewer

> *"Red-green check: which spec fails today and passes only after implementation?"* M1 fails on `NoMethodError`; C1 fails the same way; R1 fails because `@exam_usage` isn't assigned. After Step 3 → M1–M6 green; after Step 5 → C1–C4 green; after Step 7 → R1, R2 green; after Step 9 → R3 green. Order is sound.

**ACCEPTED — no change needed.**

> *"Edge-case coverage?"* M1 covers 0 questions. M2 covers questions but no exams. M3 covers same-exam collapsing. M5 covers two questions same exam. M6 covers other-LO contamination. **Missing:** "LO with one question in two exams" — *added* (now M4). "Many-to-many: one question linked to two LOs, both should attribute the exam" — also worth a spec.

**ACCEPTED — change applied:** M4 is in §2.1; an extra it-block for shared-question across two LOs is added below as M7:

```ruby
it 'attributes a shared question\'s exam to every LO it links to' do
  exam = create(:exam)
  q    = create(:question, topic: topic)
  other_lo = create(:learning_objective, topic: topic)
  lo.questions << q
  other_lo.questions << q
  create(:exam_question, exam: exam, question: q, position: 1)
  expect(lo.exam_appearance_count).to eq(1)
  expect(other_lo.exam_appearance_count).to eq(1)
end
```

> *"Is the query-count test brittle?"* Yes — sub-53's view changes will cause the count to drift. Mitigation: pin the assertion to the controller-rendered template path, document the count on commit (§6 Open Questions captures the concrete number), and treat any new failure in sub-53 as a forcing function to think about the data layer rather than silently bumping the threshold.

**ACCEPTED — change applied:** R3's failure message includes the actual count (`got #{count}`) so a future drift is loud, and §7 risk register lists "spec drift across sibling tickets" as risk #2.

## 6. Open questions / explicit non-goals

- **Counter-cache columns** — out of scope per issue. Revisit if R3 trends upward across releases.
- **API exposure** — out of scope. Issue explicitly says don't expose via JSON.
- **Real-time updates** — out of scope. Page-load recompute is fine.
- **Concrete query-count threshold** — to be filled in at commit time. Capture the actual count R3 produces in the commit message and update the spec's `<= 6` if the realistic fixture forces a higher floor (with a code comment justifying).
- **Index audit on `question_learning_objectives` and `exam_questions.question_id`** — verify before merge; open a separate migration ticket if missing.

## 7. Risk register

| # | Risk | Impact × Likelihood | Mitigation |
|---|---|---|---|
| 1 | Missing indexes on `question_learning_objectives(question_id)` and/or `exam_questions(question_id)` cause slow joins on prod-sized data. | High × Medium | Audit `db/schema.rb` before merge; if missing, raise a follow-up migration ticket; R3 spec serves as canary. |
| 2 | Query-count spec (R3) drifts as sub-53/54/55 rewrite the view, causing flaky failures unrelated to data layer. | Medium × High | Lock the count to a concrete number measured at sub-52 commit time; require a written justification in any later PR that bumps it. |
| 3 | `set_topic` preload swap (`:questions` → `:question_learning_objectives`) breaks an unrelated existing view path that still calls `lo.questions` per row. | Medium × Medium | Run the full request spec suite after Step 9; if other specs fail, keep `:questions` preload and accept a higher query budget for sub-52, fixing properly in sub-53. |
