# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Card' do
  let(:ace_of_spades) { Card.new(rank: 'A', suit: 'S') }
  let(:two_of_hearts) { Card.new(rank: '2', suit: 'H') }
  let(:queen_of_diamonds) { Card.new(rank: 'Q', suit: 'D') }
  let(:king_of_clubs) { Card.new(rank: 'K', suit: 'C') }

  it 'has rank and suit' do
    expect(ace_of_spades.rank).to eq 'A'
    expect(ace_of_spades.suit).to eq 'S'
  end

  it 'only takes a valid rank and suit' do
    expect do
      Card.new(rank: '3', suit: 'Geese')
    end.to raise_error(Card::InvalidRankOrSuitError, 'Invalid rank or suit: 3 and Geese')
    expect do
      Card.new(rank: '34', suit: 'C')
    end.to raise_error(Card::InvalidRankOrSuitError, 'Invalid rank or suit: 34 and C')
  end

  context '#==' do
    it 'returns true for equal cards' do
      expect(ace_of_spades).to eq ace_of_spades
    end

    it 'returns false for unequal cards' do
      expect(ace_of_spades).not_to eq two_of_hearts
      expect(queen_of_diamonds).not_to eq ace_of_spades
    end

    it 'returns false for non-card' do
      expect(ace_of_spades).not_to eq 'A S'
    end
  end

  context '#img_href' do
    it 'returns an image href' do
      expect(ace_of_spades.img_href).to eq '/assets/images/cards/ace_of_spades.svg'
    end
  end

  context '#to_s' do
    it 'returns a string representation of the playing card' do
      expect(ace_of_spades.to_s).to eq 'Ace of Spades'
      expect(two_of_hearts.to_s).to eq '2 of Hearts'
      expect(queen_of_diamonds.to_s).to eq 'Queen of Diamonds'
      expect(king_of_clubs.to_s).to eq 'King of Clubs'
    end
  end

  context '#self.valid_rank?' do
    it 'returns true for valid rank' do
      expect(Card.valid_rank?('A')).to be_truthy
    end

    it 'returns false for invalid rank' do
      expect(Card.valid_rank?('C')).to be_falsey
    end
  end
end
