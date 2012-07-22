class MovesController < ApplicationController
  before_filter :authenticate
  before_filter :correct_user
  before_filter :check_in_progress

  def new
  end

  def create
    move = @game.moves.build(params)
    if move.save
      end_game = check_game_status(@game)
      if end_game == 'draw'
        flash[:success] = 'the game is a draw!!!'
      elsif end_game
        flash[:success] = "the game was won with #{end_game}"
      else
        flash[:success] = 'nice move bro!'
        set_next_player(@game)
        pubnub.publish({
          'channel' => @game.current_user.to_s,
          'message' => { 'type' => 'game_update', 'id' => @game.id.to_s, 'name' => @game.name.to_s },
          'callback' => lambda do |message|
             puts(message)
           end
        })
      end
    else
      flash[:error] = 'sorry, unable to save that move'
    end
    redirect_to @game
  end

  private

    def correct_user
      @game = Game.find_by_id(params[:game_id])
      unless @game && @game.current_user == current_user.id && params[:user_id].to_i == current_user.id.to_i
        flash[:error] = "I'm sorry #{current_user.name}, but I can't let you do that..."
        redirect_to root_path
      end
    end

    def check_in_progress
      if @game.outcome
        flash[:error] = 'game is already over!'
        redirect_to @game 
      end
    end

end
