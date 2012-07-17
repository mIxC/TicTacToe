class SessionsController < ApplicationController

  def new
    render 'new'
  end

  def create
    user = User.find_by_name(params[:session][:name])
    if user && user.authenticate(params[:session][:password])
      sign_in user
      redirect_to user
    else
      flash.now[:error] = 'sorry, that didnt work out'
      render 'new'
    end
  end

  def destroy
    sign_out
    redirect_to root_path
  end

end
