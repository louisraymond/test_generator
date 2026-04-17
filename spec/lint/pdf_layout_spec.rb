# frozen_string_literal: true

require 'rails_helper'

# Pin spec: every PDF-rendering controller action must use `layout: 'pdf'`.
# The pre-existing `layout: false` bug left mark-scheme PDFs without KaTeX and
# silently shipped broken math — this grep regression catches any regression.
RSpec.describe 'PDF layout usage' do
  it 'keeps all PDF controller actions on the pdf layout' do
    controllers_root = Rails.root.join('app/controllers')
    matches = Dir[controllers_root.join('**/*.rb')].sum do |path|
      File.read(path).scan(/layout:\s*['"]pdf['"]/).length
    end

    expect(matches).to be >= 4,
      "Expected at least 4 'layout: \"pdf\"' call sites (api+web show+marking_scheme); found #{matches}"
  end

  it 'has no `layout: false` in any controller (would skip the pdf layout)' do
    controllers_root = Rails.root.join('app/controllers')
    offenders = Dir[controllers_root.join('**/*.rb')].select do |path|
      File.read(path).include?('layout: false')
    end

    expect(offenders).to be_empty,
      "Controllers still use `layout: false`: #{offenders.inspect}"
  end
end
