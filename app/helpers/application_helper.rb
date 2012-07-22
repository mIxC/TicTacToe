module ApplicationHelper

  def title
    if @title.nil?
      'Tic Tack Toe | The ULTIMATE Game'
    else
      "#{@title} | Tic Tack Toe | The ULTIMATE Game"
    end
  end
  
  def pubnub
    Pubnub.new(
      "pub-048dc89b-2b8c-481e-9a4f-bb874847c3f6",  ## PUBLISH_KEY
      "sub-09d4f2ae-d435-11e1-ae47-0b88a5d68c46",  ## SUBSCRIBE_KEY
      "sec-NTQ4ZDg3MzUtMGFiMi00MGZmLTkzMjktMGExYjQ0Nzc4OTA4",  ## SECRET_KEY
      "",      ## CIPHER_KEY (Cipher key is Optional)
      false    ## SSL_ON?
    )
  end

end
