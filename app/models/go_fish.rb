# frozen_string_literal: true

class GoFish
  DEAL_SIZE = {
    2 => 7,
    3 => 5,
    4 => 5,
    5 => 5
  }.freeze

  attr_reader :players, :deck, :cards_in_play, :winner, :turn, :dealt, :should_shuffle_player_order

  class TooManyPlayers < StandardError; end
  class InvalidRank < StandardError; end
  class PlayerDoesNotHaveRequestedRank < StandardError; end
  class PlayerAskedForHimself < StandardError; end

  def initialize(players: [Player.new], deck: Deck.new, turn: 0, should_shuffle_player_order: true, winner: nil)
    raise TooManyPlayers if players.length > 5

    @deck = deck
    @players = players
    @dealt = false
    @winner = winner
    @turn = turn
    @should_shuffle_player_order = should_shuffle_player_order
    @shuffled_player_order = false
  end

  def winner?
    check_for_winner
    !winner.nil?
  end

  def dealt?
    dealt
  end

  def shuffled_player_order?
    @shuffled_player_order
  end

  def start!
    shuffle_player_order
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

  def shuffle_player_order
    @players.shuffle! if should_shuffle_player_order
  end

  def draw_card
    return if deck.empty?

    card = deck.draw
    current_player.take card
    card
  end

  def take_turn(rank:, player: nil)
    return go_fish_and_increment_turn if current_player.hand.empty?
    raise InvalidRank unless Card.valid_rank? rank
    raise PlayerDoesNotHaveRequestedRank unless current_player.rank_in_hand? rank
    raise PlayerAskedForHimself if current_player == player
    return go_fish_and_increment_turn_if_neccesary(rank) unless player.rank_in_hand?(rank)

    take_rank_from_player(player, rank)
  end

  def check_for_winner
    return if deck.cards.length != 0

    @winner = players.max_by { |player| player.books.length } if players.all? { |player| player.hand.empty? }
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
    winner = Player.from_json(json['winner']) unless winner.nil?
    new(players: players, deck: deck, turn: json['turn'], winner: winner)
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
      deck: deck.as_json,
      winner: winner.as_json
    }
  end

  private

  def go_fish_and_increment_turn
    draw_card
    @turn += 1
  end

  def go_fish_and_increment_turn_if_neccesary(rank)
    return if deck.empty?

    @turn += 1 if draw_card.rank != rank
  end

  def take_rank_from_player(player, rank)
    current_player.take(*player.give_cards_of_rank(rank))
  end

  def turn_index
    turn % players.length
  end
end
