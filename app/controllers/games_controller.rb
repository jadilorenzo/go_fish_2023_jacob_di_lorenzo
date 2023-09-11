# frozen_string_literal: true

class GamesController < ApplicationController
  def index
    @pending_games = Game.pending
  end

  def show
    @game = Game.find params[:id]
  end

  def new
    @game = Game.new

    render layout: 'modal'
  end

  def create
    @game = Game.new(game_params)
    @game.users << current_user # creates a GameUser record

    if @game.save
      redirect_to @game, notice: I18n.t('flash.game_created_successfully')
    else
      render :new, layout: 'modal', status: :unprocessable_entity
    end
  end

  def play_round
    game = Game.find params[:id]
    game.play_round!(rank: params[:selected_rank], user_id: params[:selected_player].to_i)
    redirect_to game
  end

  private

  def game_params
    params.require(:game).permit(:player_count)
  end
end
