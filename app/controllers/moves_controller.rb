class MovesController < ApplicationController
  before_filter :authenticate
  before_filter :correct_user
  before_filter :check_in_progress

  def new
  end

  def create
    move = @game.moves.build(params)
    if move.save
      end_game = @game.check_game_status
      if end_game == 'draw'
        message = {'type'    => 'alert',
                   'alert'   => 'notice',
                   'game_id' => @game.id.to_s,
                   'message' => "The game #{view_context.link_to @game.name, game_path(@game)} was a draw!"}
        pubnub.publish({'channel' => @game.user1_id.to_s,'message' => message,'callback'=>lambda{|m|}})
        pubnub.publish({'channel' => @game.user2_id.to_s,'message' => message,'callback'=>lambda{|m|}})
      elsif end_game
        message = {'type'    => 'alert',
                   'alert'   => 'notice',
                   'game_id' => @game.id.to_s,
                   'message' => "The game #{view_context.link_to @game.name, game_path(@game)} was won with #{end_game}"}
        pubnub.publish({'channel' => @game.user1_id.to_s,'message' => message,'callback'=>lambda{|m|}})
        pubnub.publish({'channel' => @game.user2_id.to_s,'message' => message,'callback'=>lambda{|m|}})
      else
        flash[:success] = 'nice move!'
        @game.set_next_player
        pubnub.publish({
          'channel' => @game.current_user.to_s,
          'message' => { 'type'    => 'alert',
                         'alert'   => 'success',
                         'game_id' => @game.id.to_s,
                         'message' => "You're move in the game #{view_context.link_to @game.name, game_path(@game)}"},
                         'callback'=> lambda do |message|
                            #puts(message)
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
