class Deck
  DECK_SIZE = Card::SUITS.length * Card::RANKS.length

  attr_reader :cards

  def initialize(cards: generate_full_deck)
    @cards = cards || []
    @shuffled = false
  end

  def cards_left
    @cards.length
  end

  def draw_cards(number_of_cards)
    @cards.slice!(0, number_of_cards)
  end

  def draw
    draw_cards(1).first
  end

  def shuffle!(seed = nil)
    @shuffled = true
    seed ? @cards.shuffle!(random: Random.new(seed)) : @cards.shuffle!
  end

  def shuffled?
    @shuffled
  end

  def empty?
    cards_left.zero?
  end

  def self.from_json(json)
    cards = json['cards'].map { |card_hash| Card.new(**card_hash.symbolize_keys) }
    self.new(cards: cards)
  end

  def as_json
    {
      cards: cards.map(&:as_json)
    }
  end

  private

  def generate_full_deck
    Card::SUITS.flat_map do |suit|
      Card::RANKS.map do |rank|
        Card.new(rank: rank, suit: suit)
      end
    end
  end
end
