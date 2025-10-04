
# Exam: Exam Generator Codebase (Phase 1)

This exam covers the architecture, commits, and implementation details of the current Rails app. Unless otherwise stated, answers should cite the relevant file path (and line numbers when helpful) and explain why the code is written that way.

## Conventions
- Use inline code for identifiers (e.g., `ExamBuilder.call`).
- For code locations, reference paths like `app/services/exam_builder.rb:22`.
- For reasoning questions, mention trade‑offs and alternatives.

---

## 1) Initial scaffolding and dependencies
1. Which gem renders HTML to PDF in this app? Point to the declaration in `Gemfile` and the version lock in `Gemfile.lock`.
2. What JavaScript runtime/library backs the PDF generation, and where is it declared? (Hint: `package.json`.)
3. Where is the Rails version pinned? Show the line in `Gemfile` that constrains it.
4. Which database adapter is configured in `Gemfile` and `config/database.yml`? Why is `encoding: unicode` set for Postgres?

## 2) Models and associations
1. Show the `Question` model’s associations and explain `optional: true` on `belongs_to :source` (`app/models/question.rb`).
2. Where does `Exam` enforce question ordering via a join model? Cite `app/models/exam.rb` and explain how `position` is used.
3. Why does `Topic` use `dependent: :destroy` while `Source` uses `dependent: :nullify`? Discuss the data‑integrity rationale.

## 3) Migrations and constraints
1. In `db/migrate/20251003210938_create_exam_questions.rb`, what index prevents duplicate positions within an exam? Give the index signature.
2. In `db/migrate/20251003223000_harden_db_constraints.rb`, what is the DB default for `questions.options` and why was `NOT NULL` added?
3. How did the migration `20251004000500_allow_repeated_questions_in_exam.rb` change constraints to allow repeated questions? Explain the index that was removed.

## 4) Seeds and data variety
1. How many example questions are created in `db/seeds.rb`? Name at least five different question types present.
2. Find one calculation question in the seeds. What fields make it a calculation? (Show `answer_label` and `unit`.)
3. Several image‑based questions use local SVGs. Where are those assets stored? Show a file path and explain how the app embeds images.
4. For diagram labeling questions, seeds can include `markers`. Show one example and explain how it influences rendering.

## 5) Controllers and routes
1. What are the routes for exams and their marking scheme? Cite `config/routes.rb` and list the actions.
2. In `ExamsController#create`, how does the app sanitize and permit `topic_weights` and `question_types`? Give the `exam_params` definition and explain why `to_h` cannot be called on unpermitted params.
3. In `QuestionsController#types_preview`, which Grover options ensure the PDF respects print CSS and backgrounds?

## 6) Grover integration and PDF options
1. Show where PDFs are generated in `ExamsController#show`. Which options are set and why (e.g., `emulate_media: 'print'`)?
2. What layout is used for PDFs vs. HTML for the marking scheme? Compare `layout: false` vs. `layout: 'pdf'` and justify the choice.

## 7) Service object (PORO) design: `ExamBuilder`
1. Explain the purpose of `MAX_QUESTIONS` and how `count` is clamped (`app/services/exam_builder.rb:22–25`).
2. How do type filters (`types`) and topic weights (`topic_weights`) influence selection? Cite relevant lines.
3. Describe how `allow_repeats` works and how the padding by cycling is implemented (`app/services/exam_builder.rb:46–50`).
4. Why is exam creation wrapped in a transaction? What could go wrong if it weren’t?
5. What exceptions can `ExamBuilder` raise and under what conditions? (`MissingTopicsError`, `NotEnoughQuestionsError`).

## 8) Question types and rendering
1. List all `QUESTION_TYPES` in `app/models/question.rb` and explain the inclusion validations.
2. How are question partials selected? Point to the case statement in `app/views/questions/_question.html.erb`.
3. For `multiple_choice`, describe the grid layout and sizes for box, letter, and text. Reference the CSS in `app/assets/stylesheets/exam.css`.
4. For `diagram_label`, explain how on‑image callouts are rendered and how the number of blanks is determined.
5. For `image_occlusion`, how are multiple masks shown and how are answers collected? Reference both the template and CSS.
6. For `markdown`, what subset of markdown is supported and how is it sanitized? Cite `app/helpers/markdown_helper.rb`.

## 9) Styling and print layout
1. What are the `@page` margins? Quote the values and explain their effect on printed PDFs.
2. How do we ensure background gradients (ruled lines) render in PDFs? Show both CSS (`print-color-adjust`) and Grover options.
3. Explain how ruled line thickness and cadence were stabilized in `.answer-lines`. Why can anti‑aliasing make lines look uneven?
4. Why are MC, calculation, and diagram labels indented, while written answers are not? Describe the visual rationale.
5. Where is the A4 screen preview container defined, and why did we switch to `min-height` from `height`?

## 10) Exams form and browsing
1. What inputs does the exam generation form accept (title, count, duration, question types, topic weights, repeats)? Show where the form renders them.
2. Where can a user browse questions by topic/source/type? Cite the controller and view.
3. How does the controller preserve form state when validation fails? Explain use of `render :new` with `flash.now`.

