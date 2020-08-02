# frozen_string_literal: true

class PasswordResetsController < ActionController::Base
  before_action :get_user,         only: %i[edit update]
  before_action :valid_user,       only: %i[edit update]
  before_action :check_expiration, only: %i[edit update]

  def new; end

  def create
    @user = User.find_by(email: params[:password_reset][:email].downcase)
    if @user
      @user.create_reset_digest
      @user.send_password_reset_email
      flash[:info] = 'Email sent with password reset instructions'
      redirect_to 'https://takashiii-hq.com'
    else
      flash.now[:danger] = 'Email address not found'
      render 'new'
    end
  end

  def edit; end

  def update
    return render :edit if params[:user][:password].empty?

    if @user.update(user_params)
      flash[:success] = 'password has been reset'
      redirect_to 'https://takashiii-hq.com'
    else
      render :edit
    end
  end

  private

  def user_params
    params.require(:user).permit(:password)
  end

  def get_user
    p @user = User.find_by(email: params[:email])
  end

  # 有効なユーザーかどうか確認する
  def valid_user
    p params[:id]
    p @user.activated?
    p @user.reset_digest
    p BCrypt::Password.new(@user.reset_digest).is_password?(params[:id])
    p @user.authenticated?(:reset, params[:id])
    unless @user&.activated? &&
           @user&.authenticated?(:reset, params[:id])
      redirect_to 'https://takashiii-hq.com'
    end
  end

  # トークンが期限切れかどうか確認する
  def check_expiration
    return unless @user.password_reset_expired?

    flash[:danger] = 'Password reset has expired.'
    redirect_to new_password_reset_url
  end
end
