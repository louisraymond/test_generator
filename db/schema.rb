# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2026_04_22_100200) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "exam_questions", force: :cascade do |t|
    t.bigint "exam_id", null: false
    t.bigint "question_id", null: false
    t.integer "position", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "section_number"
    t.index ["exam_id", "position"], name: "index_exam_questions_on_exam_id_and_position", unique: true
    t.index ["exam_id"], name: "index_exam_questions_on_exam_id"
    t.index ["question_id"], name: "index_exam_questions_on_question_id"
  end

  create_table "exam_sections", force: :cascade do |t|
    t.bigint "exam_template_id", null: false
    t.integer "position", default: 0, null: false
    t.string "name", null: false
    t.integer "duration_minutes"
    t.integer "question_count", null: false
    t.integer "min_points"
    t.integer "max_points"
    t.jsonb "question_type_filter", default: []
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "letter"
    t.index ["exam_template_id", "position"], name: "index_exam_sections_on_exam_template_id_and_position", unique: true
    t.index ["exam_template_id"], name: "index_exam_sections_on_exam_template_id"
  end

  create_table "exam_templates", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.integer "duration_minutes"
    t.integer "use_count", default: 0, null: false
    t.datetime "last_used_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "subject"
    t.string "paper_number"
    t.string "tier"
    t.string "subtitle"
    t.text "rubric"
    t.jsonb "candidate_fields", default: [], null: false
    t.jsonb "grade_boundaries", default: {}, null: false
    t.string "centre_name"
    t.boolean "sections_have_letters", default: true, null: false
    t.text "principles_of_marking"
    t.index ["last_used_at"], name: "index_exam_templates_on_last_used_at"
    t.index ["name"], name: "index_exam_templates_on_name", unique: true
  end

  create_table "exams", force: :cascade do |t|
    t.string "title", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "duration_minutes"
    t.bigint "exam_template_id"
    t.date "exam_date"
    t.integer "seed"
    t.string "subject_override"
    t.string "paper_number_override"
    t.string "tier_override"
    t.string "centre_name_override"
    t.integer "lock_version", default: 0, null: false
    t.index ["created_at"], name: "index_exams_on_created_at"
    t.index ["exam_template_id"], name: "index_exams_on_exam_template_id"
  end

  create_table "learning_objectives", force: :cascade do |t|
    t.bigint "topic_id", null: false
    t.string "category", null: false
    t.integer "category_order", default: 0, null: false
    t.integer "position", default: 0, null: false
    t.text "description", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "topic_module_id"
    t.index ["topic_id", "category", "position"], name: "idx_on_topic_id_category_position_1999db334e"
    t.index ["topic_id", "category_order"], name: "index_learning_objectives_on_topic_id_and_category_order"
    t.index ["topic_id"], name: "index_learning_objectives_on_topic_id"
    t.index ["topic_module_id"], name: "index_learning_objectives_on_topic_module_id"
  end

  create_table "marking_steps", force: :cascade do |t|
    t.bigint "question_id", null: false
    t.integer "position", null: false
    t.string "kind", null: false
    t.integer "n", default: 1, null: false
    t.text "text", null: false
    t.text "accepts", default: [], array: true
    t.text "rejects", default: [], array: true
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["question_id", "position"], name: "index_marking_steps_on_question_id_and_position", unique: true
    t.index ["question_id"], name: "index_marking_steps_on_question_id"
  end

  create_table "question_learning_objectives", force: :cascade do |t|
    t.bigint "question_id", null: false
    t.bigint "learning_objective_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["learning_objective_id"], name: "index_question_learning_objectives_on_learning_objective_id"
    t.index ["question_id", "learning_objective_id"], name: "index_qlo_on_question_and_learning_objective", unique: true
    t.index ["question_id"], name: "index_question_learning_objectives_on_question_id"
  end

  create_table "questions", force: :cascade do |t|
    t.bigint "topic_id", null: false
    t.bigint "source_id"
    t.text "content", null: false
    t.text "answer", null: false
    t.integer "points", null: false
    t.string "answer_size"
    t.string "question_type", null: false
    t.jsonb "options", default: [], null: false
    t.string "source_reference"
    t.string "answer_label"
    t.string "unit"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "topic_module_id"
    t.string "bloom_level"
    t.text "marker_notes"
    t.index ["bloom_level"], name: "index_questions_on_bloom_level"
    t.index ["question_type"], name: "index_questions_on_question_type"
    t.index ["source_id"], name: "index_questions_on_source_id"
    t.index ["topic_id", "question_type"], name: "index_questions_on_topic_id_and_question_type"
    t.index ["topic_id"], name: "index_questions_on_topic_id"
    t.index ["topic_module_id"], name: "index_questions_on_topic_module_id"
  end

  create_table "section_question_rules", force: :cascade do |t|
    t.bigint "exam_section_id", null: false
    t.bigint "question_id", null: false
    t.string "rule_type", null: false
    t.integer "repeat_count", default: 1, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["exam_section_id", "question_id", "rule_type"], name: "idx_section_question_rules_unique", unique: true
    t.index ["exam_section_id"], name: "index_section_question_rules_on_exam_section_id"
    t.index ["question_id"], name: "index_section_question_rules_on_question_id"
  end

  create_table "section_source_rules", force: :cascade do |t|
    t.bigint "exam_section_id", null: false
    t.string "source_type", null: false
    t.bigint "source_id", null: false
    t.integer "weight", default: 1
    t.integer "question_count_override"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["exam_section_id"], name: "index_section_source_rules_on_exam_section_id"
    t.index ["source_type", "source_id"], name: "index_section_source_rules_on_source_type_and_source_id"
  end

  create_table "sources", force: :cascade do |t|
    t.string "name", null: false
    t.string "source_type", null: false
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_sources_on_name"
  end

  create_table "topic_modules", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.bigint "topic_id", null: false
    t.integer "position", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["topic_id", "name"], name: "index_topic_modules_on_topic_id_and_name", unique: true
    t.index ["topic_id"], name: "index_topic_modules_on_topic_id"
  end

  create_table "topics", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "epigraph_quote"
    t.string "epigraph_attribution"
    t.jsonb "module_aims", default: [], null: false
    t.jsonb "learning_outcomes", default: [], null: false
    t.jsonb "syllabus_outline", default: [], null: false
    t.jsonb "reference_links", default: [], null: false
    t.bigint "parent_topic_id"
    t.index ["name"], name: "index_topics_on_name"
    t.index ["parent_topic_id"], name: "index_topics_on_parent_topic_id"
  end

  add_foreign_key "exam_questions", "exams"
  add_foreign_key "exam_questions", "questions"
  add_foreign_key "exam_sections", "exam_templates"
  add_foreign_key "exams", "exam_templates"
  add_foreign_key "learning_objectives", "topic_modules"
  add_foreign_key "learning_objectives", "topics"
  add_foreign_key "marking_steps", "questions"
  add_foreign_key "question_learning_objectives", "learning_objectives"
  add_foreign_key "question_learning_objectives", "questions"
  add_foreign_key "questions", "sources"
  add_foreign_key "questions", "topic_modules"
  add_foreign_key "questions", "topics"
  add_foreign_key "section_question_rules", "exam_sections"
  add_foreign_key "section_question_rules", "questions"
  add_foreign_key "section_source_rules", "exam_sections"
  add_foreign_key "topic_modules", "topics"
  add_foreign_key "topics", "topics", column: "parent_topic_id"
end