## 11) Security, safety, and trade‑offs
1. Why is the markdown renderer intentionally minimal and sanitized? What tags/attributes are allowed?
2. Why embed local images as data URIs in some cases? Discuss reliability vs. payload size.
3. What risks are avoided by transactions and by defensive parameter casting in the controllers?

## 12) Improvements and extensions (design questions)
1. How would you add per‑type quotas (e.g., 40% written, 40% MC, 20% diagrams) without making `ExamBuilder` too complex?
2. Propose a clean `delegated_type` refactor for question types. Sketch tables and migration steps.
3. Outline a `Preset` model for re‑usable test configs. What fields and validations would you add?
4. Suggest how to add page numbers to PDFs with minimal view changes and no preview JS.
5. How would you test `ExamBuilder` selection logic and repeats? Provide a brief spec outline.

---

## Practical (code reading)
- Write a short note explaining what this code does and why each option matters:

```ruby
# app/controllers/exams_controller.rb:58
pdf = Grover.new(
  html,
  base_url: request.base_url,
  emulate_media: 'print',
  print_background: true,
  prefer_css_page_size: true
).to_pdf
```

- Given the method below, explain how `topic_weights` are applied and what happens when availability is lower than allocation:

```ruby
# app/services/exam_builder.rb:65
def self.allocate_by_weights(scope, topic_ids, weights, total_needed)
  # allocation and balancing logic
end
```

- In `question.rb`, show the inclusion validations and conditional validation for `multiple_choice` options and explain the rationale.

---

End of exam.

---

## Code Reading Questions (with snippets)

Read each snippet and explain what it does, why it is implemented this way, and how it interacts with the rest of the app. Reference file paths and line numbers in your explanations.

1) Controller parameter hardening and service call

```ruby
# app/controllers/exams_controller.rb:create
p = exam_params

title     = p[:title].presence || 'Practice Exam'
topic_ids = Array(p[:topic_ids]).reject(&:blank?)
count     = p[:question_count].to_i

# Sanitize optional filters
types = Array(p[:question_types]).reject(&:blank?)
types &= Question::QUESTION_TYPES

raw_weights_params = p[:topic_weights]
raw_weights = raw_weights_params.is_a?(ActionController::Parameters) ? raw_weights_params.to_h : (raw_weights_params || {})
weights = raw_weights
          .slice(*topic_ids.map(&:to_s))
          .transform_values { |v| v.to_s.strip }
          .reject { |_k, v| v.blank? || v.to_f <= 0 }
          .transform_values(&:to_f)

duration = p[:duration_minutes].presence&.to_i
allow_repeats = ActiveModel::Type::Boolean.new.cast(p[:allow_repeats])

@exam = ExamBuilder.call(
  topic_ids: topic_ids,
  count: count,
  title: title,
  strict: true,
  types: types.presence,
  topic_weights: weights.presence,
  duration_minutes: duration,
  allow_repeats: allow_repeats
)
```

- Explain how strong parameters are used and why `to_h` is avoided on unpermitted params.
- Why is `types` intersected with `Question::QUESTION_TYPES`?
- What does `allow_repeats` change in exam generation?

2) Weighted selection and repeats

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

- Describe how the code ensures the requested count is met with or without repeats.
- What are the trade‑offs of using `ORDER BY RANDOM()` vs. precomputed randomness or sampling by id?

3) Matching question layout (view)

```erb
# app/views/questions/_matching.html.erb
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

- Explain how this layout improves clarity over checkboxes.
- What CSS ensures the line is long enough to draw on and that the columns align consistently?

4) Diagram labeling callouts

```erb
# app/views/questions/_diagram_label.html.erb
<% markers = Array(data['markers']) %>
...
<% markers.each_with_index do |m, i| %>
  <div class="callout" style="left:<%= m['x'] %>%; top:<%= m['y'] %>%">
    <span class="callout-dot"><%= i + 1 %></span>
  </div>
<% end %>
```

- How do `markers` improve UX? What happens to the number of blanks if markers are omitted?
- Why are callouts positioned with percentages rather than pixels?

5) Ruled lines cadence and print fidelity

```css
/* app/assets/stylesheets/exam.css */
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

- Why is `background-size` set to `100% 7mm`? How does this reduce anti‑aliasing artifacts when printed to PDF?
- Suggest an alternative if lines still look uneven on a specific printer.

6) Markdown question type

```erb
# app/views/questions/_markdown.html.erb
<div class="markdown-body">
  <%= render_markdown(question.content) %>
  <% if question.answer_size.present? %>
    <div class="answer-lines answer-lines-<%= question.answer_size %>"></div>
  <% end %>
</div>
```

- Explain why the renderer is intentionally minimal and how the CSS makes it readable in B/W printing (mention gutter border and grayscale background).

7) Routes and preview

```ruby
# config/routes.rb
root 'exams#new'
resources :exams, only: %i[new create show] do
  member { get :marking_scheme }
end
resources :questions, only: [:index]
```

- List all reachable endpoints with their HTTP methods and what they return.
- Why is `questions#index` useful during development?
