defmodule AdventOfCode.Day09 do
  def parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      line |> String.split(" ", trim: true) |> Enum.map(&String.to_integer/1)
    end)
  end

  @typedoc """
  Compute a list of differences between each pair of numbers in the list
  """
  @spec compute_differences([number()]) :: [number()]
  def compute_differences(numbers) do
    numbers
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.map(fn [a, b] -> b - a end)
  end

  def extrapolate(lists) do
    Enum.reduce(lists, 0, fn l, acc -> acc + List.last(l) end)
  end

  def extrapolate_backwards(lists) do
    do_extrapolate_backwards(Enum.reverse(lists), [])
  end

  # one element left, return first element of first list
  defp do_extrapolate_backwards([last], _), do: List.first(last)

  defp do_extrapolate_backwards([first, second | rest], acc) do
    # Modify second list by prepending the result of substracting first element of first list from first element of second list
    modified_second = [List.first(second) - List.first(first)] ++ second

    # Call again with the modified second list and adding first to acc
    do_extrapolate_backwards([modified_second | rest], [first | acc])
  end

  def make_sequences(numbers) do
    make_sequences(numbers, [numbers])
  end

  def make_sequences(numbers, lists) do
    last_list = List.last(lists)

    # If we reached a point where the last list is all 0s, we're done making sequences - proceed to extrapolate
    if Enum.all?(last_list, &(&1 == 0)) do
      lists
    else
      # Otherwise, make a new list of differences of last list and recurse
      make_sequences(numbers, lists ++ [compute_differences(last_list)])
    end
  end

  def part1(input) do
    data = parse(input)

    data |> Enum.map(&make_sequences/1) |> Enum.map(&extrapolate/1) |> Enum.sum()
  end

  def part2(input) do
    data = parse(input)

    data
    |> Enum.map(&make_sequences/1)
    |> Enum.map(&extrapolate_backwards/1)
    |> Enum.sum()
  end
end
