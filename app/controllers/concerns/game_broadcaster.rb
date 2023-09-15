module GameBroadcaster
  include ActionView::RecordIdentifier

  private

  def broadcast_games(your_games, games_to_join)
    User.all.each do |user|
      Turbo::StreamsChannel.broadcast_update_to(
        "games:users:#{user.id}",
        target: dom_id(user, 'games'),
        partial: 'games/games', locals: { your_games: your_games, games_to_join: games_to_join }
      )
    end
  end

  def broadcast_game(game, round_results)
    game.users.each do |user|
      Turbo::StreamsChannel.broadcast_update_to(
        "games:#{game.id}:users:#{user.id}", # matches turbo_stream_from channel
        target: dom_id(game, user.id), # matches turbo_frame id
        partial: 'games/active_game', locals: { game: game, user: user, round_results: round_results }
      )
    end
  end
end
