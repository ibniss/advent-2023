defmodule AdventOfCode.Day08 do
  require Stream.Reducers

  def parse(input) do
    [directions | network] = input |> String.split("\n", trim: true)

    network_map =
      network
      |> Enum.map(fn line ->
        [source, targets] = String.split(line, "=", trim: true) |> Enum.map(&String.trim/1)

        [left, right] =
          targets
          |> String.split(",", trim: true)
          |> Enum.map(fn node ->
            # Remove parentheses and whitespace
            node
            |> String.replace("(", "")
            |> String.replace(")", "")
            |> String.trim()
          end)

        {source, {left, right}}
      end)
      |> Enum.into(%{})

    {directions, network_map}
  end

  @start_letter "AAA"
  @end_letter "ZZZ"

  # overcomplicated solution with stream transformations
  def part1(input) do
    {directions, network_map} = parse(input)
    IO.inspect(network_map)

    dir_stream = Stream.cycle(String.graphemes(directions))

    Stream.transform(dir_stream, {@start_letter, 1}, fn direction, {current_location, count} ->
      IO.inspect(%{direction: direction, current_location: current_location, count: count})

      new_location = network_map[current_location] |> elem(if direction == "R", do: 1, else: 0)

      IO.inspect(%{new_location: new_location})

      new_state = {new_location, count + 1}

      case new_location do
        # Stop stream if we've reached the end
        @end_letter ->
          {:halt, new_state}

        _ ->
          # Continue stream with new location and count
          {[new_state], new_state}
      end
    end)
    |> Enum.reduce(nil, fn {_, count}, _acc ->
      count
    end)
  end

  defp is_start?(position) do
    String.ends_with?(position, "A")
  end

  defp is_end?(position) do
    String.ends_with?(position, "Z")
  end

  @spec get_next_location(map(), String.t(), String.t()) :: String.t()
  defp get_next_location(network_map, location, "R"), do: elem(network_map[location], 1)
  defp get_next_location(network_map, location, "L"), do: elem(network_map[location], 0)

  @spec get_direction([String.grapheme()], integer()) :: String.t()
  defp get_direction(directions, count) do
    index = rem(count, Enum.count(directions))
    Enum.at(directions, index)
  end

  @spec do_navigate(map(), [String.grapheme()], String.t(), integer()) :: integer()
  defp do_navigate(network_map, directions, position, count) do
    # Navigate the position
    new_position = get_next_location(network_map, position, get_direction(directions, count))

    if is_end?(new_position) do
      count + 1
    else
      do_navigate(network_map, directions, new_position, count + 1)
    end
  end

  # handwritten lcm as per formula
  def lcm(a, b), do: div(a * b, Integer.gcd(a, b))

  # lcm of multiple numbers
  def lcm(numbers) do
    Enum.reduce(numbers, &lcm/2)
  end

  # Brute force would take forever, it turns out each starting position loops between the starting and ending position in a fixed time
  # So we can just find the number of steps required to reach the ending position from each starting position, and then find the LCM of those numbers
  def part2(input) do
    {directions, network_map} = parse(input)

    # Check steps required to reach a Z from each A
    directions_list = String.graphemes(directions)
    starting_positions = network_map |> Map.keys() |> Enum.filter(&is_start?/1)

    required_counts =
      Enum.map(starting_positions, fn starting_position ->
        do_navigate(network_map, directions_list, starting_position, 0)
      end)

    # required_counts = [18559, 21883, 16897, 16343, 11911, 20221]

    # Solution is LCM of all required counts
    lcm(required_counts)
  end
end
