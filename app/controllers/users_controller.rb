# frozen_string_literal: true

class UsersController < ApplicationController
  DAY_LIMIT = 2

  def create
    user = User.new(user_params)
    user.id = generate_uuid
    if user.save
      login
    else
      render json: { status: 'ERROR', message: 'create user failed', error: user.errors }
    end
  end

  def login
    user = User.find_by(email: user_params[:email].downcase)
    unless user
      return render json: { status: 'ERROR', message: 'invalid email address' }
    end

    if user&.authenticate(user_params[:password])
      delete_old_sessions(user_params[:email])
      token = generate_access_token(user)
      render json: { status: 'SUCCESS', message: 'login success', token: token }
    else
      render json: { status: 'ERROR', message: 'failed to authenticate' }
    end
  end

  def update
    user = User.find_by(email: user_params[:email].downcase)
    session = Session.find_by(token: secure_token(user_token))
    unless user && session
      return render json: { status: 'ERROR', message: 'invalid parameters' }
    end

    unless token_valid?(user_token)
      delete_old_sessions(user_params[:email])
      return render json: { status: 'OLD_TOKEN', message: 'please re-login' }
    end

    if user.email == session.user_email && update_user_params(user)
      render json: { status: 'SUCCESS', message: 'updated the user' }
    else
      render json: { status: 'ERROR', message: 'failed to authenticate' }
    end
  end

  def logout
    session = Session.find_by(token: secure_token(user_token))
    user = User.find_by(email: session[:user_email].downcase)
    unless user && session
      return render json: { status: 'ERROR', message: 'invalid parameters' }
    end

    delete_old_sessions(user[:email])
    render json: { status: 'SUCCESS', message: 'logout success' }
  end

  def destroy
    user = User.find_by(email: user_params[:email].downcase)
    session = Session.find_by(token: secure_token(user_token))
    unless user && session
      return render json: { status: 'ERROR', message: 'invalid parameters' }
    end

    unless token_valid?(user_token)
      delete_old_sessions(user_params[:email])
      return render json: { status: 'OLD_TOKEN', message: 'please re-login' }
    end

    if user.email == session.user_email
      user.destroy
      render json: { status: 'SUCCESS', message: 'deleted the user' }
    else
      render json: { status: 'ERROR', message: 'failed to authenticate' }
    end
  end

  private

  def token_valid?(token)
    session = Session.find_by(token: secure_token(token))
    return false unless session

    elapsed_time = (Time.now - session.created_at) / 86_400

    return false if elapsed_time > DAY_LIMIT

    true
  end

  def user_params
    params.permit(:name, :email, :password)
  end

  def user_token
    params.permit(:token)[:token]
  end

  def update_user_params(user)
    required_params = params.permit(:name, :email, :password)
    user.update(required_params)
  end

  def generate_access_token(user)
    delete_old_sessions(user.email)
    loop do
      @token = SecureRandom.hex(64)
      break unless Session.find_by(token: secure_token(@token))
    end
    session = Session.new(token: secure_token(@token),
                          user_email: user.email.downcase,
                          user_name: user.name)
    return @token if session.save

    nil
  end

  def secure_token(token)
    token.crypt('secret_key')
  end

  def delete_old_sessions(email)
    sessions = Session.where(user_email: email.downcase)

    ActiveRecord::Base.transaction do
      sessions.each(&:destroy!)
    end
  end

  def generate_uuid
    loop do
      @uuid = SecureRandom.uuid
      break unless User.find_by(id: @uuid)
    end
    @uuid
  end
end
