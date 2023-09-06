# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  describe '#email' do
    it 'is required' do
      expect(build(:user, email: nil)).not_to be_valid
    end

    it 'must be unique' do
      existing_user = create(:user, email: 'test@example.com')
      new_user = build(:user, email: 'test@example.com')

      expect(new_user).not_to be_valid
      expect do
        new_user.save!
      end.to raise_error ActiveRecord::RecordInvalid
    end
  end

  xdescribe 'user record' do
    let(:user1) { create(:user) }
    let(:user2) { create(:user) }
    let!(:lost_game) { create(:game, users: [user1, user2], winner: user2) }
    let!(:won_game1) { create(:game, users: [user1, user2], winner: user1) }
    let!(:won_game2) { create(:game, users: [user1, user2], winner: user1) }

    it 'returns the games a user has won' do
      expect(user1.won_games).to eq [won_game1, won_game2]
      expect(user2.won_games).to eq [lost_game]
    end

    it 'handle a user that has no games' do
      user = create(:user)
      expect(user.winning_percentage).to eq 0
    end

    it 'calcualtes the winning percentage for the user' do
      expect(user1.winning_percentage).to be_within(0.001).of 0.666
      expect(user2.winning_percentage).to be_within(0.001).of 0.333
    end

    it 'returns a human readable percentage' do
      expect(user1.winning_percentage_string).to eq '67%'
      expect(user2.winning_percentage_string).to eq '33%'
    end
  end
end
