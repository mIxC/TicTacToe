require 'spec_helper'

describe GamesController do
render_views

  describe "GET 'new'" do
    it "should be successful" do
      get 'new'
      response.should be_success
    end
  end

    describe 'access control' do
        
        it 'should deny access to create if not signed in' do
            post :create
            response.should redirect_to(signin_path)
        end
        
        it 'should deny access to destroy if not signed in' do
            delete :destroy, :id => 1
            response.should redirect_to(signin_path)
        end
        
    end
    
  describe "POST 'create'" do

    before(:each) do
      @user = test_sign_in(Factory(:user))
    end

    describe "failure" do

      before(:each) do
        @attr = { :content => "" }
      end

      it "should not create a game" do
        lambda do
          post :create, :game => @attr
        end.should_not change(game, :count)
      end

      it "should render the home page" do
        post :create, :game => @attr
        response.should render_template('pages/home')
      end
    end

    describe "success" do

      before(:each) do
        first_user = Factory(:user, :name => 'Tim', :email => 'tallen@homeimprovement.com')
        second_user = Factory(:user, :name => 'Bob', :email => 'bvilla@homeimprovement.com') 
        @attr = { :name => "Lorem ipsum", :user1_id => first_user.id, :user2_id => second_user.id }
      end

      it "should create a game" do
        lambda do
          post :create, :game => @attr
        end.should change(game, :count).by(1)
      end

      it "should redirect to the game page" do
        post :create, :game => @attr
        response.should redirect_to(game_path)
      end

      it "should have a flash message" do
        post :create, :game => @attr
        flash[:success].should =~ /created/i
      end
    end
  end

end
