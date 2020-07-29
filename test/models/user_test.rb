# frozen_string_literal: true

require 'test_helper'

class UserTest < ActiveSupport::TestCase
  def setup
    @user = User.new(id: SecureRandom.uuid,
                     name: 'hoge',
                     email: 'hoge@email.com',
                     password: 'hogefuga',
                     password_confirmation: 'hogefuga')
  end

  test 'should be valid' do
    assert @user.valid?
  end

  test 'password should be present (nonblank)' do
    @user.password = @user.password_confirmation = ' ' * 6
    assert_not @user.valid?
  end

  test 'password should have a minimum length' do
    @user.password = @user.password_confirmation = 'a' * 5
    assert_not @user.valid?
  end
end
