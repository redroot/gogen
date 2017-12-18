class Gogen
  TEXT_INPUT_SPLIT = "#####"
  GRID_SIZE = 5
  PRINT_PADDING = 3
  BLANK_CHARACTER = '_'


  def initialize(input)
    initialize_from_text(input) if input.is_a?(String)
  end

  def initialize_from_text(input)
    parts = input.split(TEXT_INPUT_SPLIT)
    # transforms V _ D _ J\n_ _ _ _ _\nQ _ R _ S\n_ _ _ _ _\nX _ H _ M\n"
    # into grid style system, with x and y row and col indexes
    @grid = parts[0].split("\n").map(&:split).transpose
    @words = parts[1].split("\n").reject(&:empty?)
    # find used letters and remaining letters
    @letters_found = build_found_letters_with_pos(@grid)
    @letters_to_find = build_unfound_letter_with_remaining_pos(@letters_found)
    @adjacencies = build_adjacencies(@words)
  end

  # returns hash of letter and current co-ords
  def build_found_letters_with_pos(grid)
    letters = Hash.new { |h, k| h[k] = {} }
    @grid.each_with_index do |col, col_index|
      col.each_with_index do |letter, row_index|
        letters[letter] = [col_index, row_index] unless letter.eql?(BLANK_CHARACTER)
      end
    end
    letters
  end

  def build_unfound_letter_with_remaining_pos(letters_found)
    letters_to_find = ('A'..'Y').to_a - letters_found.keys
    all_positions = (0..GRID_SIZE-1).to_a.product((0..GRID_SIZE-1).to_a)
    positions_to_find = all_positions - letters_found.values
    letters_to_find.reduce({}) do |memo, letter|
      memo[letter] = positions_to_find
      memo
    end
  end

  def build_neighbourhood(pos)
    x, y = pos
    x_range = ([0, x-1].max..[GRID_SIZE-1, x+1].min).to_a
    y_range = ([0, y-1].max..[GRID_SIZE-1, y+1].min).to_a
    x_range.product(y_range)
  end

  def solve!
    log "Let's solve a Gogen Puzzle!"

    while unsolved?
      @letters_to_find.each_key do |letter|
        @adjacencies[letter].each do |adjacent_letter|
          # get current possible (or known single) position of letter
          positions_of_letter = @letters_to_find[adjacent_letter] || [@letters_found[adjacent_letter]]
          # build neighhbourhoods and union
          valid_positions = positions_of_letter.map do |pos|
            build_neighbourhood(pos)
          end.flatten(1).uniq
          # reject known fixed positions
          valid_positions = valid_positions - @letters_found.values
          # update possible positions with intersection
          @letters_to_find[letter] = @letters_to_find[letter] & valid_positions
          if @letters_to_find[letter].size == 1
            @letters_found[letter] = @letters_to_find[letter].first
            @letters_to_find.delete(letter)
            break # found it, next loop
          end
        end
      end
    end

    # lets reapply to the grid
    @letters_found.each do |letter, pos|
      @grid[pos[0]][pos[1]] = letter
    end
  end

  # build a list of what letters are next to each letter in the word
  def build_adjacencies(words)
    adjacencies = Hash.new { |h, k| h[k] = [] }
    words.each do |word|
      (word.size-1).times do |i|
        first = word[i]
        second = word[i+1]
        adjacencies[first].push(second)
        adjacencies[second].push(first)
      end
    end
    adjacencies
  end

  def print!
    PRINT_PADDING.times { puts "\n" }
    @grid.each do |row|
      puts ["\t" * PRINT_PADDING, row.join("  ")].flatten.join("")
      puts "\n"
    end
    PRINT_PADDING.times { puts "\n" }
  end

  def verify_solved!
    solved = @words.map do |word|
      found = 1
      (word.size - 1).times do |i|
        pos = @letters_found[word[i]]
        break if pos.nil?
        build_neighbourhood(pos).each do |neighbour_pos|
          if @grid[neighbour_pos[0]][neighbour_pos[1]] == word[i+1]
            found += 1
            break
          end
        end
      end
      found.eql?(word.size)
    end.all? { true }
    log "Actually Solved? #{solved}"
  end

  def unsolved?
    @letters_to_find.any?
  end

  def log(msg)
    puts "[GOGEN] #{msg}"
  end
end

PUZZLE = ENV['PUZZLE'] || 1
path = File.join(File.dirname(__FILE__), ["..", "examples", "#{PUZZLE}-unsolved.txt"])
puzzle = Gogen.new(File.read(path))

puzzle.solve!
puzzle.print!
puzzle.verify_solved!

# fix up ? use sets rather than arrays (if necesary in ruby)
# work out big O time - f(grid_size = G, neighhbourhood size = 8, # of unfound letters = L, alphabet = A)
# interestingly how it breaks if edge fixed are removed, but middle R can be removed
