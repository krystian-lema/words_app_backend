class SessionsController < ApplicationController
  protect_from_forgery with: :null_session

  def create
    user = User.find_by_username(params[:username])
    if user && user.authenticate(params[:password])
      user.regenerate_auth_token
      render json: { success: true, data: { user: user }, auth_token: user.auth_token }
    else
      render json: { success: false, error: 'Invalid username or password' }
    end
  end

  def destroy
    user.auth_token = nil
    render json: { success: true }
  end
end
