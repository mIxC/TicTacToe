require 'spec_helper'

describe Move do
  before(:each) do
    @user1 = Factory(:user, :name => 'Adam')
    @user2 = Factory(:user, :name => 'Bob')
    @game  = Factory(:game, :name => 'Fun Game!', :user1_id => @user1.id, :user2_id => @user2.id, :current_user => @user1.id)
    @attr  = {:position => 1, :user_id => @user1.id, :game_id => @game.id}
    #@move1 = Factory(:move, :user_id => @user1.id, :game_id => @game.id)
    #@move2 = Factory(:move, :user_id => @user1.id, :game_id => @game.id)
  end

  it 'should make a proper instance given valid attributes' do
    Move.create!(@attr)
  end

  it 'should require a presence of a move' do
    no_position = Move.new(@attr.merge(:position => nil))
    no_position.should_not be_valid
  end

  it 'should limit you to one of nine moves' do
    bad_position = Move.new(@attr.merge(:position => 10))
    bad_position.should_not be_valid
  end

  it 'should require a valid user' do
    not_a_user = Move.new(@attr.merge(:user_id => '999999'))
    not_a_user.should_not be_valid
  end

  it 'should require a valid game' do
    not_a_game = Move.new(@attr.merge(:game_id => '999999'))
    not_a_game.should_not be_valid
  end

  it 'should not let user place a move if not their turn' do
    wrong_user = Move.new(@attr.merge(:user_id => @user2.id))
    wrong_user.should_not be_valid
  end

  it 'should not let two moves in the same place' do
    @move1 = Factory(:move, :position => 1, :user_id => @user1.id, :game_id => @game.id)
    taken_move = Move.new(@attr.merge(:user_id => @user2.id))
    taken_move.should_not be_valid
  end

end
