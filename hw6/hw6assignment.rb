# Programming Languages, Homework 6, hw6runner.rb

# This is the only file you turn in,
# so do not modify the other files as
# part of your solution.

class MyPiece < Piece
  # The constant All_My_Pieces should be declared here:

  All_My_Pieces = Piece::All_Pieces + [
    [[[-2,0], [-1,0], [0,0], [1,0], [2,0]],         # extra long
     [[0,2], [0,1], [0,0], [0,-1], [0,-2]]],
      rotations([[0,0], [1,0], [0,1]]),               # short L
      rotations([[-1,0], [0,0], [1,0], [-1,1], [0,1]])] # short fat L

  # rotate piece 180
  def rotate_180
    # Ensures that the flip will always be a possible formation (as opposed 
    # to nil) by altering the intended coordinates so that it stays 
    # within the bounds of the rotation array
    moved = true
    potential = @all_rotations[(@rotation_index + 2) % @all_rotations.size]
    # for each individual block in the piece, checks if the intended move
    # will put this block in an occupied space
    potential.each{|posns| 
      if !(@board.empty_at([posns[0] + @base_position[0],
                            posns[1] + @base_position[1]]));
        moved = false;  
      end
    }
    if moved
      @rotation_index = (@rotation_index + 2) % @all_rotations.size
    end
    moved
  end

  # class method to genereate a cheat piece
  def self.cheat_piece (board)
    MyPiece.new([[[0,0]]], board)
  end

  # class method to choose the next piece
  def self.next_piece (board)
    MyPiece.new(All_My_Pieces.sample, board)
  end

  # gets number of blocks in current piece
  def size ()
    @all_rotations[0].length()
  end
end

class MyBoard < Board
  def initialize (game)
    @grid = Array.new(num_rows) {Array.new(num_columns)}
    @current_block = MyPiece.next_piece(self)
    @score = 0
    @game = game
    @delay = 500
    @cheating = false
  end

  # rotates the current piece by 180 degrees
  def rotate_180
    if !game_over? and @game.is_running?
      @current_block.rotate_180()
    end
    draw
  end

  # gets the next piece
  def next_piece
    if @cheating == true
      @current_block = MyPiece.cheat_piece(self)
      @cheating = false
    else
      @current_block = MyPiece.next_piece(self)
    end
    @current_pos = nil
  end

  # gives player 1x1 piece and deducts 100 points
  # if their score > 100
  def cheat
    if !game_over? and @game.is_running?
      if !@cheating and @score >= 100
        @cheating = true
        @score -= 100
      end
    end
    draw
  end

  # gets the information from the current piece about where it is and uses this
  # to store the piece on the board itself.  Then calls remove_filled.
  def store_current
    locations = @current_block.current_rotation
    displacement = @current_block.position
    (0..@current_block.size-1).each{|index| 
      current = locations[index];
      @grid[current[1]+displacement[1]][current[0]+displacement[0]] = 
      @current_pos[index]
    }
    remove_filled
    @delay = [@delay - 2, 80].max
  end
end

class MyTetris < Tetris
  # creates a canvas and the board that interacts with it
  def set_board
    @canvas = TetrisCanvas.new
    @board = MyBoard.new(self)
    @canvas.place(@board.block_size * @board.num_rows + 3,
                  @board.block_size * @board.num_columns + 6, 24, 80)
    @board.draw
  end

  # extend key bindings in Tetris class
  def key_bindings
    super
    @root.bind('u', proc {@board.rotate_180})
    @root.bind('c', proc {@board.cheat})
  end
end

class MyPieceChallenge < MyPiece
end

class MyBoardChallenge < MyBoard
  def initialize (game)
    super
    @next_block = MyPieceChallenge.next_piece(self)
  end

  # gets the next piece
  def next_piece
    @current_block = @next_block
    @next_block = MyPieceChallenge.next_piece(self)
    @current_pos = nil
    @cheating = false
  end

  # gives player 1x1 piece and deducts 100 points
  # if their score > 100
  def cheat
    if !game_over? and @game.is_running?
      if !@cheating and @score >= 100
        @cheating = true
        @next_block = MyPieceChallenge.cheat_piece(self)
        @score -= 100
      end
    end
    draw
  end

  # moves the current piece down
  def move_down
    if @game.is_running?
      ran = @current_block.drop_by_one
      if !ran
        store_current
        if !game_over?
          next_piece
        end
      else
        @score += 1
      end
      @game.update_score
      draw
    end
  end
end

class MyTetrisChallenge < MyTetris
  def set_board
    @canvas = TetrisCanvas.new
    @board = MyBoardChallenge.new(self)
    @canvas.place(@board.block_size * @board.num_rows + 3,
                  @board.block_size * @board.num_columns + 6, 24, 80)
    @board.draw
  end

  # extend key bindings in MyTetris class
  def key_bindings
    super
    @root.bind('Return', proc {@board.move_down})
  end
end

