class GamesController < ApplicationController
  before_filter :authenticate, :only => [:join, :create, :new]

  def new
    @title = 'Create a New Game'
    @game = Game.new
  end

  def update
    @game = Game.find_by_id(params[:id])
    @user = User.find_by_id(params[:user2_id])
    if @game && @user && @game.user2_id.nil?
      if @game.update_attribute(:user2_id, @user.id)
        pubnub.publish({
          'channel' => @game.user1_id.to_s,
          'message' => { 'type'    => 'alert',
                         'alert'   => 'success',
                         'game_id' => @game.id.to_s,
                         'message' => "Someone joined your game! Game #{view_context.link_to @game.name, game_path(@game)}"},
                         'callback'=> lambda do |message|
                            #puts(message)
                          end
        })
        redirect_to @game
      else
        @games = Game.paginate(:page => params[:page])
        flash[:error] = 'sorry, something happened'
        redirect_to :action => :index
      end
    else
      flash[:error] = 'sorry, can\'t join'
      redirect_to :action => :index
    end
  end

  def index
    @title = 'Games'
    @games = Game.paginate(:page => params[:page])
  end

  def create
    gameName = params[:name]
    user1 = current_user

    case params[:opponent]

    when 'user'
      user2 = User.find_by_name(params[:user2_name])
      if user2
        @game = Game.new(:name => gameName, :user1_id => user1.id, :user2_id => user2.id, :current_user => user1.id)
        if @game.save
          pubnub.publish({
            'channel' => @game.user2_id.to_s,
            'message' => { 'type'    => 'alert',
                           'alert'   => 'success',
                           'game_id' => @game.id.to_s,
                           'message' => "Someone challenged you to a game! Game #{view_context.link_to @game.name, game_path(@game)}"},
                           'callback'=> lambda do |message|
                              #puts(message)
                            end
          })
          flash[:success] = "game made between you and #{user2.name}!"
          redirect_to @game
        else
          flash.now[:error] = "sorry, couldn't create that game"
          render 'new'
        end
      else
        flash.now[:error] = 'sorry, thats not a real user...'
        render 'new'
      end

    when 'undetermined'
      @game = Game.new(:name => gameName, :user1_id => user1.id, :current_user => user1.id)
      if @game.save
        flash[:success] = "game made! now go get someone to join your game!"
        redirect_to current_user
      else
        render 'new'
      end

    when 'computer'
      if computer_player
        @game = Game.new(:name => gameName, :user1_id => user1.id, :user2_id => computer_player.id, :current_user => computer_player.id)
        if @game.save
          make_computer_move(@game)
          flash[:success] = "game made between you and the computer!"
          redirect_to @game
        else
          flash.now[:error] = "sorry, couldn't create that game"
          render 'new'
        end
      else
        flash.now[:error] = 'sorry, the computer has ran away...'
        render 'new'
      end

    else
      flash.now[:error] = 'please make a valid opponent choice!'
      render 'new'

    end
 
  end

  def show
    @game = Game.find_by_id(params[:id])
    @user1 = User.find_by_id(@game.user1_id) if @game.user1_id
    @user2 = User.find_by_id(@game.user2_id) if @game.user2_id
    if @game && @user1 && @user2
      @title = @game.name
      @userMoves = @game.moves.where(:user_id => [@user1.id,@user2.id])
      render 'show'
    else
      flash[:notice] = 'we dont have everything we need'
      redirect_to root_path
    end
  end

end
