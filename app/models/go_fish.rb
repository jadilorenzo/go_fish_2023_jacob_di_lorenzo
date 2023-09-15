# frozen_string_literal: true

class GoFish
  include ActionView::Helpers::TextHelper

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

  def draw_card(asker = current_player)
    return if deck.empty?

    card = deck.draw
    asker.take card
    card
  end

  def take_turn(rank:, player: nil)
    # will always return round_result
    asker = current_player
    askee = player
    return go_fish_and_increment_turn(asker, askee) if asker.hand.empty?
    raise InvalidRank unless Card.valid_rank? rank
    raise PlayerDoesNotHaveRequestedRank unless asker.rank_in_hand? rank
    raise PlayerAskedForHimself if asker == askee
    return go_fish_and_increment_turn_if_neccesary(asker, rank, askee) unless askee.rank_in_hand?(rank)

    take_rank_from_player(asker, rank, askee)
  end

  def round_result(asker, rank, askee, count)
    return ['Go Fish!'] if askee.nil? || rank.nil?
    return ["#{asker.name} asked for #{rank}s from #{askee.name}.", 'Go Fish!'] if count == 0

    ["#{asker.name} took #{pluralize(count, rank)} from #{askee.name}."]
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

  def go_fish_and_increment_turn(asker, askee)
    card = draw_card(asker)
    @turn += 1
    round_result(asker, card.rank_name, askee, 0)
  end

  def go_fish_and_increment_turn_if_neccesary(asker, rank, askee)
    return if deck.empty?

    @turn += 1 if draw_card(asker).rank != rank
    round_result(asker, Card.rank_name(rank), askee, 0)
  end

  def take_rank_from_player(asker, rank, askee)
    cards = askee.give_cards_of_rank(rank)
    asker.take(*cards)
    round_result(asker, Card.rank_name(rank), askee, cards.length)
  end

  def turn_index
    turn % players.length
  end
end
