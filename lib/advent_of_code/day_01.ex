defmodule AdventOfCode.Day01 do
  @doc """
  Whether a given character is a digit
  """
  def is_char_digit(char) do
    case Integer.parse(char) do
      {_, ""} -> true
      _ -> false
    end
  end

  @doc """
  Find first and last number in a given string which contains numbers and letters
  """
  @spec first_and_last_number(String.t()) :: integer()
  def first_and_last_number(string) do
    digits =
      string
      |> String.graphemes()
      |> Enum.filter(&is_char_digit/1)

    case digits do
      [] ->
        0

      [first_digit] ->
        String.to_integer(first_digit <> first_digit)

      _ ->
        first_digit = Enum.at(digits, 0)
        last_digit = Enum.at(digits, -1)

        String.to_integer(first_digit <> last_digit)
    end
  end

  def part1(inp) do
    inp
    |> String.split("\n")
    |> Enum.map(&first_and_last_number/1)
    |> Enum.sum()
  end

  def part2(_args) do
  end
end
