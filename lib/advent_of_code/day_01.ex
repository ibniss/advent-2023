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
  Find a spelled out digit in a given string
  """
  @spec find_spelled_out(String.t()) :: [String.t()]
  def find_spelled_out(string) do
    digit_strings = ~w(one two three four five six seven eight nine)
    regex = Regex.compile!(Enum.join(digit_strings, "|"))

    Regex.scan(regex, string)
    |> Enum.map(&List.first/1)
  end

  def spelled_out_digit_to_number(digit) do
    case digit do
      "one" -> "1"
      "two" -> "2"
      "three" -> "3"
      "four" -> "4"
      "five" -> "5"
      "six" -> "6"
      "seven" -> "7"
      "eight" -> "8"
      "nine" -> "9"
    end
  end

  @doc """
  Find first and last digit in a given string which contains digits and letters.
  Returns the concatenation of the first and last digit.
  """
  @spec first_and_last_digit(String.t()) :: integer()
  def first_and_last_digit(string) do
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

  def first_and_last_digits_wide(string) do
    digits =
      string
      |> String.graphemes()
      # Reduce over the string, keeping track of the digits and the characters met so far
      |> Enum.reduce({[], ""}, fn char, {digs, chars} ->
        # If we encountered a numeric digit, add it to the list of digits
        if is_char_digit(char) do
          {digs ++ [char], ""}
        else
          new_chars = chars <> char

          case find_spelled_out(new_chars) do
            # If we have a spelled out digit, add it to the list of digits
            [found] ->
              {digs ++ [spelled_out_digit_to_number(found)], char}

            [] ->
              {digs, new_chars}
          end
        end
      end)
      |> elem(0)

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
    |> Enum.map(&first_and_last_digit/1)
    |> Enum.sum()
  end

  def part2(inp) do
    inp
    |> String.split("\n")
    |> Enum.map(&first_and_last_digits_wide/1)
    |> Enum.sum()
  end
end
