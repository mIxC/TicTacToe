module GamesHelper

  def winning_moves_filter(moves,criteria = 3)
    winning_path = winning_combinations.collect{|wm| moves & wm }
    winning_combination = nil
    winning_path.each {|aa|  winning_combination = aa if aa.length == criteria }
    winning_combination
  end

  def computer_player
    User.find_by_name('computer')
  end

  def make_computer_move(game)
    oMoves = Array.new
    uMoves = Array.new
    game.moves.each do |m|
      if m.user_id == computer_player.id
        uMoves << m.position
      else
        oMoves << m.position
      end
    end
    desired_move = computer_move(uMoves,oMoves)
    game.moves.create(:position => desired_move, :user_id => computer_player.id)
    game.set_next_player unless game.check_game_status
  end

  def computer_move(user_moves,opponent_moves)
    # so this is the plan.
    # first we check to see if we can win in the next move
    # if not, then we'll see if we have to block a winning move
    # then we'll look at the next best given move
    # and if nothing is apparent, then let's progress towards the most promising path

    available_moves = [1,2,3,4,5,6,7,8,9] - user_moves - opponent_moves

    possible_next_combos = Array.new
    available_moves.each do |m|
      possible_combo = user_moves.dup
      possible_combo << m
      possible_next_combos << possible_combo
    end

    possible_opp_next_combos = Array.new
    available_moves.each do |m|
      possible_combo = opponent_moves.dup
      possible_combo << m
      possible_opp_next_combos << possible_combo
    end

    winning_combination = nil
    possible_next_combos.each {|c| winning_combination ||= winning_moves_filter(c) }

    losing_combination = nil
    possible_opp_next_combos.each {|c| losing_combination ||= winning_moves_filter(c) }
    
    good_move = winning_moves_filter(available_moves,2)
    okay_move = winning_moves_filter(available_moves,1)

    if winning_combination
      (winning_combination - user_moves).first
    elsif losing_combination
      (losing_combination - opponent_moves).first
    elsif (user_moves + opponent_moves).empty?
      1
    elsif (user_moves.count - opponent_moves.count) >= 0
      strategyX(user_moves,opponent_moves)
    elsif good_move
      (good_move - user_moves).first
    elsif okay_move
      (okay_move - user_moves).first
    else
      available_moves.sample
    end

  end

  def strategyX(user_moves,opponent_moves)

    available_moves = [1,2,3,4,5,6,7,8,9] - user_moves - opponent_moves
    
    case opponent_moves.count

    when 0
      1
    
    when 1
      if opponent_moves.include?(5) # A
        9
      elsif !(opponent_moves & corners).empty? # B
        (available_moves & corners).sample
      elsif !(opponent_moves & edges).empty? # C
        5
      end

    when 2
      if opponent_moves.include?(5) && !(opponent_moves & corners).empty? # A 1
        (available_moves & corners).sample
      elsif !(opponent_moves & corners).empty? && !(opponent_moves & edges).empty? # B 1
        (available_moves & corners).sample
      elsif !(opponent_moves & edges).empty? && opponent_moves.include?(9)
        if opponent_moves.include?(2) || opponent_moves.include?(6)
          7
        else
          3
        end
      else
        available_moves.sample
      end
        
    else
      available_moves.sample

    end

  end

  private

    def winning_combinations
      [[1,2,3],[4,5,6],[7,8,9],[1,5,9],[3,5,7],[1,4,7],[2,5,8],[3,6,9]]
    end

    def corners
      [1,3,7,9]
    end

    def edges
      [2,4,6,8]
    end

end
