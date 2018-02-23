defmodule Gogen do
  @text_input_split "#####"
  @grid_size 5
  @print_padding 2
  @blank_character "_"

  def run(text) do
    { grid, words, letters_found } = data_from_input(text)
    { letters_to_find, adjacencies } = { build_letters_to_find(letters_found), build_adjacencies(words) }
    print_grid(grid)
    solve(letters_to_find, letters_found, adjacencies)
    |> (&update_grid(grid, &1)).()
    |> print_grid
  end

  defp solve(letters_to_find, letters_found, adjacencies) when map_size(letters_to_find) > 0 do
    IO.inspect "Solving, letters_remaining: #{length(all_letters()) - map_size(letters_found)}"
    { new_letters_to_find, new_letters_found } =
      Enum.reduce(letters_to_find, {letters_to_find, letters_found}, fn({letter, _orig_pos_list}, { top_ltf, top_lf }) ->
        { new_top_ltf, new_top_lf, _ } =
          Enum.reduce(adjacencies[letter], {top_ltf, top_lf, :continue}, fn(adj_letter, {inner_ltf, inner_lf, action}) ->
            if action == :break do
              # we've found this letter, just return early to the outer loop by skipping the rest
              { inner_ltf, inner_lf, :break }
            else # still need to processing the next adjacent letter
              updated_inner_ltf_value =
                update_letter_pos_map_from_adjacencies(
                  Map.get(inner_ltf, letter),
                  List.wrap(letters_to_find[adj_letter] || letters_found[adj_letter]),
                   Map.values(inner_lf)
                )
              if length(updated_inner_ltf_value) == 1 do
                [pos | _] = updated_inner_ltf_value
                new_inner_ltf = Map.delete(inner_ltf, letter)
                new_inner_lf = Map.put(inner_lf, letter, pos)
                { new_inner_ltf, new_inner_lf, :break } # break out of inner callback
              else
                new_inner_ltf = Map.put(inner_ltf, letter, updated_inner_ltf_value)
                { new_inner_ltf, inner_lf, :continue }
              end
            end
          end)
        { new_top_ltf, new_top_lf }
      end)
    solve(new_letters_to_find, new_letters_found, adjacencies)
  end

  defp solve(letters_to_find, letters_found, _) when map_size(letters_to_find) == 0 do
    letters_found
  end

  defp update_letter_pos_map_from_adjacencies(current_letter_positions, adj_letters, known_letter_positions) do
    pos_list_from_adjacencies =
      Enum.map(adj_letters, &build_neighbourhood(&1))
      |> List.flatten
      |> Enum.uniq
    pos_list_without_found_letters = pos_list_from_adjacencies -- known_letter_positions # difference, remove ones we know about
    current_letter_positions -- (current_letter_positions -- pos_list_without_found_letters) # intersection va List --
  end

  def update_grid(grid, letter_pos_map) do
    Enum.reduce(letter_pos_map, grid, fn({letter, pos}, new_grid) ->
      Enum.at(new_grid, pos.x)
      |> List.replace_at(pos.y, letter)
      |> (&List.replace_at(new_grid, pos.x, &1)).()
    end)
  end

  defp build_letters_to_find(letters_found) do
    letters_to_find = all_letters() -- Map.keys(letters_found)
    positions_to_check = all_positions() -- Map.values(letters_found)
    letters_to_find
    |> Enum.map(fn a -> {a, positions_to_check} end)
    |> Map.new
  end

  defp build_adjacencies(words) do
    initial_letter_map =
      List.duplicate([], 25)
      |> (&List.zip([all_letters(), &1])).()
      |> Map.new
    letter_pairs = Enum.flat_map(words, fn(word) ->
      Enum.map((0..String.length(word) - 2), fn(index) ->
        { String.slice(word, index, 1), String.slice(word, index+1, 1) }
      end)
    end)
    Enum.reduce(letter_pairs, initial_letter_map, fn({ first, second }, acc) ->
      acc
      |> Map.update!(first, fn l -> Enum.uniq(l ++ [second]) end)
      |> Map.update!(second, fn l -> Enum.uniq(l ++ [first]) end)
    end)
  end

  defp build_neighbourhood(pos) do
    x_range = max(0, pos.x - 1)..min(@grid_size - 1, pos.x + 1)
    y_range = max(0, pos.y - 1)..min(@grid_size - 1, pos.y + 1)
    for x <- x_range, y <- y_range, do: %{x: x, y: y}
  end

  defp data_from_input(text) do
    [rawGrid, rawWords] = String.split(text, @text_input_split)
    words = String.trim(rawWords) |> String.split("\n")
    grid =
      String.trim(rawGrid)
      |> String.split("\n")
      |> Enum.map(fn x -> String.split(x, " ") end)
      |> transpose_array
    letters_found =
      grid
      |> List.flatten
      |> Enum.with_index
      |> Enum.reduce(%{}, fn({letter, index}, letter_map) ->
        if letter != @blank_character do
          Map.put(letter_map, letter, %{
            x: Integer.mod(index, @grid_size),
            y: Float.floor(index / @grid_size) |> Kernel.trunc
          })
        else
          letter_map
        end
      end)
    { grid, words, letters_found }
  end

  defp print_grid(grid) do
    IO.puts String.duplicate("\n", @print_padding)
    Enum.each(grid, fn row ->
      Enum.join(row, " ") |> IO.puts
    end)
    IO.puts String.duplicate("\n", @print_padding)
  end

  defp all_positions do
    range = 0..(@grid_size - 1)
    for x <- range, y <- range, do: %{x: x, y: y}
  end

  defp all_letters do
    for n <- ?A..?Y, do: << n :: utf8 >>
  end

  defp transpose_array(arr) do
    arr |> List.zip |> Enum.map(&Tuple.to_list/1)
  end
end

puzzle = System.get_env("PUZZLE") || "1"
IO.puts "Lets solve puzzle ##{puzzle}!"
Gogen.run(File.read!("../examples/#{puzzle}-unsolved.txt"))
