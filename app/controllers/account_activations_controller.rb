# frozen_string_literal: true

class AccountActivationsController < ApplicationController
  def edit
    p params
    user = User.find_by(email: params[:email])

    if user&.activated? && user&.authenticated?(:activation, params[:id])
      user.update_attribute(:activated, true)
      user.update_attribute(:activated_at, Time.zone.now)
      redirect_to 'https://takashiii-hq.com'
    else
      render json: { status: 'ERROR', message: 'invalid activation link' }
    end
  end
end
