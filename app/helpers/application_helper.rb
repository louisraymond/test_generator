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
end
