class GamesController < ApplicationController
  def index
    @pending_games = Game.pending
  end

  def new
    @game = Game.new

    render layout: 'modal'
  end

  def create
    @game = Game.new(game_params)
    @game.users << current_user # creates a GameUser record
    if @game.save
      redirect_to @game, notice: 'Game created successfully'
    else
      render :new, layout: 'modal', status: :unprocessable_entity
    end
  end

  def play_round
    game = Game.find params[:id]
    game.play_round!
    redirect_to game
  end

  def show
    @game = Game.find params[:id]
  end

  private

  def game_params
    params.require(:game).permit(:player_count)
  end
end
