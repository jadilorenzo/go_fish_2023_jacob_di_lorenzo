# frozen_string_literal: true

class Player
  class TakeReceivedCardsAndCard < StandardError; end
  class TakeReceivedNothing < StandardError; end
  class InvalidRank < StandardError; end

  attr_reader :hand, :books, :user_id

  def initialize(user_id: nil, name: nil, hand: [], books: [])
    @user_id = user_id
    @name = name
    @hand = hand
    @books = books
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
    unless json['books'].nil?
      books = json['books'].map do |book|
        book.map { |card_hash| Card.new(**card_hash.symbolize_keys) }
      end
    end
    new(user_id: json['user_id'], hand: hand, books: books || [])
  end

  def as_json
    {
      user_id: user_id,
      hand: hand.map(&:as_json),
      books: books.map { |book| book.map(&:as_json) }
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

  def grouped_hand
    hand.group_by(&:rank).sort_by { |_rank, cards| cards.first.value }.to_h
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
    hand_ranks = hand.map(&:rank)
    unique_book_ranks = hand_ranks.select { |rank| hand_ranks.count(rank) == 4 }.uniq

    @books += unique_book_ranks.map { |rank| hand.filter { |card| card.rank == rank } }
    @hand = @hand.reject { |card| unique_book_ranks.include?(card.rank) }

    @books
  end
end
