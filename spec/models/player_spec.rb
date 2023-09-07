# frozen_string_literal: true

RSpec.describe 'Player' do
  let(:card1) { Card.new(rank: 'A', suit: 'S') }
  let(:card2) { Card.new(rank: '2', suit: 'S') }
  let(:card3) { Card.new(rank: '3', suit: 'S') }
  let(:card4) { Card.new(rank: '2', suit: 'H') }
  let(:player) { Player.new(name: 'Pancy Nelosi') }
  let(:ace_book) do
    [
      Card.new(rank: 'A', suit: 'S'), Card.new(rank: 'A', suit: 'H'),
      Card.new(rank: 'A', suit: 'C'), Card.new(rank: 'A', suit: 'D')
    ]
  end

  it 'has name, empty hand, and empty books' do
    expect(player.name).to eq 'Pancy Nelosi'
    expect(player.hand.length).to eq 0
    expect(player.books.length).to eq 0
  end

  it 'takes hand' do
    player = Player.new(name: 'Ced Truz', hand: ['card'])
    expect(player.hand).to eq ['card']
  end

  context '#take' do
    it 'adds a card' do
      player.take(card1)
      card = player.hand.first
      expect(card).to eq card1
    end

    it 'adds cards' do
      player.take(card1, card2)
      card = player.hand.first
      expect(card).to eq card1
    end

    it 'adds one book when found and removes cards from hand' do
      player.take(*ace_book)
      player.take(card2)
      expect(player.books).to eq [ace_book]
      expect(player.books.length).to eq 1
      expect(player.hand.length).to be 1
    end

    it 'adds multiple books as they are found and removes all the cards from hand' do
      player.take(Card.new(rank: '3', suit: 'H'), Card.new(rank: '3', suit: 'S'), Card.new(rank: '3', suit: 'D'))
      player.take(*ace_book)
      player.take(card3)
      expect(player.books.length).to eq 2
      expect(player.hand.length).to be 0
    end
  end

  context '#give_cards_of_rank' do
    before do
      player.take(card1, card2, card3, card4)
    end

    it 'throws error if given invalid rank' do
      expect { player.give_cards_of_rank('') }.to raise_error Player::InvalidRank
      expect { player.give_cards_of_rank('L') }.to raise_error Player::InvalidRank
      expect { player.give_cards_of_rank('Ace') }.to raise_error Player::InvalidRank
    end

    it 'returns one card if it matches the rank' do
      expect(player.give_cards_of_rank(card1.rank)).to eq [card1]
    end

    it 'returns cards if they match the rank' do
      expect(player.give_cards_of_rank(card2.rank)).to eq [card2, card4]
      expect(player.hand).to eq [card1, card3]
    end

    it 'returns nothing if no cards match the rank' do
      sample_rank_not_in_hand = '5'
      expect(player.give_cards_of_rank(sample_rank_not_in_hand)).to eq []
    end
  end

  context '#rank_in_hand?' do
    it 'returns true if player has the rank' do
      player.take(card1)
      expect(player.rank_in_hand?(card1.rank)).to be_truthy
    end

    it 'returns false if player does not have the rank' do
      expect(player.rank_in_hand?(card2.rank)).to be_falsey
    end
  end

  context '#==' do
    it 'returns true for equal players' do
      expect(
        Player.new(name: 'billy', hand: [Card.new(rank: 'A', suit: 'S')])
      ).to eq(
        Player.new(name: 'billy', hand: [Card.new(rank: 'A', suit: 'S')])
      )
    end
    it 'returns false for different players' do
      expect(player).not_to eq Player.new name: 'billy'
    end
  end
end
