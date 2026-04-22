require 'rails_helper'

RSpec.describe MarkdownHelper, type: :helper do
  describe '#render_markdown with LaTeX' do
    it 'does not convert ^ inside $...$ into <sup>' do
      # red-team-found bug: Redcarpet's superscript extension was mangling
      # `D^c` inside math into `D<sup>c</sup>`, breaking KaTeX on seeded Q10.
      result = helper.render_markdown('Compute $P(-\mid D^c) = 0.95$.')
      expect(result).to include('$P(-\\mid D^c) = 0.95$')
      expect(result).not_to match(/\$[^\$]*<sup>/)
    end

    it 'does not convert ^ inside $$...$$ display math into <sup>' do
      result = helper.render_markdown('$$\lVert \mathbf{x} \rVert^2 + y^2$$')
      expect(result).to include('\rVert^2')
      expect(result).not_to include('<sup>')
    end

    it 'still applies superscript to plain-text carets outside math' do
      # Existing non-maths seeds rely on Redcarpet turning `QK^T` into `QK<sup>T</sup>`.
      result = helper.render_markdown('Attention uses QK^T scores.')
      expect(result).to include('<sup>T</sup>')
    end

    it 'preserves underscores inside $...$ (subscripts)' do
      result = helper.render_markdown('Let $x_1$ and $x_2$ be roots.')
      expect(result).to include('$x_1$')
      expect(result).to include('$x_2$')
      expect(result).not_to include('<em>')
    end
  end

  describe '#render_markdown_inline with LaTeX' do
    it 'does not wrap underscores inside $...$ in <em>' do
      # red-team-found bug: `$a_1 * b_1$` was mangled into `$a<em>1 * b</em>1$`
      result = helper.render_markdown_inline('Given $a_1 * b_1$ compute the sum.')
      expect(result).to include('$a_1 * b_1$')
      expect(result).not_to match(/\$a<em>/)
    end

    it 'does not wrap asterisks inside $...$ in <strong> or <em>' do
      result = helper.render_markdown_inline('Let $f(x) = x^2 * g(x)$.')
      expect(result).to include('$f(x) = x^2 * g(x)$')
      expect(result).not_to include('<em>')
      expect(result).not_to include('<strong>')
    end

    it 'still applies inline bold/italic outside math' do
      result = helper.render_markdown_inline('This is **bold** and $x^2$ and _italic_.')
      expect(result).to include('<strong>bold</strong>')
      expect(result).to include('<em>italic</em>')
      expect(result).to include('$x^2$')
    end

    it 'handles display math $$...$$ without touching contents' do
      result = helper.render_markdown_inline('Display: $$a_1 + b_2 * c_3$$ end.')
      expect(result).to include('$$a_1 + b_2 * c_3$$')
      expect(result).not_to include('<em>')
    end

    it 'preserves math with unmatched dollar as plain text without crashing' do
      expect { helper.render_markdown_inline('An odd $ sign here') }.not_to raise_error
    end
  end

  describe '#auto_wrap_math (reverted — no-op identity)' do
    it 'returns text unchanged' do
      text = 'H(P, Q) = −Σ P(x) log Q(x). θ > 0.'
      expect(helper.auto_wrap_math(text)).to eq(text)
    end
  end
end
