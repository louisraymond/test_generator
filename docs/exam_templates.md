# Exam Templates System

## Overview

The Exam Templates system allows you to create reusable exam configurations with multiple sections, granular source selection, and advanced question rules.

## Key Features

### 1. **Reusable Templates**
- Save exam configurations for repeated use
- Track usage statistics (use_count, last_used_at)
- Clone and modify existing templates

### 2. **Multi-Section Exams**
- Create exams with distinct sections (e.g., "Section A: Multiple Choice", "Section B: Written")
- Each section can have:
  - Custom name and duration
  - Specific question count
  - Point constraints (min/max)
  - Question type filters

### 3. **Granular Source Selection**
- Select questions from:
  - **Topics**: All questions from a topic
  - **Modules**: Questions from specific topic modules
  - **Learning Objectives**: Questions tagged to specific LOs
- Weight-based distribution across multiple sources
- Override with exact question counts per source

### 4. **Question Rules**
- **Force Include**: Specific questions that must appear
  - Support for repeating the same question multiple times
- **Exclude**: Blacklist specific questions

### 5. **Section Breaks in Exams**
- Generated exams display clear section headers
- Section metadata shown (duration, point ranges)
- Proper section breaks in both exam and marking scheme

## Database Schema

### ExamTemplate
- `name`: Template name (required, unique)
- `description`: Optional description
- `duration_minutes`: Total duration (optional, auto-sums if blank)
- `use_count`: Tracks number of uses
- `last_used_at`: Timestamp of last use

### ExamSection
- `exam_template_id`: Parent template
- `position`: Order in exam (0-indexed)
- `name`: Section name (e.g., "Section A: Multiple Choice")
- `question_count`: Number of questions (required)
- `duration_minutes`: Section duration (optional)
- `min_points`, `max_points`: Point constraints (optional)
- `question_type_filter`: JSONB array of allowed types

### SectionSourceRule
- `exam_section_id`: Parent section
- `source_type`: 'Topic', 'TopicModule', or 'LearningObjective'
- `source_id`: ID of the source
- `weight`: Distribution weight (default: 1)
- `question_count_override`: Exact count from this source (optional)

### SectionQuestionRule
- `exam_section_id`: Parent section
- `question_id`: Specific question
- `rule_type`: 'force_include' or 'exclude'
- `repeat_count`: How many times to include (default: 1)

## Usage

### Creating a Template

1. Navigate to **Exam Templates** in the menu
2. Click **New Template**
3. Fill in template details (name, description, duration)
4. Click **Add Section** to create sections
5. For each section:
   - Set name, question count, duration
   - Optionally filter by question types
   - Add source rules (where to pull questions from)
   - Optionally add force-include/exclude rules
6. Click **Create Template**

### Generating an Exam from Template

**Option 1**: From Template Index
- Click **Generate** button on any template

**Option 2**: From Template Show Page
- Click **Generate Exam** button

The system will:
1. Pull questions from all sections according to rules
2. Force-include specified questions (with repeats)
3. Exclude blacklisted questions
4. Apply weighted distribution across sources
5. Create exam with section breaks
6. Increment template use count

### Example Template Structure

```ruby
template = ExamTemplate.create!(
  name: "Database Fundamentals Midterm",
  description: "Standard midterm format",
  duration_minutes: 120
)

# Section 1: Multiple Choice
section1 = template.exam_sections.create!(
  name: "Section A: Multiple Choice",
  position: 0,
  question_count: 20,
  duration_minutes: 30,
  question_type_filter: ['multiple_choice']
)

section1.section_source_rules.create!(
  source_type: 'Topic',
  source_id: topic.id,
  weight: 1
)

# Section 2: Written
section2 = template.exam_sections.create!(
  name: "Section B: Written Response",
  position: 1,
  question_count: 8,
  duration_minutes: 60,
  question_type_filter: ['written']
)

# Multiple sources with different weights
section2.section_source_rules.create!(
  source_type: 'TopicModule',
  source_id: hash_indexes_module.id,
  weight: 2  # Prioritize this module
)

section2.section_source_rules.create!(
  source_type: 'TopicModule',
  source_id: btree_module.id,
  weight: 1
)

# Force include a specific question
section2.section_question_rules.create!(
  question_id: important_question.id,
  rule_type: 'force_include',
  repeat_count: 1
)

# Exclude a question (e.g., used in last exam)
section2.section_question_rules.create!(
  question_id: overused_question.id,
  rule_type: 'exclude'
)
```

