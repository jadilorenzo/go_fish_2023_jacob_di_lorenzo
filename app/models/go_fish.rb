class GoFish
  CARDS_PER_PLAYER = 7
  attr_reader :players, :deck
  def initialize(players, deck = Deck.new, current_player_index=0)
    @players = players
    @deck = deck
    @current_player_index = current_player_index
  end

  def current_player
    players[current_player_index]
  end

  def deal!
    deck.shuffle!
    CARDS_PER_PLAYER.times do
      players.each do |player|
        player.take deck.draw
      end
    end
  end

  def play_round!
    if current_player_index == players.length - 1
      self.current_player_index = 0
    else
      self.current_player_index = current_player_index + 1
    end
  end

  def self.from_json(json)
    # TODO: parse from JSON to Domain model
  end

  def self.load(json)
    return nil if json.blank?
    self.from_json(json)
  end

  def self.dump(obj)
    obj.as_json
  end

  def as_json(*)
    # TODO: convert from Domain model to JSON primitives
  end

  private

  attr_accessor :current_player_index
end
