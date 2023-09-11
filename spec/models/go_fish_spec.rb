# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'GoFish' do
  let(:player1) { Player.new(name: 'Muffin') }
  let(:player2) { Player.new(name: 'Potato') }
  let(:go_fish) { GoFish.new(players: [player1, player2], should_shuffle_player_order: false) }
  let(:card_deck) { Deck.new }
  let(:players) { go_fish.players }

  context '#initialize' do
    it 'has players, card deck, no winner, and has not been dealt' do
      expect(players[0].name).to eq('Muffin')
      expect(players[1].name).to eq('Potato')
      expect(go_fish.deck).to_not be_nil
      expect(go_fish.winner).to be_nil
      expect(go_fish.dealt?).to be_falsey
      expect(go_fish.shuffled_player_order?).to be_falsey
      expect(go_fish.turn).to eq 0
    end

    it 'throws error if too many players' do
      expect do
        GoFish.new(
          players:
            8.times.map { Player.new(name: 'Bobby Big Boy') }.to_a
        )
      end.to raise_error(GoFish::TooManyPlayers)
    end

    it 'takes a deck and doesn\'t shuffle it' do
      go_fish = GoFish.new(deck: card_deck)
      expect(go_fish.deck).to eq card_deck
      expect(go_fish.deck.shuffled?).to be false
    end
  end

  context '#start' do
    it 'shuffles the deck and deals the cards' do
      go_fish.start!
      expect(go_fish.deck.shuffled?).to be_truthy
      expect(go_fish.dealt?).to be_truthy
    end
  end

  context '#deal' do
    it 'should deal the cards' do
      go_fish.deal!
      expect(players[0].hand.length).to eq(GoFish::DEAL_SIZE[2])
      expect(players[1].hand.length).to eq(GoFish::DEAL_SIZE[2])
    end
  end

  context '#current_player' do
    it 'should return the first player before the first turn,
        should return the second player after the first turn,
        and should go back to the first player after the second turn
    ' do
      go_fish.deal!
      expect(go_fish.current_player).to eq player1
      go_fish.take_turn(rank: player1.hand.last.rank, player: player2)
      expect(go_fish.current_player).to eq player2
      go_fish.take_turn(rank: player2.hand.second.rank, player: player1)
      expect(go_fish.current_player).to eq player1
    end
  end

  context '#draw_card' do
    it 'should give a player a card from the deck' do
      go_fish.draw_card
      expect(go_fish.deck.cards_left).to eq Deck::DECK_SIZE - 1
      expect(go_fish.current_player.hand.length).to eq 1
    end
  end

  context '#take_turn' do
    it 'should not result in a go fish if the player asks for a card from a player that exists' do
      # player 1 hand starts with 2 which player 2 hand also has
      go_fish.deal!
      expect(go_fish.deck.shuffled?).to be_falsey
      allow(go_fish).to receive(:draw_card)
      go_fish.take_turn(rank: player1.hand.first.rank, player: player2)
      expect(go_fish).to_not have_received(:draw_card)
    end

    it 'should result in a go fish if the player asks for a card from a player that does not exist' do
      # player 1 hand starts with 2 which player 2 hand also has
      go_fish.deal!
      expect(go_fish.deck.shuffled?).to be_falsey
      allow(go_fish).to receive(:draw_card).and_return(card_deck.draw)
      go_fish.take_turn(rank: player1.hand.last.rank, player: player2)
      expect(go_fish).to have_received(:draw_card)
    end

    it 'should move cards from one player to the other on a successful query' do
      go_fish.deal!
      expect(go_fish.deck.shuffled?).to be_falsey
      go_fish.take_turn(rank: player1.hand.first.rank, player: player2)
      expect(player1.hand.length).to eq 8
      expect(player2.hand.length).to eq 6
    end

    describe "when it changes who's turn it is" do
      let(:player1) do
        Player.new(name: 'Muffin X',
                   hand: [
                     Card.new(suit: 'C', rank: '4'), Card.new(suit: 'S', rank: 'J'), Card.new(suit: 'H', rank: '5')
                   ])
      end
      let(:player2) do
        Player.new(name: 'Not Today Potato',
                   hand: [
                     Card.new(suit: 'H', rank: 'J'), Card.new(suit: 'C', rank: 'A')
                   ])
      end
      let(:deck) do
        Deck.new(cards: [
          Card.new(suit: 'C', rank: '5'), Card.new(suit: 'H', rank: 'J'), Card.new(suit: 'S', rank: 'A')
        ])
      end
      let(:go_fish) do
        GoFish.new(
          players: [player1, player2],
          should_shuffle_player_order: false,
          deck: deck
        )
      end

      it "changes turn when a player fishes for a card and doesn't get the one he asked for" do
        # when the game is stacked ^^
        # then
        expect(go_fish.turn).to eq 0
        go_fish.take_turn(rank: player1.hand.first.rank, player: player2)
        # what
        expect(go_fish.turn).to eq 1
      end

      it "doesn't change turn when a player fishes for a card and gets the one he asked for" do
        # when the game is stacked ^^
        # then
        expect(go_fish.turn).to eq 0
        go_fish.take_turn(rank: deck.cards.first.rank, player: player2)
        expect(go_fish.turn).to eq 0
      end

      it "doesn't change turn when a player gets the card he asked for" do
        expect(go_fish.turn).to eq 0
        go_fish.take_turn(rank: player1.hand.second.rank, player: player2)
        expect(go_fish.turn).to eq 0
      end
    end

    it 'should raise PlayerDoesNotHaveRequestedRank if the player does not have the requested card' do
      go_fish.deal!
      expect { go_fish.take_turn(rank: '5', player: player2) }.to raise_error(GoFish::PlayerDoesNotHaveRequestedRank)
    end

    it 'should raise PlayerAskedForHimself if the player asks for a card from themselves' do
      go_fish.deal!
      expect do
        go_fish.take_turn(rank: player1.hand.first.rank, player: player1)
      end.to raise_error(GoFish::PlayerAskedForHimself)
    end

    it 'determines the winner' do
      go_fish.deal!
      expect(go_fish.winner).to be_nil
    end
  end
end
