defmodule AdventOfCode.Day02 do
  @max_red 12
  @max_green 13
  @max_blue 14

  @colors [:red, :green, :blue]

  @type color :: :red | :green | :blue

  @type pull_data :: %{
          optional(color) => integer()
        }

  @doc """
  Parse a game data item, e.g. "3 blue, 2 red" into a map
  """
  @spec parse_game_data_item(String.t()) :: pull_data
  def parse_game_data_item(game_data_item) do
    game_data_item
    |> String.split(",")
    |> Enum.map(&String.trim/1)
    |> Enum.map(fn str ->
      [count, color] = String.split(str, " ")
      {String.to_atom(color), String.to_integer(count)}
    end)
    |> Enum.into(%{})
  end

  @doc """
  Parse a line of data, e.g. "Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green"
  into a tuple of game id and a list of game data items
  """
  @spec parse_line_data(String.t()) :: {integer(), [pull_data]}
  def parse_line_data(line) do
    [game_id_string, game_data_string] =
      line
      |> String.split(":", parts: 2)

    game_id =
      game_id_string
      |> String.replace("Game", "")
      |> String.trim()
      |> String.to_integer()

    game_data_list =
      game_data_string
      |> String.split(";", trim: true)
      |> Enum.map(&parse_game_data_item/1)

    {game_id, game_data_list}
  end

  @doc """
  Calculate the max of each color in a list of pull data
  """
  @spec get_max_colors([pull_data]) :: %{color => integer()}
  def get_max_colors(pull_list) do
    pull_list
    |> Enum.reduce(%{}, fn pull_data, acc ->
      @colors
      |> Enum.map(fn color ->
        {color, max(Map.get(acc, color, 0), Map.get(pull_data, color, 0))}
      end)
      |> Enum.into(%{})
    end)
  end

  def part1(input) do
    input
    |> String.split("\n", trim: true)
    |> Stream.map(&parse_line_data/1)
    |> Stream.filter(fn {_, pull_list} ->
      # Get max of each color
      max_colors = get_max_colors(pull_list)

      max_colors[:red] <= @max_red and max_colors[:green] <= @max_green and
        max_colors[:blue] <= @max_blue
    end)
    |> Stream.map(&elem(&1, 0))
    |> Enum.sum()
  end

  def part2(input) do
    input
    |> String.split("\n", trim: true)
    |> Stream.map(&parse_line_data/1)
    |> Stream.map(fn {_, pull_list} ->
      # Get max of each color
      max_colors = get_max_colors(pull_list)

      # Multiply the max of each color together to get the power of the set
      max_colors
      |> Map.values()
      |> Enum.reduce(fn x, acc -> x * acc end)
    end)
    |> Enum.sum()
  end
end
