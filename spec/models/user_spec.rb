require 'spec_helper'

describe User do
  before(:each) do
    @attr = {:name => 'Adam',
             :password => 'validPassword',
             :password_confirmation => 'validPassword'}
  end

  it 'should make a proper instance given valid attributes' do
    User.create!(@attr)
  end

  it 'should require a name' do
    no_name_user = User.new(@attr.merge(:name => ''))
    no_name_user.should_not be_valid
  end

  it 'should reject names that are too long' do
    long_name = 'a' * 51
    long_name_user = User.new(@attr.merge(:name => long_name))
    long_name_user.should_not be_valid
  end

  it 'should have a unique name' do
    User.create!(@attr)
    duplicate_user = User.new(@attr.merge(:name => 'ADAM'))
    duplicate_user.should_not be_valid
  end

  describe 'password validations' do
    
    it 'should have a password' do
      empty_pass_user = User.new(@attr.merge(:password => '', :password_confirmation => ''))
      empty_pass_user.should_not be_valid
    end
    
    it 'should have the password confirmation match the password' do
      wrong_pass = 'wrongPASS!'
      wrong_confirmation_user = User.new(@attr.merge(:password_confirmation => wrong_pass))
      wrong_confirmation_user.should_not be_valid
    end

    it 'should reject short passwords' do
      short_pass = 'a' * 5
      short_pass_user = User.new(@attr.merge(:password => short_pass, :password_confirmation => short_pass))
      short_pass_user.should_not be_valid
    end
    
    it 'should reject extremely long passwords' do
      long_pass = 'a' * 51
      long_pass_user = User.new(@attr.merge(:password => long_pass, :password_confirmation => long_pass))
      long_pass_user.should_not be_valid
    end
    
  end

  describe 'moves associations' do
    before(:each) do
      @user  = User.create(@attr)
      @game  = Factory(:game, :name => 'Moves Game!', :user1_id => @user.id, :user2_id => nil, :current_user => @user.id)
      @move1 = Factory(:move, :position => 1, :user_id => @user.id, :game_id => @game.id)
      @move2 = Factory(:move, :position => 2, :user_id => @user.id, :game_id => @game.id)
    end

    it 'should have a moves attribute' do
      @user.should respond_to(:moves)
    end

    it 'should have moves' do
      @user.moves.include?(@move1).should be_true
      @user.moves.include?(@move2).should be_true
    end

    it 'should destroy all related moves when destroyed' do
      @user.destroy
      [@move1, @move2].each do |m|
        Move.find_by_id(m.id).should be_nil
      end
    end

  end

end
