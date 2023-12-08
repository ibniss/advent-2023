defmodule AdventOfCode.Day05 do
  @type range_map :: %{Range.t() => Range.t()}

  @spec create_range_map(String.t()) :: range_map
  def create_range_map(range_map_list) do
    range_map_list
    |> String.split("\n", trim: true)
    |> Enum.map(fn range_map_string ->
      [dest_start, source_start, range_len] =
        range_map_string
        |> String.split(" ", trim: true)
        |> Enum.map(&String.to_integer/1)

      {Range.new(source_start, source_start + range_len - 1),
       Range.new(dest_start, dest_start + range_len - 1)}
    end)
    |> Enum.into(%{})
  end

  @spec map_value(range_map, integer()) :: integer()
  def map_value(range_map, value) do
    # If no matching range found, return value
    looked_up =
      range_map
      |> Enum.find_value(fn {source_range, dest_range} ->
        # Look for first matching range
        if value in source_range do
          # Calculate offset from source range
          value_offset = value - source_range.first()
          dest_range.first() + value_offset
        end
      end)

    cond do
      # If no matching range found, return value
      is_nil(looked_up) -> value
      # Otherwise return looked up value
      true -> looked_up
    end
  end

  @spec maps_lookup([range_map], integer()) :: integer()
  def maps_lookup(range_maps, value) do
    range_maps
    |> Enum.reduce(value, fn range_map, acc ->
      map_value(range_map, acc)
    end)
  end

  def part1(input) do
    [seeds | maps] =
      input
      |> String.split("\n\n", trim: true)

    seed_numbers =
      seeds
      |> String.split(":", trim: true)
      |> List.last()
      |> String.split(" ", trim: true)
      |> Enum.map(&String.to_integer/1)

    range_maps =
      maps
      |> Enum.map(fn map_string ->
        map_string
        |> String.split(":", trim: true)
        |> List.last()
        |> String.split("\n", trim: true)
        |> Enum.map(&create_range_map/1)
        |> Enum.reduce(%{}, &Map.merge/2)
      end)

    seed_to_location_map =
      seed_numbers
      |> Enum.map(fn seed_number ->
        mapped = maps_lookup(range_maps, seed_number)

        {seed_number, mapped}
      end)
      |> Enum.into(%{})

    seed_to_location_map
    |> Enum.min_by(fn {_, location} -> location end)
    |> elem(1)
  end

  def part2(input) do
    [seeds | maps] =
      input
      |> String.split("\n\n", trim: true)

    seed_ranges =
      seeds
      |> String.split(":", trim: true)
      |> List.last()
      |> String.split(" ", trim: true)
      |> Enum.map(&String.to_integer/1)
      |> Enum.chunk_every(2, 2)
      |> Enum.map(fn [start, length] -> Range.new(start, start + length - 1) end)
      |> IO.inspect(label: "seed_ranges")

    reverse_range_maps =
      maps
      |> Enum.map(fn map_string ->
        map_string
        |> String.split(":", trim: true)
        |> List.last()
        |> String.split("\n", trim: true)
        |> Enum.map(&create_range_map/1)
        |> Enum.reduce(%{}, &Map.merge/2)
        # Reverse the map
        |> Enum.map(fn {source_range, dest_range} ->
          {dest_range, source_range}
        end)
      end)
      |> Enum.reverse()

    # Based on the first map, find min and max values to use as bounds
    first_map = Enum.at(reverse_range_maps, 0)

    max_loc =
      first_map
      |> Enum.map(fn {dest_range, _} -> dest_range.last() end)
      |> Enum.max()

    # chunk to process in 12 parallel tasks
    num_proc = 24
    chunk_size = div(max_loc, num_proc)

    chunk_starts =
      0..num_proc
      |> Enum.map(fn idx -> idx * chunk_size end)

    # Find first location that exists in any seed range
    chunk_starts
    |> Task.async_stream(
      fn chunk_start ->
        chunk_end = chunk_start + chunk_size

        chunk_start..chunk_end
        |> Stream.map(fn loc ->
          mapped = maps_lookup(reverse_range_maps, loc)
          {loc, mapped}
        end)
        |> Stream.filter(fn {loc, mapped} ->
          Enum.any?(seed_ranges, fn seed_range -> mapped in seed_range end)
        end)
        |> Stream.take(1)
        |> Enum.to_list()
        |> List.first()
      end,
      max_concurrency: num_proc,
      timeout: :infinity
    )
    |> Enum.map(&elem(&1, 1))
    |> Enum.filter(&(&1 != nil))
    |> List.first()
    |> elem(0)
  end
end
