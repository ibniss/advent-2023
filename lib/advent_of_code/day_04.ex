defmodule AdventOfCode.Day04 do
  @spec parse_line(String.t()) :: {[integer()], [integer()]}
  defp parse_line(line) do
    [_, card_data] = line |> String.split(":", trim: true)
    [winning_numbers, your_numbers] = card_data |> String.split("|", trim: true)

    winning_numbers =
      winning_numbers |> String.split(" ", trim: true) |> Enum.map(&String.to_integer/1)

    your_numbers = your_numbers |> String.split(" ", trim: true) |> Enum.map(&String.to_integer/1)

    {winning_numbers, your_numbers}
  end

  def part1(input) do
    input
    |> String.split("\n", trim: true)
    |> Stream.map(fn line ->
      {winning_numbers, your_numbers} = parse_line(line)

      your_numbers
      |> Enum.reduce(0, fn number, acc ->
        if Enum.member?(winning_numbers, number) do
          max(1, acc * 2)
        else
          acc
        end
      end)
    end)
    |> Enum.sum()
  end

  @spec update_count_map(map(), integer(), integer(), integer()) :: map()
  defp update_count_map(acc, _index, numbers_won, _multiplier) when numbers_won <= 0 do
    # No numbers won, no need to update the map
    acc
  end

  defp update_count_map(acc, index, numbers_won, multiplier) do
    # Update numbers_won scratchcards with multiplier
    0..(numbers_won - 1)
    |> Enum.reduce(acc, fn num_index, acc ->
      Map.update(acc, index + num_index + 1, multiplier + 1, &(&1 + multiplier))
    end)
  end

  def part2(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn {line, index}, acc ->
      # Adjust index to be 1-based so matches instruction
      index = index + 1

      {winning_numbers, your_numbers} = parse_line(line)

      # Original number of won scratchcards
      number_won = your_numbers |> Enum.filter(&Enum.member?(winning_numbers, &1)) |> Enum.count()

      multiplier = Map.get(acc, index, 1)

      acc
      |> update_count_map(index, number_won, multiplier)
      |> Map.update(index, 1, & &1)
    end)
    |> Map.values()
    |> Enum.sum()
  end
end
