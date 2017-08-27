class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  def current_user
    token = request.headers['auth-token']
    @current_user ||= User.find_by(auth_token: token) if token.present? && User.where(auth_token: token).present?
    # @current_user ||= User.find_by(auth_token: token)
  end
  helper_method :current_user

  def authorize
    render_auth_problem unless current_user
  end

  def render_auth_problem
    render json: { success: false, error: 'Bad credendials' }, status: 401
  end

  def updated_auth_token
    user = current_user
    if user.present?
      user.regenerate_auth_token
      user.auth_token
    end
  end

  def render_response(success_value, error_message, data_value)
    response.headers['auth-token'] = updated_auth_token if success_value
    render json: { success: success_value, error: error_message, data: data_value }
  end
end
