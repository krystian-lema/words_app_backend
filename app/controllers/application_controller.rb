class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  def current_user
    token = params['auth_token']
    @current_user ||= User.find_by(auth_token: token) if token.present? && User.where(auth_token: token).present?
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
    else  
      nil
    end
  end
end
