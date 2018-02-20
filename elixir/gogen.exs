defmodule Position do
  defstruct x: 0, y: 0
end

defmodule Gogen do
  @text_input_split "#####"
  # @grid_size 5
  # @print_padding 3
  @blank_character "_"

  def solve(text) do
    { grid, words, letters_found } = data_from_input(text)
    IO.puts grid
    IO.puts words
    IO.puts letters_found
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
      |> Enum.with_index
      |> Enum.reduce(%{}, fn({col, col_index}, letters) ->
        col
        |> Enum.with_index
        |> Enum.each(fn({letter, row_index}) ->
          unless letter == @blank_character do # cant use filter as we need to maintain grid position
            Map.put(letters, letter, %Position{x: col_index, y: row_index})
          end
        end)
        letters
      end)
    { grid, words, letters_found }
  end

  defp transpose_array(arr) do
    arr
    |> List.zip
    |> Enum.map(&Tuple.to_list/1)
  end
end

puzzle = System.get_env("PUZZLE") || "1"
IO.puts "Lets solve puzzle ##{puzzle}!"
Gogen.solve(File.read!("../examples/#{puzzle}-unsolved.txt"))
