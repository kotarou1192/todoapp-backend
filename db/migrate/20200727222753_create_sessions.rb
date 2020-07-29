# frozen_string_literal: true

class CreateSessions < ActiveRecord::Migration[6.0]
  def change
    create_table :sessions do |t|
      t.string :token
      t.string :user_name
      t.string :user_email
      t.timestamps
    end
  end
end
