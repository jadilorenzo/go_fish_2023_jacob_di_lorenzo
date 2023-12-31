# frozen_string_literal: true

class GamesController < ApplicationController
  include ActionView::RecordIdentifier
  include GameBroadcaster

  def index
    @your_games = Game.started.games_for_user(current_user)
    @games_to_join = Game.pending - @your_games
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
      update_games
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
    results = game.play_round!(rank: params[:selected_rank], user_id: params[:selected_player].to_i)
    results.each { |result| RoundResult.new(content: result, game: game).save! }
    game.save!
    round_results = RoundResult.where(game_id: params[:id]).order(created_at: :desc)
    broadcast_game(game, round_results)
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.update(
          dom_id(game, current_user.id),
          partial: 'games/active_game', locals: { game: game, user: current_user, round_results: round_results }
        )
      end
      format.html { redirect_to game }
    end
  end

  private

  def update_games
    @your_games = Game.started.games_for_user(current_user)
    @games_to_join = Game.pending - @your_games
    broadcast_games @your_games, @games_to_join
  end

  def game_params
    params.require(:game).permit(:player_count)
  end
end
