require 'spec_helper'

describe UsersController do
render_views

  describe "GET 'new'" do
    it "should be successful" do
      get 'new'
      response.should be_success
    end
  end

  describe 'post create' do

    describe 'failure' do
      before(:each) do
        @attr = { :name => '', :password => '', :password_confirmation => ''}
      end
      
      it 'should not create a user' do
        lambda do
          post :create, :user => @attr
        end.should_not change(User, :count)
      end
      
      it 'should render the "new" page' do
        post :create, :user => @attr
        response.should render_template('new')
      end
    end

    describe 'success' do
      before(:each) do
          @attr = { :name => 'John Smith', :password => 'hoohum', :password_confirmation => 'hoohum'}
      end
      
      it 'should create a user' do
          lambda do
              post :create, :user => @attr
          end.should change(User, :count).by(1)
      end
      
      it 'should direct to the user show page' do
          post :create, :user => @attr
          response.should redirect_to(user_path(assigns(:user)))
      end
      
      it 'should sign the user in' do
          post :create, :user => @attr
          controller.should be_signed_in
      end
    end

  end

  describe 'GET "index"' do
    before(:each) do
        @user1 = Factory(:user)
        @user3 = Factory(:user, :name => 'Bob')
        @user4 = Factory(:user, :name => 'Tim')
        @users = [@user1, @user3, @user4]
        30.times do 
            @users << Factory(:user, :name => Factory.next(:name))
        end
    end
    
    it 'should be successful' do
        get :index
        response.should be_success
    end
    
    it 'should paginate users' do
        test_sign_in(@user1)
        get :index
        response.body.should have_selector('div.pagination')
        response.body.should have_selector('span.disabled', :content => 'Previous')
        response.body.should have_selector('a', :href => '/users?page=2', :content => '2')
        response.body.should have_selector('a', :href => '/users?page=2', :content => 'Next')
    end

    it 'should have an element and link for each user' do
      get :index
      @users[0..2].each do |user|
        response.body.should have_selector('a', :href => user_path(user), :content => user[:name])
      end
    end

  end

end
