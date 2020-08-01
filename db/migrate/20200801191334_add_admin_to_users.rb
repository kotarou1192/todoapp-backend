# frozen_string_literal: true

class AddAdminToUsers < ActiveRecord::Migration[6.0]
  def up
    add_column :users, :is_admin, :boolean, default: false
  end

  def down
    remove_column :users, :is_admin, :boolean
  end
end
