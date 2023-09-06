class Deck
  attr_reader :cards
  def initialize(cards = Deck.full_deck)
    @cards = cards
  end

  def self.full_deck
    ((2..10).map(&:to_s) + %w[ J Q K A ]).flat_map do |rank|
      %w[ C D S H ].map do |suit|
        Card.new(rank: rank, suit: suit)
      end
    end
  end

  def shuffle!
    cards.shuffle!
  end

  def draw
    cards.pop
  end

  def as_json
    {
      cards: cards.map(&:as_json)
    }
  end
end
