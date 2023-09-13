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

  def setup_two_player_game(player1_name, player2_name)
    game = create(:game, player_count: 2)
    user1 = sign_in_and_join_game(player1_name)
    sleep 0.1
    user2 = sign_in_and_join_game(player2_name)
    page.driver.refresh
    [game.reload, user1, user2]
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
    expect(page).to have_content('7 cards')
  end

  it "won't let you join you've already entered" do
    game = create(:game, player_count: 2)
    user1 = sign_in_and_join_game('Hunter')
    user2 = sign_in_and_join_game('Jacob')
    page.driver.refresh
    visit root_path
    expect(page).to_not have_content 'Join'
    expect(page).to have_content 'View'
  end

  it "shows games you're in" do
    game = create(:game, player_count: 2)
    user1 = sign_in_and_join_game('Hunter')
    user2 = sign_in_and_join_game('Jacob')
    visit root_path
    expect(page).to have_content 'View'
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
    game, user1, user2 = setup_two_player_game('Caleb', 'Jacob')

    sign_in user1
    page.driver.refresh
    visit game_path(game.reload)

    last_card = game.go_fish.players.first.grouped_hand[game.go_fish.players.first.grouped_hand.keys.last].last
    find("img[src='#{last_card.img_href}']").click
    expect(page).to have_content('Ask Jacob')
  end

  it 'takes a turn' do
    game, user1, user2 = setup_two_player_game('Caleb', 'Jacob')

    sign_in user1
    visit game_path(game)

    expect(game.reload.current_player.user_id).to eq user1.id
    last_card = game.go_fish.players.first.grouped_hand[game.go_fish.players.first.grouped_hand.keys.last].last
    find("img[src='#{last_card.img_href}']").click
    choose 'Ask Jacob Last'
    click_on 'Ask'

    sleep 0.1
    expect(game.reload.go_fish.players.first.hand.length).to_not eq 7
  end

  it 'starts a game when 3 players join' do
    user1 = sign_in_user('Caleb')
    create_game(3)

    expect(page).to have_content 'Waiting for 2 players to join'
    user2 = sign_in_and_join_game('Jacob')
    expect(page).to have_content 'Waiting for 1 player to join'
  end

  def pick_last_card(game, session)
    grouped_hand = game.reload.go_fish.current_player.grouped_hand
    last_card = grouped_hand[grouped_hand.keys.last].last
    session.find("img[src='#{last_card.img_href}']").click
  end

  def pick_player(opponent, session)
    session.choose "Ask #{opponent.name}"
    session.click_on 'Ask'
  end

  it 'plays a game to completion' do
    game = create(:game, player_count: 2)
    session1 = Capybara::Session.new(:selenium_chrome_headless, Rails.application)
    session2 = Capybara::Session.new(:selenium_chrome_headless, Rails.application)

    user1, user2 = [session1, session2].map.with_index do |session, index|
      user = create(:user, first_name: 'Player', last_name: "#{index + 1}")
      session.visit root_path
      manual_sign_in(session, user)
      session.click_on 'Join'
      user
    end

    users_to_sessions = { user1 => session1, user2 => session2 }

    sleep 0.1 until game.reload.started?

    until game.reload.go_fish&.winner?
      sleep 0.1
      current_user = User.find(game.reload.go_fish.current_player.user_id)
      current_session = users_to_sessions[current_user]
      visit game_path game, session: current_session unless current_session.current_url == game_path(game)

      break if game.reload.go_fish.winner?

      if game.go_fish.current_player.hand.empty?
        current_session.click_on 'Go Fish'
      else
        pick_last_card(game.reload, current_session)
        pick_player(game.opponents(current_user).first, current_session)
      end
    end

    # Assert the winner
    expect(session1).to have_content "#{game.go_fish.winner.name} won!"
    expect(session2).to have_content "#{game.go_fish.winner.name} won!"
  end

  xit 'saves game state' do
    game = create(:game, player_count: 2)
    session1 = Capybara::Session.new(:selenium_chrome_headless, Rails.application)
    session2 = Capybara::Session.new(:selenium_chrome_headless, Rails.application)

    [session1, session2].each_with_index do |session, index|
      user = create(:user, first_name: 'Player', last_name: "#{index + 1}")
      session.visit root_path
      # can't use devise helper with multiple sessions
      manual_sign_in(session, user)
      session.click_on 'Join'
    end

    sleep 0.1
    expect(session1).to have_content '(your turn)'
    expect(session1).to have_content '(your turn)'
    session1.click_on 'Play'
    session2.click_on 'Play'
    expect(session1).to have_content '(your turn)'
    expect(session2).to have_content 'Player 1 (their turn)'
  end
end
