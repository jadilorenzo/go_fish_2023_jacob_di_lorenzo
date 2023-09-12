# frozen_string_literal: true

class GameUsersController < ApplicationController
  include GameBroadcaster

  def create
    game = Game.find params[:game_id]
    game.users << current_user # creates a new GameUser

    game.start!
    broadcast_game(game) if game.started?
    redirect_to game
  end
end
