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
          case acc do
            0 -> 1
            _ -> acc * 2
          end
        else
          acc
        end
      end)
    end)
    |> Enum.sum()
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

      if number_won <= 0 do
        # Just update acc with current index
        acc |> Map.update(index, 1, & &1)
      else
        # Increment acc indexes by 'multiplier' for each won scratchcard
        Range.new(0, number_won - 1)
        |> Enum.with_index()
        |> Enum.reduce(acc, fn {_, num_index}, acc ->
          Map.update(acc, index + num_index + 1, multiplier + 1, &(&1 + multiplier))
        end)
        #  make sure current index is set, default it to 1
        |> Map.update(index, 1, & &1)
      end
    end)
    |> Map.values()
    |> Enum.sum()
  end
end
