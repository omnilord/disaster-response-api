module ExceptionHandlers
  extend ActiveSupport::Concern

  included do
    unless Rails.env.development?
      rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
      rescue_from ActionController::RoutingError, with: :render_not_found
    end
  end

  def not_found
    raise ActionController::RoutingError.new('Not Found')
  end

  def render_not_found
    respond_to do |f|
      f.html { render file: Rails.root.join(*%w[public 404.html]),  status: :not_found }
      f.json { render json: { error: '404 not found' }, status: :not_found }
      f.any { render text: '404 not found', status: :not_found }
    end
  end
end
