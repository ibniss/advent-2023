defmodule AdventOfCode.Day03 do
  @type position :: {integer, integer}
  @type number_entry :: {String.t(), position}

  # Capture  numbers
  @number_regex ~r/(\d+)/
  # Capture non-letters, non-number, non-dot symbols
  @symbol_regex ~r/([^a-zA-Z\d\.]+)/

  defp get_symbols(line) do
    @symbol_regex
    |> Regex.scan(line, return: :index)
    |> Enum.map(&List.first/1)
    |> Enum.map(&elem(&1, 0))
  end

  @spec get_numbers(String.t()) :: [number_entry]
  defp get_numbers(line) do
    @number_regex
    |> Regex.scan(line, return: :index)
    |> Enum.map(&List.first/1)
    |> Enum.map(fn {start_index, len} ->
      end_index = start_index + len - 1
      {String.slice(line, start_index..end_index), {start_index, end_index}}
    end)
  end

  def part1(schematic) do
    schematic
    |> String.split("\n", trim: true)
    # Consider two rows at a time
    |> Enum.chunk_every(2, 1)
    # Keep track of previous line symbols
    |> Enum.reduce(%{prev_symbols: [], numbers: []}, fn lines, acc ->
      line1 = List.first(lines)
      line2 = List.last(lines, [])

      # Find number entries in line1
      number_entries = get_numbers(line1)

      # Look for symbols in line1 and 2
      symbols_1 = get_symbols(line1)
      symbols_2 = get_symbols(line2)

      numbers_filtered =
        number_entries
        |> Enum.filter(fn {_, {start_index, end_index}} ->
          # Condition 1 - adjacent above
          adj_above =
            acc[:prev_symbols]
            |> Enum.any?(fn symbol_idx ->
              symbol_idx >= start_index - 1 and symbol_idx <= end_index + 1
            end)

          # Condition 2 - symbol directly to the left or right of the number
          adj_line =
            symbols_1
            |> Enum.any?(fn symbol_idx ->
              symbol_idx == start_index - 1 or symbol_idx == end_index + 1
            end)

          # Condition 3 - adjacent below
          adj_below =
            symbols_2
            |> Enum.any?(fn symbol_idx ->
              symbol_idx >= start_index - 1 and symbol_idx <= end_index + 1
            end)

          adj_above or adj_line or adj_below
        end)

      %{
        prev_symbols: symbols_1,
        numbers: acc[:numbers] ++ numbers_filtered
      }
    end)
    |> Map.get(:numbers)
    |> Enum.map(&elem(&1, 0))
    |> Enum.map(&String.to_integer/1)
    |> Enum.sum()
  end

  def part2(schematic) do
    schematic
    |> String.split("\n", trim: true)
    # Consider two rows at a time
    |> Enum.chunk_every(2, 1)
    # Keep track of previous line numbers
    |> Enum.reduce(%{prev_numbers: [], sum: 0}, fn lines, acc ->
      line1 = List.first(lines)
      line2 = List.last(lines, [])

      symbols = get_symbols(line1)

      numbers_1 = get_numbers(line1)
      numbers_2 = get_numbers(line2)

      # compute map of symbol => adjacent numbers
      symbol_sum =
        symbols
        |> Enum.map(fn symbol_idx ->
          adjacent_above =
            acc[:prev_numbers]
            |> Enum.filter(fn {_, {start_index, end_index}} ->
              symbol_idx >= start_index - 1 and symbol_idx <= end_index + 1
            end)
            |> Enum.map(&elem(&1, 0))

          adjacent_next =
            numbers_1
            |> Enum.filter(fn {_, {start_index, end_index}} ->
              symbol_idx == start_index - 1 or symbol_idx == end_index + 1
            end)
            |> Enum.map(&elem(&1, 0))

          adjacent_below =
            numbers_2
            |> Enum.filter(fn {_, {start_index, end_index}} ->
              symbol_idx >= start_index - 1 and symbol_idx <= end_index + 1
            end)
            |> Enum.map(&elem(&1, 0))

          numbers_found = adjacent_above ++ adjacent_next ++ adjacent_below

          # If at least two numbers found
          if length(numbers_found) >= 2 do
            numbers_found
            |> Enum.map(&String.to_integer/1)
            |> Enum.product()
          else
            0
          end
        end)
        |> Enum.sum()

      %{
        prev_numbers: numbers_1,
        sum: acc[:sum] + symbol_sum
      }
    end)
    |> Map.get(:sum)
  end
end
