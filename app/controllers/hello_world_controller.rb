# frozen_string_literal: true

class HelloWorldController < ApplicationController
  def index
    render json: { text: 'Hello World' }
  end
end
