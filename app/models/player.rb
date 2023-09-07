# frozen_string_literal: true

class Player
  class TakeReceivedCardsAndCard < StandardError; end
  class TakeReceivedNothing < StandardError; end
  class InvalidRank < StandardError; end

  attr_reader :hand, :books, :user_id

  def initialize(user_id: nil, name: nil, hand: [])
    @user_id = user_id
    @name = name
    @hand = hand
    @books = []
  end

  def user
    return if user_id.nil?

    @user ||= User.find user_id
  end

  def name
    return @name unless @name.nil?

    user.full_name if user.present?
  end

  def take(*new_cards)
    new_hand = @hand.push(*new_cards)
    check_for_books
    new_hand
  end

  def self.from_json(json)
    hand = json['hand'].map { |card_hash| Card.new(**card_hash.symbolize_keys) }
    new(user_id: json['user_id'], hand: hand)
  end

  def as_json
    {
      user_id: user_id,
      hand: hand.map(&:as_json)
    }
  end

  def give_cards_of_rank(rank)
    raise InvalidRank unless Card.valid_rank?(rank)

    matching_cards = cards_of_rank rank
    @hand -= matching_cards
    matching_cards
  end

  def rank_in_hand?(rank)
    hand.any? { |card| card.rank == rank }
  end

  def ==(other)
    other.is_a?(self.class) &&
      other.user_id == user_id &&
      other.hand == hand &&
      other.books == books &&
      other.name == name
  end

  private

  def cards_of_rank(rank)
    hand.filter { |card| card.rank == rank }
  end

  def check_for_books
    ranks_in_hand = hand.map(&:rank)
    book_ranks = ranks_in_hand.select { |rank| ranks_in_hand.count(rank) == 4 }.uniq
    @books += book_ranks.map { |rank| hand.filter { |card| card.rank == rank } }
    @hand = @hand.reject { |card| book_ranks.include?(card.rank) }
    @books
  end
end
