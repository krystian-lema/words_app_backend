class SessionsController < ApplicationController
  protect_from_forgery with: :null_session

  def create
    user = User.find_by_username(params[:username])
    if user && user.authenticate(params[:password])
      user.regenerate_auth_token
      response.headers['auth-token'] = user.auth_token
      render json: { success: true, data:  user }
      # render_response(true, nil, { user: user })
    else
      # render json: { success: false, error: 'Invalid username or password' }
      render_response(false, 'Invalid username or password', nil)
    end
  end

  def destroy
    user.auth_token = nil
    render json: { success: true }
  end
end
