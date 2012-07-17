class UsersController < ApplicationController

  def new
    @title = 'Sign Up'
    @user = User.new
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      sign_in @user
      flash[:success] = "Welcome to the ultimate tic tac toe game!"
      redirect_to @user
    else
      render 'new'
    end
  end

  def index
    @title = 'Users'
    @users = User.paginate(:page => params[:page])
  end

  def show
    @user  = User.find(params[:id])
    @games = Game.find(:all, :conditions => ['user1_id = ? or user2_id = ?', @user.id, @user.id])
    @gamesWon, @gamesLost, @gamesTied, @gamesPlaying = [0]*4
    @games.each do |g|
      @gamesWon     += 1 if g.outcome == @user.id
      @gamesLost    += 1 if !g.outcome.nil? && g.outcome != @user.id && g.outcome != 0
      @gamesTied    += 1 if g.outcome == 0
      @gamesPlaying += 1 if g.outcome.nil?
    end
    @title = @user.name
  end

end
