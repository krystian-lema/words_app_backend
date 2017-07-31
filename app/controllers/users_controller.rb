class UsersController < ApplicationController
  before_action :authenticate, except: :create

  def create
    @user = User.new(user_create_params)
    if @user.save
      session[:user_id] = @user.id
      render json: { success: true, user: @user }
    else
      render json: { success: false, error: @user.errors.full_messages.first }
     end
  end

  def change_username
    update_user(user_change_username_params)
  end

  def change_email
    update_user(user_change_email_params)
  end

  def change_password
    @user.validate_password = true if @user.present?
    update_user(user_change_password_params)
  end

  def update_user(params)
    if @user.present?
      if @user.update(params)
        render json: { success: true, user: @user, auth_token: updated_auth_token }
      else
        render json: { success: false, error: @user.errors.full_messages.first }
      end
    else
      render_auth_problem
    end
  end

  def destroy
    if @user.present?
      @user.destroy
      render json: { success: true }
    else
      render_auth_problem
    end
  end

  private

  def authenticate
    token = params['auth_token']
    if token.present?
      @user = if User.where(auth_token: token).blank?
                nil
              else
                User.find_by(auth_token: token)
              end
    end
  end

  def render_auth_problem
    render json: { success: false, error: 'Bad credendials' }, status: 401
  end

  def updated_auth_token
    @user.regenerate_auth_token
    @user.auth_token
  end

  def user_create_params
    params.require(:user).permit(:username, :email, :password, :password_confirmation)
  end

  def user_change_username_params
    params.require(:user).permit(:username)
  end

  def user_change_email_params
    params.require(:user).permit(:email)
  end

  def user_change_password_params
    params.require(:user).permit(:password, :password_confirmation)
  end

  def get_parsed_body
    request.body.rewind
    request_body = request.body.read
    request_body = '{}' if request_body.empty?
    parsed_body = JSON.parse(request_body)
    parsed_body
  end
end
