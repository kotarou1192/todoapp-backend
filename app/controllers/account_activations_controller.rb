# frozen_string_literal: true

class AccountActivationsController < ApplicationController
  def edit
    user = User.find_by(email: params[:email])

    if user && !user.activated? && user.authenticated?(:activation, params[:id])
      user.activate
      redirect_to 'https://takashiii-hq.com'
    else
      render json: { status: 'ERROR', message: 'invalid activation link' }
    end
  end
end
