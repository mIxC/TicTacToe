require 'spec_helper'

describe Game do
  before(:each) do
    @user     = Factory(:user, :name => 'Adam')
    @user2    = Factory(:user, :name => 'Bob')
    @computer = Factory(:user, :name => 'computer')
    @attr     = {:name => 'Fun Game!', :user1_id => @user.id, :user2_id => @user2.id, :current_user => @user.id}
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

  describe 'no_moves_left method' do
    before(:each) do
      @game  = Game.create(@attr)
      @move1 = Factory(:move, :position => 1, :user_id => @user.id, :game_id => @game.id)
      @move2 = Factory(:move, :position => 2, :user_id => @user.id, :game_id => @game.id)
    end

    it 'should have a no_moves_left method' do
      @game.should respond_to(:no_moves_left?)
    end

    it 'should return false if moves are left' do
      @game.no_moves_left?.should_not be_true
    end

    it 'should return true if no moves are left' do
      @move1 = Factory(:move, :position => 3, :user_id => @user.id, :game_id => @game.id)
      @move2 = Factory(:move, :position => 4, :user_id => @user.id, :game_id => @game.id)
      @move3 = Factory(:move, :position => 5, :user_id => @user.id, :game_id => @game.id)
      @move4 = Factory(:move, :position => 6, :user_id => @user.id, :game_id => @game.id)
      @move5 = Factory(:move, :position => 7, :user_id => @user.id, :game_id => @game.id)
      @move6 = Factory(:move, :position => 8, :user_id => @user.id, :game_id => @game.id)
      @move7 = Factory(:move, :position => 9, :user_id => @user.id, :game_id => @game.id)
      @game.no_moves_left?.should be_true
    end

  end


  describe 'set_next_player method' do
    before(:each) do
      @game  = Game.create(@attr)
    end

    it 'should have a set_next_player method' do
      @game.should respond_to(:set_next_player)
    end

    it 'should set the next player' do
      @game.set_next_player
      @game.current_user.should == @user2.id
    end

  end

  describe 'check_game_status method' do
    before(:each) do
      @game  = Game.create(@attr)
    end

    it 'should have a check_game_status method' do
      @game.should respond_to(:check_game_status)
    end

    it 'should return nil if not over' do
      @game.check_game_status.should be_nil
    end

    it 'should return a user if won' do
      @move1 = Factory(:move, :position => 1, :user_id => @user.id, :game_id => @game.id)
      @move2 = Factory(:move, :position => 2, :user_id => @user.id, :game_id => @game.id)
      @move3 = Factory(:move, :position => 3, :user_id => @user.id, :game_id => @game.id)
      @game.check_game_status.should == [1, 2, 3]
      @game.outcome.should == @user.id
    end

    it 'should return draw if no moves left' do #this needs to be DRYed up
      Factory(:move, :position => 1, :user_id => @user.id, :game_id => @game.id)
      @game.update_attribute(:current_user, @user2.id)
      Factory(:move, :position => 2, :user_id => @user2.id, :game_id => @game.id)
      @game.update_attribute(:current_user, @user.id)
      Factory(:move, :position => 3, :user_id => @user.id, :game_id => @game.id)
      @game.update_attribute(:current_user, @user2.id)
      Factory(:move, :position => 4, :user_id => @user2.id, :game_id => @game.id)
      @game.update_attribute(:current_user, @user.id)
      Factory(:move, :position => 6, :user_id => @user.id, :game_id => @game.id)
      @game.update_attribute(:current_user, @user2.id)
      Factory(:move, :position => 5, :user_id => @user2.id, :game_id => @game.id)
      @game.update_attribute(:current_user, @user.id)
      Factory(:move, :position => 7, :user_id => @user.id, :game_id => @game.id)
      @game.update_attribute(:current_user, @user2.id)
      Factory(:move, :position => 9, :user_id => @user2.id, :game_id => @game.id)
      @game.update_attribute(:current_user, @user.id)
      Factory(:move, :position => 8, :user_id => @user.id, :game_id => @game.id)
      @game.check_game_status.should == 'draw'
      @game.outcome.should == 0
    end

  end

end
