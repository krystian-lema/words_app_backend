class UsersController < ApplicationController
	before_action :find_user
	
	def create
		@user = User.new(user_create_params)
	  if @user.save
			session[:user_id] = @user.id
	  	render json: {success: true, user: @user }
	  else
	  	render json: {success: false, error: @user.errors.full_messages.first }
	  end
	end

	def change_username
		update_user(user_change_username_params)
	end

	def change_email
		update_user(user_change_email_params)
	end

	def change_password
		@user.validate_password = true
		update_user(user_change_password_params)
	end

	def update_user(params)
		if @user.present?
			if @user.update(params)
				render json: {success: true, user: @user }
			else
				render json: {success: false, error: @user.errors.full_messages.first }
			end
		else
			render json: {success: false, error: @user.errors.full_messages.first }
		end
	end

	def destroy
		if @user.present?
			@user.destroy
			render json: {success: true }
		else
			render json: {success: false, error: @user.errors.full_messages.first }
		end
	end

private

	def find_user
    if User.where(:id => session[:user_id]).blank?
      @user = nil
    else
      @user = User.find(session[:user_id])
    end
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

end
