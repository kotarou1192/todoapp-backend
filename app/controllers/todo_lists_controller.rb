# frozen_string_literal: true

# 注意：ユーザーネームとあるが、実際はメールアドレスで管理している

class TodoListsController < ApplicationController
  DAY_LIMIT = 2

  def create
    return render json: { status: 'NOT_LOGIN' } unless login?

    todo = TodoList.new(todo_params)
    todo[:userName] = user_email
    todo[:user_id] = find_user_id(todo.userName)
    if todo.save
      render json: { status: 'SUCCESS', data: todo }
    else
      render json: { status: 'ERROR', data: todo.errors }
    end
  end

  def update
    return render json: { status: 'NOT_LOGIN' } unless login?

    user_name = user_email
    todo = TodoList.find(requested_todo[:id])
    return unless todo[:userName] == user_name

    if todo.update(isDone: !todo[:isDone])
      render json: { status: 'SUCCESS', message: 'update the todo', data: todo }
    else
      render json: { status: 'ERROR', message: 'update failed', data: todo.errors }
    end
  end

  def index
    return render json: { status: 'NOT_LOGIN' } unless login?

    user_name = user_email
    todos = TodoList.order(:id).where(userName: user_name)
    return render json: { status: 'SUCCESS', message: 'empty' } if todos.empty?
    return unless todos[0][:userName] == user_name

    render json: { status: 'SUCCESS', message: 'Load the todo', data: todos }
  end

  def destroy
    return render json: { status: 'NOT_LOGIN' } unless login?

    user_name = user_email
    todo = TodoList.find(requested_todo[:id])

    return unless todo[:userName] == user_name

    if todo.destroy
      render json: { status: 'SUCCESS',
                     message: 'the todo is deleted successfly' }
    else
      render json: { status: 'ERROR', data: todo.errors }
    end
  end

  private

  def find_user_id(email)
    user = User.find_by(email: email)
    user.id
  end

  def todo_params
    required = params.require(:todo).permit(:text, :deadline)
    required[:deadline] = Time.at(Time.at(required[:deadline]).getutc)

    required
  end

  def requested_todo
    params.permit(:id)
  end

  def user_email
    token = params.permit(:token)[:token]
    session = Session.find_by(token: token)

    session.user_email
  end

  def login?
    token = params.permit(:token)[:token]
    token_valid?(token)
  end

  def token_valid?(token)
    session = Session.find_by(token: token)
    return false unless session

    elapsed_time = (Time.now - session.created_at) / 86_400

    return false if elapsed_time > DAY_LIMIT

    true
  end

  def delete_old_sessions(email)
    sessions = Session.where(user_email: email.downcase)

    ActiveRecord::Base.transaction do
      sessions.each(&:destroy!)
    end
  end
end
