# frozen_string_literal: true

class Game < ApplicationRecord
  has_many :game_users
  has_many :users, through: :game_users

  validates :player_count, presence: true, numericality: { greater_than: 1 }

  scope :pending, -> { where(started_at: nil) }
  scope :in_progress, -> { where.not(started_at: nil).where(finished_at: nil) }

  serialize :go_fish, GoFish

  def start!
    # TODO: fill in with your logic to start game

    return unless ready_to_start?

    players = users.map { |user| Player.new(user_id: user.id) }
    go_fish = GoFish.new players: players
    update(go_fish: go_fish, started_at: Time.zone.now)
  end

  def started?
    !go_fish.nil?
  end

  def pending?
    !ready_to_start?
  end

  def ready_to_start?
    player_count == users.length
  end

  def current_player
    go_fish.current_player.user
  end

  def current_players_turn?(current_user)
    current_player_user = current_player
    current_user == current_player_user
  end

  def remaining_players
    player_count - users.length
  end

  def play_round!
    go_fish.play_round!
    save!
  end
end
