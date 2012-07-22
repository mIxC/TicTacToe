require 'spec_helper'

describe Game do
  before(:each) do
    @user  = Factory(:user, :name => 'Adam')
    @user2 = Factory(:user, :name => 'Bob')
    @attr  = {:name => 'Fun Game!', :user1_id => @user.id, :user2_id => @user2.id, :current_user => @user.id}
  end

  it 'should make a proper instance given valid attributes' do
    Game.create!(@attr)
  end

  it 'should require a name' do
    no_name_game = Game.new(@attr.merge(:name => ''))
    no_name_game.should_not be_valid
  end

  it 'should reject names that are too long' do
    long_name = 'a' * 51
    long_name_game = Game.new(@attr.merge(:name => long_name))
    long_name_game.should_not be_valid
  end

  it 'should reject games with invalid user' do
    invalid_users_game = Game.new(@attr.merge(:user1_id => '999999'))
    invalid_users_game.should_not be_valid
  end

  describe 'moves associations' do
    before(:each) do
      @game  = Game.create(@attr)
      @move1 = Factory(:move, :position => 1, :user_id => @user.id, :game_id => @game.id)
      @move2 = Factory(:move, :position => 2, :user_id => @user.id, :game_id => @game.id)
    end

    it 'should have a moves attribute' do
      @game.should respond_to(:moves)
    end

    it 'should have moves' do
      @game.moves.include?(@move1).should be_true
      @game.moves.include?(@move2).should be_true
    end

    it 'should destroy all related moves when destroyed' do
      @game.destroy
      [@move1, @move2].each do |m|
        Move.find_by_id(m.id).should be_nil
      end
    end

  end

end
