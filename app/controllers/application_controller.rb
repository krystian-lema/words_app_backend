class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  def current_user
    token = params['auth_token']
    @current_user ||= User.find_by(auth_token: token) if User.where(auth_token: token).present? if token.present?
  end
  helper_method :current_user

  def authorize
    render_auth_problem unless current_user
  end

  def render_auth_problem
    render json: { success: false, error: 'Bad credendials' }, status: 401
  end

  def updated_auth_token
    current_user.regenerate_auth_token if current_user
    current_user.auth_token if current_user
  end

end
