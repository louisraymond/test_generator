require 'rails_helper'

RSpec.describe 'API /api/exam_templates', type: :request do
  let!(:topic) { create(:topic, name: 'API ExamTemplates Topic') }
  let!(:topic_module) { create(:topic_module, topic: topic, name: 'API ETM') }

  # 14 MCQ + 8 written + 4 composite = 26 hand-crafted questions
  let!(:mcq_questions) do
    14.times.map do |i|
      create(:question, :multiple_choice, topic: topic, topic_module: topic_module,
                                          content: "MCQ #{i}")
    end
  end
  let!(:written_questions) do
    8.times.map do |i|
      create(:question, topic: topic, topic_module: topic_module,
                        content: "Written #{i}", question_type: 'written')
    end
  end
  let!(:composite_questions) do
    4.times.map do |i|
      create(:question, :composite, topic: topic, topic_module: topic_module,
                                    content: "Composite #{i}")
    end
  end

  def template_payload(name: 'Three-section template')
    {
      exam_template: {
        name: name,
        description: 'Sections A/B/C',
        duration_minutes: 90,
        exam_sections_attributes: [
          {
            name: 'Section A — Recognition',
            position: 0,
            question_count: 14,
            question_type_filter: ['multiple_choice'],
            section_source_rules_attributes: [
              { source_type: 'TopicModule', source_id: topic_module.id, weight: 1 }
            ],
            section_question_rules_attributes: mcq_questions.map { |q|
              { question_id: q.id, rule_type: 'force_include' }
            }
          },
          {
            name: 'Section B — Comprehension',
            position: 1,
            question_count: 8,
            question_type_filter: ['written'],
            section_source_rules_attributes: [
              { source_type: 'TopicModule', source_id: topic_module.id, weight: 1 }
            ],
            section_question_rules_attributes: written_questions.map { |q|
              { question_id: q.id, rule_type: 'force_include' }
            }
          },
          {
            name: 'Section C — Application & Synthesis',
            position: 2,
            question_count: 4,
            question_type_filter: ['composite'],
            section_source_rules_attributes: [
              { source_type: 'TopicModule', source_id: topic_module.id, weight: 1 }
            ],
            section_question_rules_attributes: composite_questions.map { |q|
              { question_id: q.id, rule_type: 'force_include' }
            }
          }
        ]
      }
    }
  end

  describe 'POST /api/exam_templates' do
    it 'creates a template with nested sections and rules (201)' do
      expect {
        post '/api/exam_templates',
             params: template_payload.to_json,
             headers: { 'CONTENT_TYPE' => 'application/json' }
      }.to change(ExamTemplate, :count).by(1)
        .and change(ExamSection, :count).by(3)
        .and change(SectionQuestionRule, :count).by(26)
        .and change(SectionSourceRule, :count).by(3)

      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)
      expect(json['id']).to be_present
      expect(json['name']).to eq('Three-section template')
      expect(json['exam_sections'].size).to eq(3)
      expect(json['exam_sections'].first['section_question_rules'].size).to eq(14)
    end

    it 'returns 422 when a force_include question_type does not match the section filter' do
      payload = template_payload(name: 'Bad type filter')
      payload[:exam_template][:exam_sections_attributes][0][:section_question_rules_attributes] = [
        { question_id: written_questions.first.id, rule_type: 'force_include' }
      ]

      expect {
        post '/api/exam_templates',
             params: payload.to_json,
             headers: { 'CONTENT_TYPE' => 'application/json' }
      }.not_to change(ExamTemplate, :count)

      expect(response).to have_http_status(:unprocessable_entity)
      json = JSON.parse(response.body)
      expect(json['error']).to match(/question.*type|type.*filter/i)
    end

    it 'returns 422 when a force_include question_id does not exist' do
      payload = template_payload(name: 'Missing question')
      payload[:exam_template][:exam_sections_attributes][0][:section_question_rules_attributes] = [
        { question_id: 99_999_999, rule_type: 'force_include' }
      ]

      post '/api/exam_templates',
           params: payload.to_json,
           headers: { 'CONTENT_TYPE' => 'application/json' }

      expect(response).to have_http_status(:unprocessable_entity)
      json = JSON.parse(response.body)
      expect(json['error']).to match(/question.*99999999.*not.*found/i)
    end
  end

  describe 'GET /api/exam_templates/:id' do
    it 'returns the full nested structure' do
      post '/api/exam_templates',
           params: template_payload(name: 'For show').to_json,
           headers: { 'CONTENT_TYPE' => 'application/json' }
      id = JSON.parse(response.body).fetch('id')

      get "/api/exam_templates/#{id}"
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['id']).to eq(id)
      expect(json['exam_sections'].size).to eq(3)
      expect(json['exam_sections'].map { |s| s['question_count'] }).to eq([14, 8, 4])
      expect(json['exam_sections'][0]['section_question_rules'].size).to eq(14)
      expect(json['exam_sections'][0]['section_source_rules'].size).to eq(1)
    end

    it 'returns 404 for an unknown id' do
      get '/api/exam_templates/99999999'
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'GET /api/exam_templates' do
    it 'returns a summary list ordered by created_at desc' do
      post '/api/exam_templates',
           params: template_payload(name: 'First').to_json,
           headers: { 'CONTENT_TYPE' => 'application/json' }
      post '/api/exam_templates',
           params: template_payload(name: 'Second').to_json,
           headers: { 'CONTENT_TYPE' => 'application/json' }

      get '/api/exam_templates'
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json).to be_an(Array)
      expect(json.map { |t| t['name'] }).to eq(['Second', 'First'])
      expect(json.first).to include('id', 'name', 'total_questions', 'sections_count')
      expect(json.first['total_questions']).to eq(26)
      expect(json.first['sections_count']).to eq(3)
    end
  end

  describe 'POST /api/exam_templates/:id/generate' do
    let(:template_id) do
      post '/api/exam_templates',
           params: template_payload(name: 'For generate').to_json,
           headers: { 'CONTENT_TYPE' => 'application/json' }
      JSON.parse(response.body).fetch('id')
    end

    it 'materialises an exam with section_number per question and preserves force_include order' do
      expect {
        post "/api/exam_templates/#{template_id}/generate",
             params: {}.to_json,
             headers: { 'CONTENT_TYPE' => 'application/json' }
      }.to change(Exam, :count).by(1)
        .and change(ExamQuestion, :count).by(26)

      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)
      expect(json['exam_id']).to be_present
      expect(json['question_count']).to eq(26)
      expect(json['pdf_url']).to be_present
      expect(json['marking_scheme_url']).to be_present

      exam = Exam.find(json['exam_id'])
      section_numbers = exam.exam_questions.order(:position).pluck(:section_number)
      expect(section_numbers).to eq([0] * 14 + [1] * 8 + [2] * 4)

      ordered_qs = exam.exam_questions.order(:position).pluck(:question_id)
      expect(ordered_qs[0...14]).to eq(mcq_questions.map(&:id))
      expect(ordered_qs[14...22]).to eq(written_questions.map(&:id))
      expect(ordered_qs[22...26]).to eq(composite_questions.map(&:id))
    end

    it 'returns 422 when force_include count exceeds question_count' do
      # Build a tighter template: question_count 14 but 15 force_include rules
      tight = template_payload(name: 'Overpin')
      tight[:exam_template][:exam_sections_attributes] = [
        tight[:exam_template][:exam_sections_attributes][0].merge(
          question_count: 13   # fewer slots than force_includes (14)
        )
      ]
      post '/api/exam_templates',
           params: tight.to_json,
           headers: { 'CONTENT_TYPE' => 'application/json' }
      expect(response).to have_http_status(:created)
      overpin_id = JSON.parse(response.body).fetch('id')

      expect {
        post "/api/exam_templates/#{overpin_id}/generate",
             params: {}.to_json,
             headers: { 'CONTENT_TYPE' => 'application/json' }
      }.not_to change(Exam, :count)

      expect(response).to have_http_status(:unprocessable_entity)
      json = JSON.parse(response.body)
      expect(json['error']).to match(/force_include.*question_count|too many force/i)
    end

    it 'fills sparse force_includes with random sampling from the pool' do
      sparse = {
        exam_template: {
          name: 'Sparse fill',
          exam_sections_attributes: [
            {
              name: 'Only A', position: 0, question_count: 5,
              question_type_filter: ['multiple_choice'],
              section_source_rules_attributes: [
                { source_type: 'TopicModule', source_id: topic_module.id, weight: 1 }
              ],
              section_question_rules_attributes: [
                { question_id: mcq_questions[0].id, rule_type: 'force_include' },
                { question_id: mcq_questions[1].id, rule_type: 'force_include' },
                { question_id: mcq_questions[13].id, rule_type: 'exclude' }
              ]
            }
          ]
        }
      }
      post '/api/exam_templates',
           params: sparse.to_json,
           headers: { 'CONTENT_TYPE' => 'application/json' }
      expect(response.status).to eq(201), "Expected 201 but got #{response.status}: #{response.body}"
      tid = JSON.parse(response.body).fetch('id')

      post "/api/exam_templates/#{tid}/generate",
           params: {}.to_json,
           headers: { 'CONTENT_TYPE' => 'application/json' }
      expect(response.status).to eq(201), "Expected 201 but got #{response.status}: #{response.body}"
      exam = Exam.find(JSON.parse(response.body).fetch('exam_id'))
      qids = exam.exam_questions.order(:position).pluck(:question_id)
      expect(qids.size).to eq(5)
      expect(qids[0]).to eq(mcq_questions[0].id)
      expect(qids[1]).to eq(mcq_questions[1].id)
      expect(qids).not_to include(mcq_questions[13].id)
    end

    it 'generated exam serves a modern paper-style PDF' do
      post "/api/exam_templates/#{template_id}/generate",
           params: {}.to_json,
           headers: { 'CONTENT_TYPE' => 'application/json' }
      exam_id = JSON.parse(response.body).fetch('exam_id')

      # Stub the PDF renderer so the spec doesn't spawn headless Chrome.
      allow(PdfRenderer).to receive(:render_to_pdf) { |args| "PDFBYTES:#{args[:html].length}" }

      get "/api/exams/#{exam_id}/pdf"
      expect(response).to have_http_status(:ok)
      expect(response.content_type).to start_with('application/pdf')
    end

    it 'returns 404 when generating from an unknown template' do
      post '/api/exam_templates/99999999/generate',
           params: {}.to_json,
           headers: { 'CONTENT_TYPE' => 'application/json' }
      expect(response).to have_http_status(:not_found)
    end
  end
end
