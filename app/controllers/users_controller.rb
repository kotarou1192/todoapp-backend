# frozen_string_literal: true

class UsersController < ApplicationController
  include UserHelper

  def create
    user = User.new(user_params)
    user.id = generate_uuid
    if user.save
      UserMailer.account_activation(user).deliver_now
      render json: { status: 'SUCCESS', message: 'acount creation success' }
    else
      render json: { status: 'ERROR', message: 'create user failed', error: user.errors }
    end
  end

  def login
    user = User.find_by(email: user_params[:email].downcase)
    unless user
      return render json: { status: 'ERROR', message: 'invalid email address' }
    end

    unless user.activated?
      render json: { status: 'ERROR', message: 'account is not activated' }
    end

    if user&.authenticated?(:password, user_params[:password])
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
    token_digest = secure_token(user_token)
    session = Session.find_by(token: token_digest)
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

  def user_params
    params.permit(:name, :email, :password)
  end

  def user_token
    params.permit(:token)[:token]
  end
end
