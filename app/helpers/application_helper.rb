module ApplicationHelper
  include Pagy::HelperLoader

  def nav_link_to(name, path, **options)
    classes = Array(options[:class]) + ['app-nav__link']
    classes << 'is-active' if current_page?(path)
    options[:class] = classes.join(' ')
    options[:data] = (options[:data] || {}).merge(action: 'menu#close')
    link_to(name, path, **options)
  end
end
