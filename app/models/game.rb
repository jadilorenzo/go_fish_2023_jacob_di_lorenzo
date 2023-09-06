class Game < ApplicationRecord

  has_many :game_users
  has_many :users, through: :game_users

  validates :player_count, presence: true, numericality: { greater_than: 1 }

  scope :pending, -> { where(started_at: nil) }
  scope :in_progress, -> { where.not(started_at: nil).where(finished_at: nil) }

  serialize :go_fish, GoFish

  def start!
    # TODO fill in with your logic to start game
    go_fish = GoFish.new
    update(go_fish: go_fish, started_at: Time.zone.now)
  end

  def play_round!
    go_fish.play_round!
    save!
  end
end

