# frozen_string_literal: true

class AddColumnToTodoLists < ActiveRecord::Migration[6.0]
  def up
    add_column :todo_lists, :user_id, :string
  end

  def down
    remove_column :todo_lists, :user_id, :string
  end
end
