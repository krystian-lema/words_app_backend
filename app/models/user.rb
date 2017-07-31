class User < ApplicationRecord

	has_secure_password

	validates :username, presence: true, uniqueness: true
	validates :email, presence: true
	validates :password, presence: true, length: { minimum: 8 },  on: :create
	validates :password_confirmation, presence: true, on: :create


	validates :password, presence: true, length: { minimum: 8 },  on: :update, if: :validate_password?
	validates :password_confirmation, presence: true, on: :update, if: :validate_password?

	def validate_password?
  	validate_password == 'true' || validate_password == true
	end
	attr_accessor :validate_password

end
