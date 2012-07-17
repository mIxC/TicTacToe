module GamesHelper

  def set_next_player(game)
    if game.user1_id == game.current_user
      game.update_attribute(:current_user, game.user2_id)
      game.user2_id
    elsif game.user2_id == game.current_user
      game.update_attribute(:current_user, game.user1_id)
      game.user1_id
    else
      return nil
    end
    if game.current_user == computer_player.id
      make_computer_move(game)
    end
  end

  def check_game_status(game)
    movesB = Array.new
    movesA = Array.new

    game.moves.each do |m|
      movesA << m.position if m.user_id == game.user1_id
      movesB << m.position if m.user_id == game.user2_id
    end
    
    winning_moves1 = winning_moves_filter(movesA)
    winning_moves2 = winning_moves_filter(movesB)
    
    if winning_moves1
      puts winning_moves1
      game.update_attribute(:outcome,game.user1_id)
      winning_moves1
    elsif winning_moves2
      puts winning_moves2
      game.update_attribute(:outcome,game.user2_id)
      winning_moves2
    elsif no_moves_left?(game)
      game.update_attribute(:outcome,0)
      'draw'
    else
      nil
    end
  end

  def winning_moves_filter(moves,criteria = 3)
    winning_path = winning_combinations.collect{|wm| moves & wm }
    winning_combination = nil
    winning_path.each {|aa|  winning_combination = aa if aa.length == criteria }
    winning_combination
  end

  def no_moves_left?(game)
    allMovesA = Array.new
    game.moves.each do |m|
      allMovesA << m.position
    end
    allMovesA = allMovesA.uniq.sort
    allMovesA == [1,2,3,4,5,6,7,8,9]
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
    set_next_player(game) unless check_game_status(game)
  end

  def computer_move(user_moves,opponent_moves)
    # so this is the plan.
    # first we check to see if we can win in the next move
    # if not, then we'll see if we have to block a winning move
    # and if not, then let's progress towards the most promising path

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

    puts possible_next_combos.inspect
    puts 'possible_next_combos'
    puts possible_opp_next_combos.inspect
    puts 'possible_opp_next_combos'

    winning_combination = nil
    possible_next_combos.each {|c| winning_combination ||= winning_moves_filter(c) }

    losing_combination = nil
    possible_opp_next_combos.each {|c| losing_combination ||= winning_moves_filter(c) }

    puts winning_combination.inspect
    puts 'winning_combination'
    puts losing_combination.inspect
    puts 'losing_combination'
    
    good_move = winning_moves_filter(available_moves,2)
    okay_move = winning_moves_filter(available_moves,1)

    if winning_combination
      puts 'first'
      (winning_combination - user_moves).first
    elsif losing_combination
      puts 'second'
      (losing_combination - opponent_moves).first
    elsif good_move
      puts 'third'
      (good_move - user_moves).first
    elsif okay_move
      puts 'fourth'
      (okay_move - user_moves).first
    else
      puts 'fifth'
      available_moves.sample
    end

  end

  private

    def winning_combinations
      [[1,2,3],[4,5,6],[7,8,9],[1,5,9],[3,5,7],[1,4,7],[2,5,8],[3,6,9]]
    end

end
