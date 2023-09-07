# frozen_string_literal: true

class Card
  class InvalidRankOrSuitError < StandardError; end
  SUITS = %w[H D C S].freeze
  RANKS = %w[2 3 4 5 6 7 8 9 10 J Q K A].freeze
  SUIT_NAMES = %w[Hearts Diamonds Clubs Spades].freeze
  RANK_NAMES = %w[2 3 4 5 6 7 8 9 10 Jack Queen King Ace].freeze

  attr_reader :suit, :rank

  def initialize(suit:, rank:)
    validate(rank, suit)
    @suit = suit
    @rank = rank
  end

  def validate(rank, suit)
    return if Card.valid_rank?(rank) && SUITS.include?(suit)

    raise InvalidRankOrSuitError, "Invalid rank or suit: #{rank} and #{suit}"
  end

  def value
    return RANKS.index(rank) + 2 unless rank == 'A'

    15
  end

  def ==(other)
    other.is_a?(Card) && other.rank == rank && other.suit == suit
  end

  def to_s
    "#{RANK_NAMES[RANKS.index(rank)]} of #{SUIT_NAMES[SUITS.index(suit)]}"
  end

  def img_href
    "/cards/#{RANK_NAMES[RANKS.index(rank)]}_of_#{SUIT_NAMES[SUITS.index(suit)]}.svg".downcase
  end

  def as_json
    {
      suit: suit,
      rank: rank
    }
  end

  def self.valid_rank?(rank)
    RANKS.include?(rank)
  end
end
