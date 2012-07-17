require 'spec_helper'

describe MovesController do
render_views

  describe 'post create' do
    before(:each) do
      @user = test_sign_in(Factory(:user))
      @game = Factory(:game)
    end

    describe 'success' do
      before(:each) do
        @attr = { :position => 1, :user_id => @user.id, :game_id => @game.id }
      end

      it "should create a Move" do
        lambda do
          post :create, :move => @attr
        end.should change(Move, :count).by(1)
      end

      it "should redirect to the game page" do
        post :create, :move => @attr
        response.should redirect_to(@game)
      end

      it "should have a flash message" do
        post :create, :move => @attr
        flash[:success].should =~ /nice/i
      end
    end
    
  end
end
