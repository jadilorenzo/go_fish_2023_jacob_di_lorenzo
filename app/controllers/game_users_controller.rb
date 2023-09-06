class GameUsersController < ApplicationController
  def create
    game = Game.find params[:game_id]
    game.users << current_user # creates a new GameUser

    game.start!
    redirect_to game
  end
end
