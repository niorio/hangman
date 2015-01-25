class Hangman
  MAX_WRONG = 8

  def initialize(guesser, checker)
    @guesser = guesser
    @checker = checker
    @num_remaining_guesses = MAX_WRONG
  end

  def game
    secret_length = @checker.register_secret_length
    @guesser.register_secret_length(secret_length)
    @board = [nil] * secret_length

    while @num_remaining_guesses > 0 && !won?
      guess = @guesser.get_guess
      response = @checker.check_guess(guess)
      if response.nil?
        @num_remaining_guesses-=1
      else
        update_board(guess, response)
      end

      @guesser.hand_response(guess, response)

    end

    won? ? puts "Guesser Wins!" : puts "Guesser Loses!"

    nil
  end

  private
  def update_board(letter, positions)
    positions.each { |position| @board[position] = letter }
  end

  def won?
    @board.all?
  end
end








if __FILE__ == $PROGRAM_NAME

  puts "Hangman! Is the guesser a human or computer? (h/c)"
  if gets.chomp.downcase == "c"
    player1 = ComputerPlayer.new
  else
    player2 = HumanPlayer.new
  end

  game = Hangman.new(player1, player2)

  game.play

end
