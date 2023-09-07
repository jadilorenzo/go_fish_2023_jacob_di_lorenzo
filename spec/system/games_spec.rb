# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Games', type: :system, js: true do
  def manual_sign_in(session, user)
    session.fill_in 'Email', with: user.email
    session.fill_in 'Password', with: user.password
    session.click_on 'Log in'
  end

  def sign_in_user(name)
    user = create(:user, first_name: name)
    sign_in user
    user
  end

  def sign_in_and_join_game(name)
    user = sign_in_user(name)
    visit root_path
    click_on 'Join'
    user
  end

  def create_game(number_of_players)
    visit root_path

    click_on 'Create Game'
    fill_in 'game[player_count]', with: number_of_players
    click_button 'Create'
  end

  it 'requires authentication' do
    visit '/games'

    expect(page).to have_content 'Welcome'
    expect(current_path).to eq new_user_session_path
  end

  it 'starts a game when enough players join' do
    player1 = create(:user)
    game = create(:game, users: [player1], player_count: 2)
    user = create(:user, first_name: 'Caleb')
    sign_in user
    visit root_path

    click_on 'Join'

    expect(page).to have_content "Its #{player1.full_name}'s turn"
    expect(game.reload.users).to include user
  end

  fit 'shows a player\'s hand' do
    game = create(:game, player_count: 2)
    user1 = sign_in_and_join_game('Hunter')
    user2 = sign_in_and_join_game('Jacob')
    game.go_fish = GoFish.new(players: [
      Player.new(user_id: user1.id, hand: []), Player.new(user_id: user2.id, hand: [Card.new(rank: '2', suit: 'H')])
    ])
    expect(page).to have_selector("img[src='#{game.player_for_user(user2).hand.first.img_href}']")
  end

  it 'starts a game when 3 players join' do
    user1 = sign_in_user('Caleb')
    create_game(3)

    expect(page).to have_content 'Waiting for 2 players to join'
    user2 = sign_in_and_join_game('Jacob')
    expect(page).to have_content 'Waiting for 1 player to join'
  end

  it 'saves game state' do
    game = create(:game, player_count: 2)
    session1 = Capybara::Session.new(:rack_test, Rails.application)
    session2 = Capybara::Session.new(:rack_test, Rails.application)

    [session1, session2].each_with_index do |session, index|
      user = create(:user, first_name: "Player #{index + 1}")
      session.visit root_path
      # can't use devise helper with multiple sessions
      manual_sign_in(session, user)
      session.click_on 'Join'
    end
    session1.driver.refresh
    expect(session1).to have_content 'Its your turn'
    session1.click_on 'Play'
    session2.driver.refresh
    session2.click_on 'Play'
    session1.driver.refresh
    expect(session1).to have_content 'Its your turn'
    expect(session2).to have_content "Its Player 1 User's turn"
  end
end
