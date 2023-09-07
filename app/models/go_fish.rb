# frozen_string_literal: true

class GoFish
  DEAL_SIZE = {
    2 => 7,
    3 => 5,
    4 => 5,
    5 => 5
  }.freeze

  attr_reader :players, :deck, :cards_in_play, :winner, :turn, :dealt

  class TooManyPlayers < StandardError; end
  class InvalidRank < StandardError; end
  class PlayerDoesNotHaveRequestedRank < StandardError; end
  class PlayerAskedForHimself < StandardError; end

  def initialize(players: [Player.new], deck: Deck.new, turn: 0)
    raise TooManyPlayers if players.length > 5

    @deck = deck
    @players = players
    @dealt = false
    @pending = true
    @winner = nil
    @turn = turn
  end

  def dealt?
    dealt
  end

  def start!
    deck.shuffle!
    deal!
  end

  def deal!
    @dealt = true
    DEAL_SIZE[players.length].times do
      players.each do |player|
        player.take deck.draw
      end
    end
  end

  def play_round!
    @turn += 1
  end

  def go_fish
    current_player.take deck.draw
  end

  def take_turn(rank:, player:)
    raise InvalidRank unless Card.valid_rank? rank
    raise PlayerDoesNotHaveRequestedRank unless current_player.rank_in_hand? rank
    raise PlayerAskedForHimself if current_player == player

    recieved_cards = ask_for_rank(player, rank)
    return give_cards_to_player recieved_cards unless recieved_cards.empty?

    @turn += 1
    go_fish
  end

  def current_player
    players[turn_index]
  end

  def self.from_json(json)
    players = json['players'].map do |player_hash|
      Player.from_json(player_hash)
    end
    deck = Deck.new(cards: json['deck']['cards'].map do |card_hash|
      Card.new(**card_hash.symbolize_keys)
    end)
    new(players: players, deck: deck, turn: json['turn'])
  end

  def self.load(json)
    return nil if json.blank?

    from_json(json)
  end

  def self.dump(obj)
    obj.as_json
  end

  def as_json(*)
    {
      players: players.map(&:as_json),
      turn: turn,
      deck: deck.as_json
    }
  end

  private

  def turn_index
    turn % players.length
  end

  def ask_for_rank(player, rank)
    player.give_cards_of_rank rank
  end

  def give_cards_to_player(cards)
    player = current_player
    @turn += 1
    player.take(*cards)
  end
end
