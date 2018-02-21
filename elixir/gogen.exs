defmodule Gogen do
  @text_input_split "#####"
  @grid_size 5
  @print_padding 2
  @blank_character "_"

  def run(text) do
    { grid, words, letters_found } = data_from_input(text)
    letters_to_find = build_letters_to_find(letters_found)
    adjacencies =  build_adjacencies(words)
    print_grid(grid)
    IO.puts "Data ready, lets solve!"
    IO.inspect adjacencies
    IO.inspect build_neighbourhood(%{x: 2, y: 3})
    updated_grid = solve(letters_to_find, letters_found, adjacencies, grid)
    print_grid(updated_grid)
  end

  defp solve(_, _, _, grid) do
    grid
  end

  defp build_letters_to_find(letters_found) do
    letters_to_find = all_letters() -- Map.keys(letters_found)
    positions_to_check = all_positions() -- Map.values(letters_found)
    letters_to_find
    |> Enum.map(fn a -> {a, positions_to_check} end)
    |> Map.new
  end

  defp build_adjacencies(words) do
    Enum.reduce(words, %{}, fn(word, acc) ->
      for i <- 0..(String.length(word)-1), do: i
      acc
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
    range = 0..@grid_size
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

word = "asdf"
word
|> String.split("", trim: true)
|> Enum.with_index
