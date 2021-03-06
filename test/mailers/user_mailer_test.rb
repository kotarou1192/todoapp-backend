# frozen_string_literal: true

require 'test_helper'

class UserMailerTest < ActionMailer::TestCase
  def setup
    @user = User.new(id: SecureRandom.uuid,
                     name: 'hoge',
                     email: 'hoge@email.com',
                     password: 'hogefuga')
    @user.reset_token = User.new_token
    @user.password_digest = User.digest(@user.password)
    @user.save
  end
  test 'account_activation' do
    mail = UserMailer.account_activation(@user)
    assert_equal 'Account activation', mail.subject
    assert_equal [@user.email], mail.to
    assert_equal ['noreply@example.com'], mail.from
    # assert_match 'ようこそ', mail.body.encoded
  end

  test 'password_reset' do
    mail = UserMailer.password_reset(@user)
    assert_equal 'Password reset', mail.subject
    assert_equal [@user.email], mail.to
    assert_equal ['noreply@example.com'], mail.from
    # assert_match 'Hi', mail.body.encoded
  end
end
