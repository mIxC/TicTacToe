require 'spec_helper'

describe MovesController do
render_views
  before(:each) do
    @user1    = Factory(:user, :name => 'Adam')
    @user2    = Factory(:user, :name => 'Bob')
    @computer = Factory(:user, :name => 'computer')
    @game1    = Factory(:game, :name => 'Awesome Game', :user1_id => @user1.id, :user2_id => @user2.id, :current_user => @user1.id)
  end

  describe 'post "create"' do

    describe 'authenticated' do
      before(:each) do
        test_sign_in(@user1)
      end

      describe 'valid' do
        before(:each) do
          @validMove = {:position => 1, :user_id => @user1.id, :game_id => @game1.id}
        end

        it 'should create a new move' do
          lambda do
            post :create, @validMove
          end.should change(Move, :count).by(1)
        end

        it 'should redirect to game after move made' do
          post :create, @validMove
          response.should redirect_to(@game1)
        end

        it 'should set next player after move is made' do
          post :create, @validMove
          assigns(:game).current_user.should == @user2.id
        end

        it 'should set winner if winning move' do
          @move1 = Factory(:move, :position => 1, :user_id => @user1.id, :game_id => @game1.id)
          @move2 = Factory(:move, :position => 2, :user_id => @user1.id, :game_id => @game1.id)
          post :create, :position => 3, :user_id => @user1.id, :game_id => @game1.id
          assigns(:game).outcome.should == @user1.id
        end

        it 'should set as draw if last move' do #this needs to be DRYed up
          Factory(:move, :position => 1, :user_id => @user1.id, :game_id => @game1.id)
          @game1.update_attribute(:current_user, @user2.id)
          Factory(:move, :position => 2, :user_id => @user2.id, :game_id => @game1.id)
          @game1.update_attribute(:current_user, @user1.id)
          Factory(:move, :position => 3, :user_id => @user1.id, :game_id => @game1.id)
          @game1.update_attribute(:current_user, @user2.id)
          Factory(:move, :position => 4, :user_id => @user2.id, :game_id => @game1.id)
          @game1.update_attribute(:current_user, @user1.id)
          Factory(:move, :position => 6, :user_id => @user1.id, :game_id => @game1.id)
          @game1.update_attribute(:current_user, @user2.id)
          Factory(:move, :position => 5, :user_id => @user2.id, :game_id => @game1.id)
          @game1.update_attribute(:current_user, @user1.id)
          Factory(:move, :position => 7, :user_id => @user1.id, :game_id => @game1.id)
          @game1.update_attribute(:current_user, @user2.id)
          Factory(:move, :position => 9, :user_id => @user2.id, :game_id => @game1.id)
          @game1.update_attribute(:current_user, @user1.id)
          post :create, :position => 8, :user_id => @user1.id, :game_id => @game1.id
          assigns(:game).outcome.should == 0
        end

        it 'should not have a game outcome yet' do
          post :create, :position => 3, :user_id => @user1.id, :game_id => @game1.id
          assigns(:game).outcome.should == nil
        end

      end

      describe 'invalid' do

        it 'should not let you create moves for other players' do
          lambda do
            post :create, :position => 1, :game_id => @game1.id, :user_id => @user2.id
          end.should_not change(Move, :count)
        end

      end

    end

    describe 'unauthenticated' do

      it 'should not create unauthenticated moves' do
        lambda do
          post :create, :position => 1, :user_id => @user1.id, :game_id => @game1.id
        end.should_not change(Move, :count)
      end

    end

  end #end 'post "create"'

end