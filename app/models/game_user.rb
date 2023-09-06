# frozen_string_literal: true

class GameUser < ApplicationRecord
  belongs_to :game, touch: true
  belongs_to :user
end
