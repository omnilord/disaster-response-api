module ApplicationHelper
  def flash_class(level)
    case level.to_sym
    when :success then 'alert alert-success'
    when :warn then 'alert alert-warning'
    when :warning then 'alert alert-warning'
    when :error then 'alert alert-error'
    when :alert then 'alert alert-error'
    else 'alert alert-info'
    end
  end
end