## API Endpoints

### Routes
```ruby
resources :exam_templates do
  member do
    post :generate  # Generate exam from template
  end
end
```

### Controller Actions
- `index`: List all templates
- `show`: View template details
- `new`: New template form
- `create`: Create template
- `edit`: Edit template form
- `update`: Update template
- `destroy`: Delete template
- `generate`: Create exam from template

## Business Logic

### ExamBuilder.from_template

The core generation logic:

1. **Load Template**: Fetch template with all sections
2. **Process Each Section**:
   - Get available questions from source rules
   - Apply question type filters
   - Exclude blacklisted questions
   - Force-include specified questions (with repeats)
   - Select remaining questions using weighted distribution
   - Shuffle to mix forced and random questions
3. **Create Exam**:
   - Create exam record with template reference
   - Create exam_questions with section_number
   - Maintain position ordering across sections
4. **Update Template**: Increment use_count, set last_used_at

### Question Selection Algorithm

```ruby
def build_section_questions(section)
  questions = []
  
  # 1. Force-included questions (with repeats)
  section.section_question_rules.force_includes.each do |rule|
    rule.repeat_count.times { questions << rule.question }
  end
  
  # 2. Calculate remaining needed
  remaining = section.question_count - questions.size
  
  # 3. Get available questions
  available = section.available_questions
  
  # 4. Apply weighted selection if multiple sources
  if section.section_source_rules.size > 1
    selected = select_by_source_weights(section, available, remaining)
  else
    selected = available.order('RANDOM()').limit(remaining)
  end
  
  questions.concat(selected)
  
  # 5. Shuffle to mix forced and random
  questions.shuffle
end
```

## UI Components

### Template Index
- Table view with all templates
- Shows: sections, total questions, duration, usage stats
- Actions: Generate, Edit, Delete

### Template Show
- Overview statistics (sections, questions, duration, uses)
- Detailed section information
- Source rules and question rules per section
- Generate exam button

### Template Form
- Dynamic section builder
- Nested source rule fields
- Collapsible question rule section
- Real-time section addition/removal

### Exam Display
- Section breaks with headers
- Section metadata (duration, points)
- Proper styling and page breaks

### Marking Scheme
- Section breaks in table
- Section headers with metadata
- Grouped by section

## Future Enhancements

### Potential Features
1. **Difficulty Distribution**: Constrain by Bloom's level or difficulty
2. **Point Allocation**: Ensure section totals meet constraints
3. **Ordering Rules**: Control question order (random, difficulty, topic)
4. **Template Cloning**: One-click duplicate and modify
5. **Template Sharing**: Export/import templates
6. **Analytics**: Track which templates generate best exams
7. **Question Pool Preview**: Show available questions before generation
8. **Smart Suggestions**: Recommend templates based on topic selection

## Testing

To test the system:

1. Run the example seed: `rails runner db/seeds/example_template.rb`
2. Visit `/exam_templates`
3. View the "Database Fundamentals Midterm" template
4. Click "Generate Exam"
5. Observe section breaks in the generated exam
6. View the marking scheme to see section groupings

## Troubleshooting

### "Not enough questions"
- Check that source rules point to valid topics/modules/LOs
- Ensure those sources have enough questions
- Reduce question_count or adjust question_type_filter

### Sections not showing in exam
- Verify section_number is set on exam_questions
- Check that exam has exam_template_id set
- Ensure section position values are correct

### Question types not filtering
- Verify question_type_filter is properly saved as JSONB array
- Check that questions have correct question_type values
- Ensure allows_question_type? logic is working

## Related Files

- **Models**: `app/models/exam_template.rb`, `exam_section.rb`, `section_source_rule.rb`, `section_question_rule.rb`
- **Controller**: `app/controllers/exam_templates_controller.rb`
- **Service**: `app/services/exam_builder.rb` (updated with `from_template` method)
- **Views**: `app/views/exam_templates/`
- **Stimulus**: `app/javascript/controllers/template_form_controller.js`
- **Routes**: `config/routes.rb`
- **Migrations**: `db/migrate/2025100623*.rb`

