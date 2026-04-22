require 'rails_helper'

# Wave 3 — options_patch command branches (diagram pins, occlusion masks,
# ordering reorder, code highlight). Each branch has a narrow contract the
# Stimulus controller relies on: these specs lock the wire shape in.
RSpec.describe 'PATCH /questions/:id/options_patch command branches', type: :request do
  let(:topic) { create(:topic) }

  def build(type:, options:)
    Question.create!(topic: topic, question_type: type, content: 'q', answer: 'a',
                     points: 1, options: options)
  end

  it 'add_pin appends to diagram_label pins' do
    q = build(type: 'diagram_label', options: { 'image' => '/fig.png', 'pins' => [] })
    patch "/questions/#{q.id}/options_patch",
          params: { options: { add_pin: { x: 12.5, y: 40.0 } } }.to_json,
          headers: { 'Content-Type' => 'application/json' }
    expect(response).to have_http_status(:ok)
    expect(q.reload.options['pins']).to eq([{ 'x' => 12.5, 'y' => 40.0, 'answer' => '' }])
  end

  it 'remove_pin deletes by index' do
    q = build(type: 'diagram_label', options: {
                'image' => '/f.png',
                'pins' => [{ 'x' => 1, 'y' => 1 }, { 'x' => 2, 'y' => 2 }, { 'x' => 3, 'y' => 3 }]
              })
    patch "/questions/#{q.id}/options_patch",
          params: { options: { remove_pin: 1 } }.to_json,
          headers: { 'Content-Type' => 'application/json' }
    expect(q.reload.options['pins'].length).to eq(2)
    expect(q.reload.options['pins'].first).to include('x' => 1)
  end

  it 'add_mask appends to image_occlusion masks' do
    q = build(type: 'image_occlusion', options: { 'image' => '/img.png', 'masks' => [] })
    patch "/questions/#{q.id}/options_patch",
          params: { options: { add_mask: { x: 0, y: 0, w: 20, h: 30 } } }.to_json,
          headers: { 'Content-Type' => 'application/json' }
    expect(q.reload.options['masks'].first).to include('w' => 20, 'shape' => 'rect')
  end

  it 'reorder mutates the options array in place' do
    q = build(type: 'ordering', options: [{ 'text' => 'a' }, { 'text' => 'b' }, { 'text' => 'c' }])
    patch "/questions/#{q.id}/options_patch",
          params: { options: { reorder: { from: 0, to: 2 } } }.to_json,
          headers: { 'Content-Type' => 'application/json' }
    expect(q.reload.options.map { |o| o['text'] }).to eq(%w[b c a])
  end

  it 'toggle_highlighted_line flips a line index on code_analysis' do
    q = build(type: 'code_analysis', options: {
                'language' => 'python', 'code' => "print(1)\nprint(2)",
                'answer_format' => 'lines', 'highlighted_lines' => []
              })
    patch "/questions/#{q.id}/options_patch",
          params: { options: { toggle_highlighted_line: 1 } }.to_json,
          headers: { 'Content-Type' => 'application/json' }
    expect(q.reload.options['highlighted_lines']).to eq([1])
    patch "/questions/#{q.id}/options_patch",
          params: { options: { toggle_highlighted_line: 1 } }.to_json,
          headers: { 'Content-Type' => 'application/json' }
    expect(q.reload.options['highlighted_lines']).to eq([])
  end
end
