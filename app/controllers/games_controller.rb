# frozen_string_literal: true

class GamesController < ApplicationController
  include ActionView::RecordIdentifier
  include GameBroadcaster

  before_action :check_for_winner, only: %i[play_round show]

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

  def check_for_winner
    game = Game.find params[:id]
    return if game.go_fish.nil?

    redirect_to "#{game_path(game)}/game_over" if game.go_fish.winner?
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

  def game_over
    game = Game.find params[:id]
    game.go_fish.check_for_winner
    @winner = game.go_fish.winner
  end

  def play_round
    game = Game.find params[:id]
    game.play_round!(rank: params[:selected_rank], user_id: params[:selected_player].to_i)
    return redirect_to "#{game_path(game)}/game_over" if game.go_fish.winner?

    game.save!
    broadcast_game(game)
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.update(
          dom_id(game, current_user.id),
          partial: 'games/active_game', locals: { game: game, user: current_user }
        )
      end
      format.html { redirect_to game }
    end
  end

  private

  def game_params
    params.require(:game).permit(:player_count)
  end
end
