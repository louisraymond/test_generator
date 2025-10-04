module MarkdownHelper
  # Very small, safe markdown renderer supporting inline code and fenced code blocks.
  # We deliberately avoid adding a gem here; expand later if needed.
  def render_markdown(md)
    text = md.to_s.dup

    # Convert fenced code blocks. Be lenient about leading spaces and trailing spaces.
    # Matches lines like:  ```ruby\n...\n```
    block_re = /(^[ \t]*```([\w+-]*)[ \t]*\r?\n)(.*?)(^[ \t]*```[ \t]*\r?$)/m
    text = text.gsub(block_re) do
      lang = Regexp.last_match(2)
      code = Regexp.last_match(3)
      %(<pre class="md-code"><code class="language-#{lang}">#{ERB::Util.html_escape(code)}</code></pre>)
    end

    # Inline code `code`
    text.gsub!(/`([^`]+)`/) { %(<code class="md-inline">#{ERB::Util.html_escape($1)}</code>) }

    # Paragraphs and line breaks
    html = text.split(/\n{2,}/).map { |para| "<p>#{para.gsub(/\n/, '<br>')}</p>" }.join

    sanitize(html, tags: %w[p br pre code strong em a ul ol li span], attributes: %w[class href])
  end
end
