require 'spec_helper'

describe GamesController do
  render_views
  before(:each) do
    @user1    = Factory(:user, :name => 'Adam')
    @user2    = Factory(:user, :name => 'Bob')
    @computer = Factory(:user, :name => 'computer')
  end

  describe 'post "create"' do

    describe 'authenticated' do
      before(:each) do
        @user1 = test_sign_in(@user1)
      end

      describe 'valid' do

        it 'should create an open game' do
          lambda do
            post :create, :name => 'gameName', :opponent => 'undetermined'
          end.should change(Game, :count).by(1)
        end

        it 'should redirect to the users page for open games' do
          post :create, :name => 'gameName', :opponent => 'undetermined' 
          response.should redirect_to(@user1)
        end

        it 'should create a user game' do
          lambda do
            post :create, :name => 'gameName', :opponent => 'user', :user2 => {:id => @user2.id}
          end.should change(Game, :count).by(1)
        end

        it 'should redirect to the game for user games' do
          post :create, :name => 'gameName', :opponent => 'user', :user2 => {:id => @user2.id}
          response.should redirect_to(game_path(assigns(:game)))
        end

        it 'should create a computer game' do
          lambda do
            post :create, :name => 'gameName', :opponent => 'computer'
          end.should change(Game, :count).by(1)
        end

        it 'should redirect to the game for computer games' do
          post :create, :name => 'gameName', :opponent => 'computer' 
          response.should redirect_to(game_path(assigns(:game)))
        end

      end

      describe 'invalid' do
      end

    end

    describe 'unauthenticated' do

      it 'should not create a valid open game' do
        lambda do
          post :create, :name => 'gameName', :opponent => 'undetermined'
        end.should_not change(Game, :count)
      end

      it 'should not create a valid opponent game' do
        lambda do
          post :create, :name => 'gameName', :opponent => 'user', :user2 => {:id => @user2.id}
        end.should_not change(Game, :count)
      end

      it 'should not create a valid computer game' do
        lambda do
          post :create, :name => 'gameName', :opponent => 'computer'
        end.should_not change(Game, :count)
      end

    end

  end #end 'post "create"'

  describe 'get "new"' do

    describe 'authenticated' do
      before(:each) do
        @user1 = test_sign_in(@user1)
      end

      it 'should render the right page' do
        get :new
        response.should render_template(:new)
      end

      it 'should have submit button' do
        get :new
        response.body.should have_selector('input', :type => 'submit')
      end

    end

    describe 'unauthenticated' do

      it 'should redirect to sign in page' do
        get :new
        response.should redirect_to(signin_path)
      end

      it 'should have a flash message' do
        get :new
        flash[:error].should =~ /sign in/i
      end

    end

  end #end 'get "new"'

  describe 'get "show"' do
    before (:each) do
      @game  = Factory(:game, :name => 'Sweet Game', :user1_id => @user1.id, :user2_id => @user2.id, :current_user => @user1.id)
      @move1 = Factory(:move, :position => 1, :user_id => @user1.id, :game_id => @game.id)
      #@move2 = Factory(:move, :position => 2, :user_id => @user2.id, :game_id => @game.id)
      @gameB = Factory(:game, :name => 'Open Game', :user1_id => @user1.id, :user2_id => nil, :current_user => @user1.id)
    end

    it 'should be successful' do
      get :show, :id => @game.id
      response.should be_success
    end

    it 'should find the right game' do
      get :show, :id => @game.id
      assigns(:game).should == @game
    end

    it 'should show the game name' do
      get :show, :id => @game.id
      response.body.should have_selector('h1', :content => @game.name)
    end

    it 'should show the first player\'s name' do
      get :show, :id => @game.id
      response.body.should have_selector('a', :content => @user1.name)
    end

    it 'should show the second player\'s name' do
      get :show, :id => @game.id
      response.body.should have_selector('a', :content => @user2.name)
    end

    it 'should say it\'s the first players move' do
      get :show, :id => @game.id
      response.body.should have_selector('div', :content => "Adam's turn")
    end

    it 'should redirect to a listing of games for incomplete games' do
      get :show, :id => @gameB.id
      response.should redirect_to(root_path)
    end

    it 'should redirect to a listing of games for incomplete games' do
      get :show, :id => @gameB.id
      flash[:notice].should =~ /dont have/i
    end

  end #end 'get "show"'

  describe 'get "index"' do
    before(:each) do
      @game1  = Factory(:game, :name => 'first Open Game',  :user1_id => @user1.id, :user2_id => nil, :current_user => @user1.id)
      @game2  = Factory(:game, :name => 'second Open Game', :user1_id => @user2.id, :user2_id => nil, :current_user => @user2.id)
      @games  = [@game1, @game2]
      50.times do
        @games << Factory(:game, :name => Factory.next(:name), :user1_id => @user1.id, :user2_id => @user2.id, :current_user => @user1.id)
      end
    end

      it 'should be successful' do
        get :index
        response.should be_success
      end

      it 'should have a link to each game' do
        get :index
        @games[1..5].each do |game|
          response.body.should have_selector('a', :href => game_path(game), :content => game.name)
        end
      end

      it 'should have a link to first player' do
        get :index
        @games[5..7].each do |game|
          response.body.should have_selector('a', :href => user_path(@user1), :content => @user1.name)
        end
      end

      it 'should have a link to second player' do
        get :index
        @games[5..7].each do |game|
          response.body.should have_selector('a', :href => user_path(@user2), :content => @user2.name)
        end
      end

      it 'should say no one! for second player for open games' do
        get :index
        @games[1..2].each do |game|
          response.body.should have_selector('td', :content => 'no one!')
        end
      end

      it 'should paginate games' do
        get :index
        response.body.should have_selector('a', :href => '/games?page=2', :content => 'Next')
        response.body.should have_selector('a', :href => '/games?page=2', :content => '2')
      end

      describe 'signed in' do
        before(:each) do
          test_sign_in(@user1)
        end

        it 'should have a link to join an open game if not first player' do
          get :index
          response.body.should have_selector('a', :href => game_path(@game2, :user2_id => @user1.id), :content => 'join game', :'data-method' => 'put')
        end

      end

  end #end 'get "index"'

  describe 'put "update"' do
    before(:each) do
      @gameOpen   = Factory(:game, :user1_id => @user1.id, :user2_id => nil, :current_user => @user1.id)
      @gameClosed = Factory(:game, :user1_id => @user1.id, :user2_id => @user2.id, :current_user => @user1.id)
      @user3      = Factory(:user, :name => 'thirdGuy')
    end

    describe 'authenticated' do
      before(:each) do
        test_sign_in(@user3)
      end

      it 'should be able to join an open game' do
        put :update, :id => @gameOpen.id, :user2_id => @user3.id
        response.should redirect_to(@gameOpen)
        assigns(:game).user2_id.should == @user3.id
      end

      it 'should not be able to join a closed game' do
        put :update, :id => @gameClosed.id, :user2_id => @user3.id
        response.should redirect_to(:action => :index)
        flash[:error].should =~ /sorry/i
      end

    end

    it 'should not allow unauthenticated joins' do
      put :update, :id => @gameOpen.id
      response.should redirect_to(:action => :index)
      flash[:error].should =~ /sorry/i
    end

  end #end 'put "update"'

end
