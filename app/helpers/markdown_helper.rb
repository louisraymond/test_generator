module MarkdownHelper
  # Very small, safe markdown renderer supporting inline code and fenced code blocks.
  # We deliberately avoid adding a gem here; expand later if needed.
  def render_markdown(md)
    text = md.to_s.dup

    # Convert fenced code blocks ```lang\n...\n```
    text.gsub!(/```([\w+-]*)\n([\s\S]*?)```/) do
      lang = Regexp.last_match(1)
      code = ERB::Util.html_escape(Regexp.last_match(2))
      %(<pre class="md-code"><code class="language-#{lang}">#{code}</code></pre>)
    end

    # Inline code `code`
    text.gsub!(/`([^`]+)`/) { %(<code class="md-inline">#{ERB::Util.html_escape($1)}</code>) }

    # Paragraphs and line breaks
    html = text.split(/\n{2,}/).map { |para| "<p>#{para.gsub(/\n/, '<br>')}</p>" }.join

    sanitize(html, tags: %w[p br pre code strong em a ul ol li span], attributes: %w[class href])
  end
end

