class Player
  attr_reader :cards

  def initialize(user_id, cards=[])
    @user_id = user_id
    @cards = cards
  end

  def user
    @user ||= User.find user_id
  end

  def take(*new_cards)
    cards.push(*new_cards)
  end

  def self.from_json(json)
    cards = json['cards'].map { |card_hash| Card.new(**card_hash.symbolize_keys) }
    self.new(json['user_id'], cards)
  end

  def as_json
    {
      user_id: user_id,
      cards: cards.map(&:as_json)
    }
  end

  private

  attr_reader :user_id
end
