class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  enum role: { user: 'user', admin: 'admin' }

  has_many :game_users
  has_many :games, through: :game_users
  has_many :won_games, class_name: 'Game', foreign_key: :winner_id

  validates :first_name, :last_name, :role, presence: true

  def full_name
    "#{first_name} #{last_name}"
  end

  def winning_percentage
    return 0 unless games.any?
    won_games.count / games.count.to_f
  end

  def winning_percentage_string
    "#{(winning_percentage * 100).round}%"
  end
end
