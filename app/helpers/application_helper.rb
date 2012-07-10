module ApplicationHelper

  def title
    if @title.nil?
      'Tic Tack Toe | The ULTIMATE Game'
    else
      "#{@title} | Tic Tack Toe | The ULTIMATE Game"
    end
  end

end
