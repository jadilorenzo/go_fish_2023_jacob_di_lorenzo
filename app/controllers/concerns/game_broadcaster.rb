module GameBroadcaster
  include ActionView::RecordIdentifier

  private

  def broadcast_game(game)
    game.users.each do |user|
      Turbo::StreamsChannel.broadcast_update_to(
        "games:#{game.id}:users:#{user.id}", # matches turbo_stream_from channel
        target: dom_id(game, user.id), # matches turbo_frame id
        partial: 'games/active_game', locals: { game: game, user: user }
      )
    end
  end
end
