# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Game, type: :model do
  describe '.pending' do
    it 'returns games not yet started' do
      done_game = create(:game, :finished)
      in_progress = create(:game, :started)
      pending = create(:game)

      expect(Game.pending).to eq [pending]
    end
  end

  describe '.in_progress' do
    it 'returns cames still in progress' do
      done_game = create(:game, :finished)
      in_progress = create(:game, :started)
      pending = create(:game)

      expect(Game.in_progress).to eq [in_progress]
    end
  end

  describe '#go_fish' do
    it 'saves a GoFish game to JSON' do
      user1 = create(:user)
      user2 = create(:user)
      player1 = Player.new(user_id: user1.id)
      player2 = Player.new(user_id: user2.id)
      go_fish = GoFish.new(players: [player1, player2])
      go_fish.deal!
      game = create(:game, users: [user1, user2])

      game.go_fish = go_fish

      expect(game.go_fish).not_to be_nil
    end

    it 'inflates a GoFish game from JSON' do
      user1 = create(:user)
      user2 = create(:user)
      go_fish_json = {
        'players' => [{
          'user_id' => user1.id,
          'hand' => [{ 'suit' => 'C', 'rank' => '4' }]
        }, {
          'user_id' => user2.id,
          'hand' => [{ 'suit' => 'H', 'rank' => 'J' }]
        }],
        'deck' => {
          'cards' => [{ 'suit' => 'D', 'rank' => 'A' }]
        }
      }
      game = create(:game, go_fish: go_fish_json)

      expect(game.go_fish.players.map(&:user)).to match_array [user1, user2]
      expect(game.go_fish.players.first.hand.first).to eq Card.new(suit: 'C', rank: '4')
      expect(game.go_fish.deck.cards.first).to eq Card.new(suit: 'D', rank: 'A')
    end
  end
end
