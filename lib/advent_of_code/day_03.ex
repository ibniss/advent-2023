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

  def part1(schematic) do
    schematic
    |> String.split("\n", trim: true)
    # Consider two rows at a time
    |> Enum.chunk_every(2, 1)
    # Keep track of previous line symbols
    |> Enum.reduce(%{prev_symbols: [], numbers: []}, fn lines, acc ->
      line1 = List.first(lines)
      line2 = List.last(lines, [])

      IO.inspect(line1, label: "Line 1")

      # Find number entries in line1
      number_entries =
        @number_regex
        |> Regex.scan(line1, return: :index)
        |> Enum.map(&List.first/1)
        |> Enum.map(fn {start_index, len} ->
          end_index = start_index + len - 1
          {{start_index, end_index}, String.slice(line1, start_index..end_index)}
        end)

      # Look for symbols in line1 and 2
      symbols_1 = get_symbols(line1)
      symbols_2 = get_symbols(line2)

      numbers_filtered =
        number_entries
        |> Enum.filter(fn {{start_index, end_index}, _} ->
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

          # # Log the conditions
          # IO.inspect({start_index, end_index}, label: "Number Entry")
          # IO.inspect(adj_above, label: "Adjacent Above")
          # IO.inspect(adj_line, label: "Adjacent Line")
          # IO.inspect(adj_below, label: "Adjacent Below")

          adj_above or adj_line or adj_below
        end)
        |> IO.inspect(label: "Number Entries Filtered")

      %{
        prev_symbols: symbols_1,
        numbers: acc[:numbers] ++ numbers_filtered
      }
    end)
    |> Map.get(:numbers)
    |> Enum.map(&elem(&1, 1))
    |> Enum.map(&String.to_integer/1)
    |> IO.inspect(label: "Numbers")
    |> Enum.sum()
  end

  def part2(_args) do
  end
end
