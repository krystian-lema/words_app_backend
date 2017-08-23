class UsersController < ApplicationController
  protect_from_forgery with: :null_session
  before_action :authorize, except: :create

  def create
    @user = User.new(user_create_params)
    if @user.save
      session[:user_id] = @user.id
      render json: { success: true, data: { user: @user } }
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
    if current_user.update(params)
      render json: { success: true, data: { user: current_user }, auth_token: updated_auth_token }
    else
      render json: { success: false, error: current_user.errors.full_messages.first, auth_token: updated_auth_token }
    end
  end

  def destroy
    current_user.destroy
    render json: { success: true }
  end

  private

  def user_create_params
    params.permit(:username, :email, :password, :password_confirmation)
  end

  def user_change_username_params
    params.permit(:username)
  end

  def user_change_email_params
    params.permit(:email)
  end

  def user_change_password_params
    params.permit(:password, :password_confirmation)
  end
end
