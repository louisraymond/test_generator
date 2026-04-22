# frozen_string_literal: true

require 'rails_helper'

# Pin specs for Phase 0 foundation assets: design tokens, paper.css, self-hosted
# fonts. These are static-file assertions — they break loudly if someone renames
# a token or drops a font file, which both cascade into visual regressions.
RSpec.describe 'Design tokens & font manifest' do
  let(:stylesheets) { Rails.root.join('app/assets/stylesheets') }
  let(:fonts)       { Rails.root.join('app/assets/fonts') }

  describe 'tokens.css (app-level palette)' do
    let(:css) { File.read(stylesheets.join('tokens.css')) }

    it 'exposes the terracotta app accent' do
      expect(css).to include('--accent: #b4532a')
    end

    it 'exposes the warm paper background' do
      expect(css).to include('--paper: #f7f4ee')
    end

    it 'names the three font families used by the app chrome' do
      expect(css).to match(/--sans:\s*'Inter'/)
      expect(css).to match(/--serif:\s*'Fraunces'/)
      expect(css).to match(/--mono:\s*'JetBrains Mono'/)
    end
  end

  describe 'paper.css (PDF stock)' do
    let(:css) { File.read(stylesheets.join('paper.css')) }

    it 'uses the printed maroon accent (darker than on-screen)' do
      expect(css).to include('--accent: #7a1d1a')
    end

    it 'declares A4 @page with zero margin (the .paper block owns the inset)' do
      expect(css).to match(/@page\s*\{[^}]*size:\s*A4/m)
      # `@page` margin is 0 by design — stacking a second margin on top
      # of the .paper element's own padding would force each .paper to
      # overflow into a ghost second page holding only the absolute-
      # positioned runfoot. See paper.css for full context.
      expect(css).to match(/@page\s*\{[^}]*margin:\s*0/m)
    end

    it 'sizes the .paper box to A4 in mm (avoids Chromium sub-pixel drift)' do
      expect(css).to include('width: 210mm')
      expect(css).to include('height: 297mm')
    end

    it 'does not @import Google Fonts (fonts are self-hosted)' do
      expect(css).not_to include('fonts.googleapis.com')
    end
  end

  describe 'fonts.css (@font-face manifest)' do
    let(:css) { File.read(stylesheets.join('fonts.css')) }

    %w[Inter Fraunces Cormorant\ Garamond JetBrains\ Mono Source\ Sans\ 3].each do |family|
      it "declares @font-face rules for #{family}" do
        expect(css).to include("font-family: '#{family}'")
      end
    end

    it 'points every src at a local /assets/fonts/*.woff2 path' do
      srcs = css.scan(/src:\s*url\(([^)]+)\)/).flatten
      expect(srcs).not_to be_empty
      srcs.each do |src|
        expect(src).to match(%r{/assets/fonts/[\w-]+\.woff2}),
                       "expected local font path, got #{src}"
      end
    end

    it 'uses font-display: block so Grover does not snapshot fallback glyphs' do
      expect(css).to include('font-display: block')
    end
  end

  describe 'self-hosted font files' do
    required = %w[
      inter-400 inter-500 inter-600 inter-700
      fraunces-400 fraunces-500 fraunces-600
      cormorant-400 cormorant-500 cormorant-600 cormorant-400i cormorant-500i
      jetbrains-400 jetbrains-500
      source-sans-400 source-sans-500 source-sans-600 source-sans-700
    ]

    required.each do |slug|
      it "has app/assets/fonts/#{slug}.woff2" do
        path = Rails.root.join('app/assets/fonts', "#{slug}.woff2")
        expect(path).to exist
        expect(path.size).to be > 1_000, "#{slug}.woff2 looks truncated"
      end
    end
  end

  describe 'pdf.html.erb layout' do
    let(:erb) { File.read(Rails.root.join('app/views/layouts/pdf.html.erb')) }

    it 'loads the new tokens/paper/fonts stylesheets inline' do
      %w[tokens.css paper.css fonts.css].each do |name|
        expect(erb).to include(name), "expected pdf.html.erb to inline #{name}"
      end
    end
  end
end
