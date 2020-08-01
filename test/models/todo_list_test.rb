# frozen_string_literal: true

require 'test_helper'

class TodoListTest < ActiveSupport::TestCase
  def setup
    @user = User.new(name: 'hogehoge', password: 'hogehoge', email: 'hogehoge@hoge.com')
    @user.id = SecureRandom.uuid
    @user.save
    @todo = TodoList.new(text: 'example', userName: 'user', user_id: @user.id)
  end

  test 'should be valid' do
    assert @todo.valid?
  end

  test 'text should not be too long' do
    @todo.text = 'g' * 300
    assert_not @todo.valid?
  end
end
