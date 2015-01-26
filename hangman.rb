require 'byebug'
class Hangman
  MAX_WRONG = 8

  def initialize(guesser, checker)
    @guesser = guesser
    @checker = checker
    @num_remaining_guesses = MAX_WRONG
  end

  def game
    secret_length = @checker.pick_word
    @guesser.register_secret_length(secret_length)
    @board = [nil] * secret_length

    while @num_remaining_guesses > 0 && !won?
      guess = @guesser.get_guess(@board, @num_remaining_guesses)
      response = @checker.check_guess(guess)
      if response.empty?
        @num_remaining_guesses-=1
      else
        update_board(guess, response)
      end

      @guesser.handle_response(guess, response)

    end

    won? ? puts("Guesser Wins!") : puts("Guesser Loses!")

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


class HumanPlayer

  def register_secret_length(secret_length)

    puts "The word is #{secret_length} letters long."
  end

  def get_guess(board, num_remaining_guesses)
    puts "You have #{num_remaining_guesses} guesses left"
    board.each {|letter| letter.nil? ? print("_") : print(letter)}

    print "\nYour guess: "
    gets.chomp
  end

  def check_guess(guess)
    puts "Opponent guessed #{guess}"
    puts "What positions does this letter occur at? (if none press enter)"

    positions = gets.chomp.split(",")
    positions.map! {|pos| pos.to_i-1}  #index begins at 1 for easier understanding
    positions

  end

  def handle_response(guess, response)
    #only the computer needs this method.  a human can see what's on screen.
  end

  def pick_word
    print "Think of a word. How long is it? "
    gets.chomp.to_i
  end


end

class ComputerPlayer

  def initialize(dict_name)
    @dictionary = File.readlines(dict_name).map(&:chomp)
    @used_letters = []
  end

  def pick_word
    @secret_word = @dictionary.sample
    @secret_word.length
  end

  def register_secret_length(secret_length)
    @candidates = @dictionary.dup
    @candidates.select! {|word| word.length == secret_length}
    @known = [nil] * secret_length
  end

  def get_guess(board, num_remaining_guesses)
    puts "#{num_remaining_guesses} guesses left"
    board.each {|letter| letter.nil? ? print("_") : print(letter)}
    print "\n"

    letter_freq = Hash.new(0)

    @candidates.each do |candidate|
      candidate.each_char do |char|
        next if @used_letters.include?(char)
        letter_freq[char] += 1
      end
    end

    frequencies = letter_freq.sort_by{|letter, freq| freq}
    best_letter = frequencies.last[0] #most frequent letter

    @used_letters << best_letter

    best_letter

  end

  def check_guess(guess)

    positions = []
    @secret_word.each_char.with_index do |char, i|
      positions << i if char == guess
    end
    positions

  end

  def handle_response(guess, response)
    #update understanding of the word
    response.each {|pos| @known[pos] = guess}

    #narrow candidates
    @candidates.select! do |candidate|
      candidate.each_char.with_index.all? do |char, i|
        @known[i].nil? || @known[i] == char
      end
    end

  end

end





if __FILE__ == $PROGRAM_NAME

  puts "Hangman! Is the guesser a human or computer? (h/c)"
  if gets.chomp.downcase == "c"
    player1 = ComputerPlayer.new('dictionary.txt')
  else
    player1 = HumanPlayer.new
  end

  puts "Is the checker a human or computer? (h/c)"
  if gets.chomp.downcase == "h"
    player2 = HumanPlayer.new
  else
    player2 = ComputerPlayer.new('dictionary.txt')
  end

  game = Hangman.new(player1, player2)

  game.game

end
