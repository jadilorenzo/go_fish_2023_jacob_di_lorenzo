# frozen_string_literal: true

FactoryBot.define do
  factory :game_user do
    game
    user
  end
end
