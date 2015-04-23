class Hangman
  def initialize(guessing_player, checking_player)
    @guesser = guessing_player
    @checker = checking_player
  end

  def display
     puts "Secret word: " + @checker.working_word.join("")
  end

  def guess
    @guesser.ask_guess
  end

  def check(guess)
    @checker.update_working_word(guess)
  end

  def play
    @checker.make_word
    p @guesser.intelligent_guesses(@checker.secret_word.length)
    display

    until won?
      check(guess)
      display
    end

    puts "You won!"
  end

  def won?
    @checker.win?
  end
end

class HumanPlayer
  attr_reader :secret_word, :working_word

  def make_word
    puts "How long is your word?"
    word_length = Integer(gets.chomp)
    @secret_word = "*" * word_length
    @working_word = Array.new(@secret_word.length) { "_" }
  end

  def valid_positions(pos)
    valid = false
    pos.all? do |position|
      position.to_i.between?(0, @secret_word.length - 1)
    end
    # pos.each do |position|
    #   valid = true
    #   valid = false if !position.to_i.between?(0, @secret_word.length - 1)
    # end
    valid == false ? puts("Please enter valid positions.") : (return true)
  end

  def update_working_word(guess)
    response = gets.chomp.upcase

    if response == "Y"
      puts "\nWhere's the letter located? [X Y]"
      pos = nil
      loop do
        pos = gets.chomp.split(' ')
        break if valid_positions(pos)
      end

      pos.each do |position|
        @working_word[position.to_i] = guess
      end
    end
  end

  def intelligent_guesses(num)
  end

  def win?
    !@working_word.include?('_')
  end

  #used when a guesser
  def ask_guess
    guess = gets.chomp.downcase
    check_guess_is_valid?(guess) ? guess : ask_guess
  end

  def check_guess_is_valid?(guess)
    letters = ("a".."z").to_a
    letters.include?(guess) ? true : puts("That's not a letter.\n\n")
  end
end

class ComputerPlayer
  attr_reader :secret_word, :working_word

  def initialize
    @letters = ("e".."o").to_a
  end

  # used when a checker
  def make_word
    @secret_word = File.readlines('dictionary.txt').sample.chomp.downcase.split('')
    @working_word = Array.new(@secret_word.length) { "_" }
  end

  def update_working_word(guess)
    # pos = []
    # @secret_word.each_with_index do |letter, i|
    #   pos << i if @secret_word[i] == letter
    # end
    pos = @secret_word.length.times.select { |letter| @secret_word[letter] == guess }
    pos.each do |position|
      @working_word[position] = guess
    end
  end

  def win?
    @working_word == @secret_word
  end

  #used when a guesser
  def intelligent_guesses(num)
    word_options = File.readlines('dictionary.txt').select do |word|
      word.length == num
    end

    most_common_letters = {}
    word_options.join("").split("\n").join("").each_char do |letter|
      if most_common_letters.has_key?(letter)
        most_common_letters[letter] += 1
      else
        most_common_letters[letter] = 1
      end
    end

    @most_common_letters = most_common_letters

  end

  def ask_guess
    max = @most_common_letters.values.max
    guess = @most_common_letters.key(max)
    @most_common_letters.delete(guess)

    # guess = @letters.sample
    # @letters.delete(guess)
    # puts "Is there an #{guess}? [Y/N]?"
    # return guess
  end
end


comp = ComputerPlayer.new
human = HumanPlayer.new
 h = Hangman.new(comp, human)
 h.play
