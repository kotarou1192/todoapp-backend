# frozen_string_literal: true

class CreateTodoLists < ActiveRecord::Migration[6.0]
  def change
    create_table :todo_lists do |t|
      t.string :userName
      t.string :text
      t.boolean :isDone, default: false
      t.timestamp :deadline
      t.timestamps
    end
  end
end
