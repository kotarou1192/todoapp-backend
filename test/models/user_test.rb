# frozen_string_literal: true

require 'test_helper'

class UserTest < ActionDispatch::IntegrationTest
  def setup
    @email = 'hoge@email.com'
    @user = User.new(id: SecureRandom.uuid,
                     name: 'hoge',
                     email: @email,
                     password: 'hogefuga')
    @user.password_digest = User.digest(@user.password)
    @user.save
    @user.update(activated: true)
  end

  test 'should be valid' do
    assert @user.valid?
  end

  test 'password should be present (nonblank)' do
    @user.password = ' ' * 6
    assert_not @user.valid?
  end

  test 'password should have a minimum length' do
    @user.password = 'a' * 5
    assert_not @user.valid?
  end

  test 'user should create' do
    user_name = 'hogefuga'
    user_email = 'hogefuga@hoge.com'
    post '/users/create', params: { name: user_name, email: user_email, password: 'hogefuga' }
    user = User.find_by(email: 'hogefuga@hoge.com')
    assert user.name == user_name
  end

  test 'user should be login' do
    post '/users/login', params: { email: @user.email, password: @user.password }
    assert Session.find_by(user_email: @email)
  end

  test 'user should be logout' do
    post '/users/login', params: { email: @user.email, password: @user.password }

    body = JSON.parse(response.body)
    token = body['token']
    post '/users/logout', params: { token: token }
    assert_not Session.find_by(user_email: @user.email)
  end

  test 'should delete user' do
    post '/users/login', params: { email: @user.email, password: @user.password }

    body = JSON.parse(response.body)
    token = body['token']
    post '/users/delete', params: { token: token, email: @email }
    assert_not User.find_by(email: @email)
  end
end
