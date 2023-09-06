class Card
  attr_reader :suit, :rank

  def initialize(suit:, rank:)
    @suit, @rank = suit, rank
  end

  def ==(other)
    suit == other.suit && rank == other.rank
  end

  def as_json
    {
      suit: suit,
      rank: rank
    }
  end
end
