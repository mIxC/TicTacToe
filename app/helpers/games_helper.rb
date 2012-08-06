module GamesHelper

  def winning_moves_filter(moves,criteria = 3)
    winning_path = winning_combinations.collect{|wm| moves & wm }
    winning_combination = nil
    winning_path.each {|aa|  winning_combination = aa if aa.length == criteria }
    winning_combination
  end

  def position_display(game)
    @pos = Hash.new

    9.times do |p|
      p += 1
      if signed_in? && current_user.id == game.current_user && game.outcome.nil?
        @pos[p] = link_to 'move here', {:controller => 'moves', :action => 'create', :position => p, :user_id => current_user.id, :game_id => game.id}, :method => :post
      else
        @pos[p] = '<span class="empty-move">.</span>'.html_safe
      end
    end

    game.moves.each do |m|
      if m.user_id == game.user1_id
        @pos[m.position] = '<b>X</b>'.html_safe
      elsif m.user_id == game.user2_id
        @pos[m.position] = '<b>O</b>'.html_safe
      end
    end

    @pos
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

    if winning_combination
      (winning_combination - user_moves).first
    elsif losing_combination
      (losing_combination - opponent_moves).first
    elsif (user_moves + opponent_moves).empty?
      1
    elsif (user_moves.count - opponent_moves.count) >= 0
      strategyX(user_moves,opponent_moves) || available_moves.sample
    else
      strategyO(user_moves,opponent_moves) || available_moves.sample
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

  def strategyO(user_moves,opponent_moves)

    available_moves = [1,2,3,4,5,6,7,8,9] - user_moves - opponent_moves

    case opponent_moves.count
      when 1
        if opponent_moves.include?(5)
          (available_moves & corners).sample
        else
          5
        end
      when 2
        if opponent_moves.include?(5)
          (available_moves & corners).sample
        elsif (opponent_moves & corners).count == 1 && (opponent_moves & edges).count == 1
          caddy_corners[(opponent_moves & corners).first]
        elsif (opponent_moves & edges).count == 2
          borderedCorner = nil
          corner_borders.each do |c,k|
            if (opponent_moves & corner_borders[c]).count == 2
              borderedCorner = c
            end
          end
          if borderedCorner
            borderedCorner
          else
            (available_moves & edges).sample
          end
        elsif (opponent_moves & [1,9]).count == 2 || (opponent_moves & [3,7]).count == 2
          (available_moves & edges).sample
        else
          available_moves.sample
        end
      when 3
        singleBorderedCorner = nil
        corner_borders.each do |k,v|
          if (opponent_moves & v).count == 1
            singleBorderedCorner = k
          end
        end
        singleBorderedCorner || (available_moves & edges).sample
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

    def caddy_corners
      {1=>9,3=>7,9=>1,7=>3}
    end

    def corner_borders
      {1=>[2,4],3=>[2,6],7=>[4,8],9=>[6,8]}
    end

end
