module ApplicationHelper
  include Pagy::HelperLoader

  # Cloze blank markers: `[[...]]` or `{{...}}`, escaped with `\[[...]]` etc. to
  # bypass (so LaTeX `\[...\]` display math survives untouched inside cloze).
  CLOZE_BLANK_PATTERN = /(?<!\\)\[\[(.+?)\]\]|(?<!\\)\{\{(.+?)\}\}/

  def nav_link_to(name, path, **options)
    classes = Array(options[:class]) + ['app-nav__link']
    classes << 'is-active' if current_page?(path)
    options[:class] = classes.join(' ')
    options[:data] = (options[:data] || {}).merge(action: 'menu#close')
    link_to(name, path, **options)
  end

  # Render a cloze question's content as safe HTML with blanks replaced by
  # `<span class="cloze-blank"></span>`. LaTeX delimiters inside the surrounding
  # prose pass through unchanged so the math controller can render them.
  def render_cloze(content)
    masked = ERB::Util.html_escape(content.to_s)
    masked.gsub!(CLOZE_BLANK_PATTERN, '<span class="cloze-blank"></span>')
    masked.html_safe
  end

  # Truncate to `length` chars without splitting a LaTeX math span.
  # Handles both `$...$` (inline) and `$$...$$` (display): if the natural cut
  # lands inside a span, we pull back to the character before that span
  # starts. Used for mark-scheme guidance previews where a mid-formula cut
  # would ship raw LaTeX to the reader.
  def truncate_without_breaking_math(text, length: 120, omission: '…')
    text_str = text.to_s
    return text_str if text_str.length <= length

    cut = length
    text_str.scan(MarkdownHelper::MATH_SPAN_PATTERN) do
      span_start, span_end = Regexp.last_match.offset(0)
      cut = span_start if span_start < cut && span_end > cut
    end

    truncated = text_str[0, cut]
    truncated.sub(/\s+\S*\z/, '') + omission
  end
end
