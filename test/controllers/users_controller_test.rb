require 'test_helper'
require 'users_controller'

class UsersControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:one)
  end

  test 'create new user' do
    assert_difference('User.count', 1, 'User should be created') do
      post '/users', params: { username: 'newuser', email: 'newuser@email.com',
                               password: 'password', password_confirmation: 'password' }
    end

    json_response = ActiveSupport::JSON.decode @response.body
    assert_equal true, json_response['success'], json_response['error']
  end

  test 'try to create user passing two different passwords' do
    assert_no_difference('User.count', 'User should not be created.') do
      post '/users', params: { username: 'newuser', email: 'newuser@email.com',
                               password: 'password', password_confirmation: 'badpassword' }
    end

    json_response = ActiveSupport::JSON.decode @response.body
    assert_equal false, json_response['success'], json_response['error']
    assert_equal "Password confirmation doesn't match Password", json_response['error']
  end

  test 'try to create user passing too short password' do
    assert_no_difference('User.count', 'User should not be created.') do
      post '/users', params: { username: 'newuser', email: 'newuser@email.com',
                               password: 'pass', password_confirmation: 'pass' }
    end

    json_response = ActiveSupport::JSON.decode @response.body
    assert_equal false, json_response['success']
    assert_equal 'Password is too short (minimum is 8 characters)', json_response['error']
  end

  test 'try to create user with existing username' do
    assert_difference('User.count', 1, 'User should be created') do
      post '/users', params: { username: 'newuser', email: 'newuser@email.com',
                               password: 'password', password_confirmation: 'password' }
    end

    assert_no_difference('User.count', 'User should not be created.') do
      post '/users', params: { username: 'newuser', email: 'newuser@email.com',
                               password: 'password', password_confirmation: 'password' }
    end

    json_response = ActiveSupport::JSON.decode @response.body
    assert_equal false, json_response['success'], json_response['error']
    assert_equal 'Username has already been taken', json_response['error']
  end

  test 'login' do
    post '/login', params: { username: @user.username, password: 'password' }
    json_response = ActiveSupport::JSON.decode @response.body
    assert_equal true, json_response['success'], json_response['error']
    assert_equal @response.headers['auth-token'], @user.reload.auth_token
  end

  test 'should not login' do
    post '/login', params: { username: @user.username, password: 'badpassword' }
    json_response = ActiveSupport::JSON.decode @response.body
    assert_equal false, json_response['success'], json_response['error']
    assert_equal 'Invalid username or password', json_response['error']
  end

  test 'change username' do
    token = login_as_user
    old_username = @user.username
    new_username = 'updated'
    patch '/change_username', params: { username: new_username }, headers: { 'auth-token' => token }

    json_response = ActiveSupport::JSON.decode @response.body
    assert_equal true, json_response['success'], json_response['error']
    assert_not_equal old_username, @user.reload.username
  end

  test 'should not change username' do
    token = login_as_user
    old_username = @user.username
    new_username = 'updated'
    patch '/change_username', params: { username: new_username }

    json_response = ActiveSupport::JSON.decode @response.body
    assert_equal false, json_response['success'], json_response['error']
    assert_equal old_username, @user.reload.username
  end

  test 'change email' do
    token = login_as_user
    old_email = @user.email
    new_email = 'updated@email.com'
    patch '/change_email', params: { email: new_email }, headers: { 'auth-token' => token }

    json_response = ActiveSupport::JSON.decode @response.body
    assert_equal true, json_response['success'], json_response['error']
    assert_not_equal old_email, @user.reload.email
  end

  test 'should not change email' do
    token = login_as_user
    old_email = @user.email
    new_email = 'updated@email.com'
    patch '/change_email', params: { email: new_email }

    json_response = ActiveSupport::JSON.decode @response.body
    assert_equal false, json_response['success'], json_response['error']
    assert_equal old_email, @user.reload.email
  end

  test 'change password' do
    token = login_as_user
    old_password = @user.password_digest
    new_password = 'new123pass'
    patch '/change_password', params: { password: new_password, password_confirmation: new_password }, headers: { 'auth-token' => token }

    json_response = ActiveSupport::JSON.decode @response.body
    assert_equal true, json_response['success'], json_response['error']
    assert_not_equal old_password, @user.reload.password_digest
  end

  test 'should not change password' do
    token = login_as_user
    old_password = @user.password_digest
    new_password = 'new123pass'
    patch '/change_password', params: { password: new_password, password_confirmation: new_password }

    json_response = ActiveSupport::JSON.decode @response.body
    assert_equal false, json_response['success'], json_response['error']
    assert_equal old_password, @user.reload.password_digest
  end

  test 'delete user' do
    token = login_as_user
    assert_difference('User.count', -1, 'User should be deleted') do
      delete '/users', headers: { 'auth-token' => token }
    end
    json_response = ActiveSupport::JSON.decode @response.body
    assert_equal true, json_response['success']
  end

  test 'should not delete user' do
    token = login_as_user
    assert_difference('User.count', 0, 'User should not be deleted') do
      delete '/users'
    end
    json_response = ActiveSupport::JSON.decode @response.body
    assert_equal false, json_response['success']
  end
end
