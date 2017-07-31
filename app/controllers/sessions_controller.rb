class SessionsController < ApplicationController

	def create
		user = User.find_by_username(params[:username])
    if user && user.authenticate(params[:password])
      session[:user_id] = user.id
      render json: { success: true }
    else
      render json: { success: false, error: "Invalid username or password" }
    end
	end

	def destroy
		session[:user_id] = nil
		render json: { success: true }
	end

end
