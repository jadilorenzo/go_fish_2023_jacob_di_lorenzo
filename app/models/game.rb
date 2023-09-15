# frozen_string_literal: true

class Game < ApplicationRecord
  has_many :game_users, dependent: :destroy
  has_many :users, through: :game_users

  validates :player_count, presence: true, numericality: { greater_than: 1 }

  scope :pending, -> { where(started_at: nil) }
  scope :in_progress, -> { where.not(started_at: nil).where(finished_at: nil) }
  scope :started, -> { where.not(started_at: nil).where(finished_at: nil) }

  def self.games_for_user(current_user)
    joins(:users).where(users: { id: current_user.id })
  end

  serialize :go_fish, GoFish

  def started?
    !go_fish.nil? && !started_at.nil?
  end

  def pending?
    player_count != users.length
  end

  def your_turn?(current_user)
    return false unless started?

    current_user == current_player_user
  end

  def start!(should_shuffle_player_order: !Rails.env.test?)
    return if pending?

    players = users.map { |user| Player.new(user_id: user.id) }
    go_fish = GoFish.new players: players, should_shuffle_player_order: should_shuffle_player_order
    go_fish.start!
    update(go_fish: go_fish, started_at: Time.zone.now)
  end

  def play_round!(rank:, user_id:)
    player ||= go_fish.players.find { |player1| player1.user_id == user_id }

    results = go_fish.take_turn(
      rank: rank,
      player: player
    )
    go_fish.check_for_winner
    update(finished_at: Time.zone.now) if go_fish.winner?
    save!
    results
  end

  def player_for_user(user)
    return if user.nil?
    return if go_fish.nil?

    go_fish.players.find { |player| player.user_id == user.id }
  end

  def opponents(user)
    return unless started?

    go_fish.players - [player_for_user(user)]
  end

  def remaining_players
    player_count - users.length
  end

  def current_player
    go_fish.current_player
  end

  def current_player_user
    current_player.user
  end
end
