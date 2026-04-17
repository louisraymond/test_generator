# frozen_string_literal: true

require 'rails_helper'

# Pin specs for PdfRenderer. These lock in two easily-regressed choices:
#   1) wait_until: 'networkidle0' — not 'domcontentloaded' (CDN KaTeX must settle).
#   2) Grover recognises 'display_url', not 'base_url' — the rename is load-bearing.
RSpec.describe PdfRenderer do
  describe 'DEFAULT_OPTIONS' do
    it 'waits for networkidle0 so KaTeX finishes rendering before snapshot' do
      expect(PdfRenderer::DEFAULT_OPTIONS[:wait_until]).to eq('networkidle0')
    end

    it 'emulates print media with a white background' do
      expect(PdfRenderer::DEFAULT_OPTIONS).to include(
        emulate_media: 'print',
        print_background: true
      )
    end
  end

  describe '.render_to_pdf' do
    it 'passes base_url to Grover under the display_url key (never base_url)' do
      grover = instance_double(Grover, to_pdf: '%PDF-stub')
      expect(Grover).to receive(:new) do |_html, opts|
        expect(opts).to include(display_url: 'http://test.host/')
        expect(opts).not_to have_key(:base_url)
        grover
      end

      described_class.render_to_pdf(html: '<p>x</p>', base_url: 'http://test.host/')
    end
  end
end
