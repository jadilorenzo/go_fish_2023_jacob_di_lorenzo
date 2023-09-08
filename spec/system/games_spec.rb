# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Games', type: :system, js: true do
  def manual_sign_in(session, user)
    session.fill_in 'Email', with: user.email
    session.fill_in 'Password', with: user.password
    session.click_on 'Log in'
  end

  def sign_in_user(name)
    user = create(:user, first_name: name, last_name: 'Last')
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

  def setup_two_player_game(player1_name, player2_name, turn)
    game = create(:game, player_count: 2)
    user1 = sign_in_and_join_game(player1_name)
    sleep 0.1
    user2 = sign_in_and_join_game(player2_name)
    [game, user1, user2]
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

    expect(page).to have_content "#{player1.full_name} (their turn)"
  end

  it 'shows a player\'s hand' do
    game = create(:game, player_count: 2)
    user1 = sign_in_and_join_game('Hunter')
    user2 = sign_in_and_join_game('Jacob')
    expect(page).to have_selector("img[class='playing-card']")
  end

  it 'shows a list of players' do
    game = create(:game, player_count: 2)
    user1 = sign_in_and_join_game('Hunter')
    sleep 0.1
    user2 = sign_in_and_join_game('Jacob')

    expect(page).to have_content('Jacob')
    expect(page).to have_content('Hunter')
  end

  it 'shows a list of players to ask' do
    game, user1, user2 = setup_two_player_game('Caleb', 'Jacob', turn: 1)

    sign_in user1
    page.driver.refresh
    visit game_path(game.reload)

    find("img[src='#{game.go_fish.players.first.hand.last.img_href}']").click
    expect(page).to have_content('Ask Jacob')
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
      user = create(:user, first_name: 'Player', last_name: "#{index + 1}")
      session.visit root_path
      # can't use devise helper with multiple sessions
      manual_sign_in(session, user)
      session.click_on 'Join'
    end
    session1.driver.refresh
    expect(session1).to have_content '(your turn)'
    session1.click_on 'Play'
    session2.driver.refresh
    session2.click_on 'Play'
    session1.driver.refresh
    expect(session1).to have_content '(your turn)'
    expect(session2).to have_content 'Player 1 (their turn)'
  end
end
