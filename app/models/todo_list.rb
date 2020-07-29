# frozen_string_literal: true

class TodoList < ApplicationRecord
  validates :text, presence: true, length: { maximum: 200 }

  belongs_to :user
end
