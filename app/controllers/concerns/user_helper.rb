# frozen_string_literal: true

module UserHelper
  extend ActiveSupport::Concern
  DAY_LIMIT = 2

  def token_valid?(token)
    session = Session.find_by(token: secure_token(token))
    return false unless session

    elapsed_time = (Time.now - session.created_at) / 86_400

    return false if elapsed_time > DAY_LIMIT

    true
  end

  def update_user_params(user)
    required_params = params.permit(:name, :email, :password)
    user.update(required_params)
  end

  def generate_access_token(user)
    delete_old_sessions(user.email)
    loop do
      @token = User.new_token
      @token_digest = secure_token(@token)
      break unless Session.find_by(token: @token_digest)
    end
    session = Session.new(token: @token_digest,
                          user_email: user.email.downcase,
                          user_name: user.name)
    return @token if session.save

    nil
  end

  def secure_token(token)
    User.digest(token)
  end

  def delete_old_sessions(email)
    sessions = Session.where(user_email: email.downcase)

    return if sessions.empty?

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
