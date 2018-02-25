defmodule Gogen do
  @text_input_split "#####"
  @grid_size 5
  @print_padding 2
  @blank_character "_"

  def run(text) do
    { grid, words, letters_found } = data_from_input(text)
    { letters_pos_set, adjacencies } = { build_letters_pos_set(letters_found), build_adjacencies(words) }
    print_grid(grid)
    solve(letters_pos_set, adjacencies, remaining_letters_to_find(letters_pos_set))
    |> (&update_grid(grid, &1)).()
    |> print_grid
  end

  defp solve(letters_pos_set, adjacencies, letters_to_find) when letters_to_find > 0 do
    Enum.reduce(letters_pos_set, letters_pos_set, fn({letter, _orig_pos_list}, top_pos_set) ->
      Enum.reduce(adjacencies[letter], top_pos_set, fn(adj_letter, inner_pos_set) ->
        case length(inner_pos_set[letter]) do
          1 -> # we've found set one, letters make no changes for the rest of the loop.
            inner_pos_set
          _ ->
            updated_inner_pos_set_letter_value =
              update_letter_pos_set_value_from_adjacencies(
                Map.get(inner_pos_set, letter),
                Map.get(inner_pos_set, adj_letter),
                extract_known_letter_positions(inner_pos_set)
              )
            Map.put(inner_pos_set, letter, updated_inner_pos_set_letter_value)
        end
      end)
    end)
    |> (&solve(&1, adjacencies, remaining_letters_to_find(&1))).()
  end

  defp solve(letters_pos_set, _adjacencies, letters_to_find) when letters_to_find == 0 do
    letters_pos_set
  end

  defp update_letter_pos_set_value_from_adjacencies(current_letter_positions, adj_letter_positions, known_letter_positions) do
    pos_list_from_adjacencies =
      Enum.map(adj_letter_positions, &build_neighbourhood(&1))
      |> List.flatten
      |> Enum.uniq
    pos_list_without_found_letters = pos_list_from_adjacencies -- known_letter_positions # difference, remove ones we know about
    current_letter_positions -- (current_letter_positions -- pos_list_without_found_letters) # intersection va List --
  end

  def update_grid(grid, letters_pos_set) do
    Enum.reduce(letters_pos_set, grid, fn({letter, [pos | _]}, new_grid) ->
      Enum.at(new_grid, pos.x)
      |> List.replace_at(pos.y, letter)
      |> (&List.replace_at(new_grid, pos.x, &1)).()
    end)
  end

  defp build_letters_pos_set(letters_found) do
    remaining_positions = all_positions() -- Map.values(letters_found)
    Enum.reduce(all_letters(), %{}, fn(letter, acc) ->
      case Map.get(letters_found, letter) do
        nil -> Map.put(acc, letter, remaining_positions)
        pos -> Map.put(acc, letter, [pos])
      end
    end)
  end

  defp build_adjacencies(words) do
    letter_pairs = Enum.flat_map(words, &word_to_letter_pairs/1)
    Enum.reduce(letter_pairs, initial_letter_map(), fn({ first, second }, acc) ->
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

  defp word_to_letter_pairs(word) do
    Enum.map((0..String.length(word) - 2), fn(index) ->
      { String.slice(word, index, 1), String.slice(word, index+1, 1) }
    end)
  end

  defp initial_letter_map do
    List.duplicate([], length(all_letters()))
    |> (&List.zip([all_letters(), &1])).()
    |> Map.new
  end

  defp remaining_letters_to_find(letters_pos_set) do
    Enum.count(letters_pos_set, fn {_, v} -> length(v) > 1 end)
  end

  defp extract_known_letter_positions(letters_pos_set) do
    letters_pos_set
    |> Enum.flat_map(fn {_, v} -> if(length(v) == 1, do: [v], else: []) end)
    |> List.flatten
  end

  defp transpose_array(arr) do
    arr |> List.zip |> Enum.map(&Tuple.to_list/1)
  end
end

puzzle = System.get_env("PUZZLE") || "1"
IO.puts "Lets solve puzzle ##{puzzle}!"
Gogen.run(File.read!("../examples/#{puzzle}-unsolved.txt"))
