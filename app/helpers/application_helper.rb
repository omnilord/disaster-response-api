module ApplicationHelper
  def flash_class(level)
    case level.to_sym
    when :success then 'alert alert-success'
    when :warn, :warning then 'alert alert-warning'
    when :error, :danger, :alert then 'alert alert-danger'
    else 'alert alert-info'
    end
  end

  def conf
    Rails.configuration
  end

  def event_disaster_type_options(selected = nil)
    options_for_select(Event.disaster_types.map { |k, v| [v.humanize.capitalize, k] }, selected: selected)
  end

  def render_markdown(text)
    #<% markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, autolink: true, tables: true) %>
    #<td><%= sanitize(markdown.render(question.content), tags: ALLOWED_HTML_TAGS, attributes: ALLOWED_HTML_ATTRIBUTES).html_safe %></td>
    @markdown ||= Redcarpet::Markdown.new(Redcarpet::Render::HTML, autolink: true, tables: true)
    sanitize(@markdown.render(text), tags: ALLOWED_HTML_TAGS, attributes: ALLOWED_HTML_ATTRIBUTES).html_safe
  end
end
