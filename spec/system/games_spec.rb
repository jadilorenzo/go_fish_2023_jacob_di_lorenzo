# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Games', type: :system, js: true do
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

  it 'save game state' do
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

  def manual_sign_in(session, user)
    session.fill_in 'Email', with: user.email
    session.fill_in 'Password', with: user.password
    session.click_on 'Log in'
  end
end
