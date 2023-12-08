defmodule AdventOfCode.Day06 do
  # x - time held
  # y - distance travelled
  # y = v * t
  # v = x  # velocity is equal to time held
  # y = x * (t - x)
  # checking that it checks out
  # optimize =>  y > n, x < t
  # assume n = 9, t = 7
  # y = x * (t - x)
  # y = x * (7 - x)
  #  - x^2 + 7x > 9
  # find solutions to above

  def part1(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      line
      |> String.split(":", trim: true)
      |> List.last()
      |> String.split(" ", trim: true)
      |> Enum.map(&String.to_integer/1)
    end)
    |> Enum.zip()
    |> Enum.map(fn {t, n} ->
      # For each time, t, from 1 to (t-1), calculate the distance travelled
      1..(t - 1)
      |> Enum.map(fn x ->
        x * (t - x)
      end)
      # Filter out distances that are too short
      |> Enum.filter(fn y -> y > n end)
      |> Enum.count()
    end)
    |> Enum.product()
  end

  def part2(input) do
    [time, distance] =
      input
      |> String.split("\n", trim: true)
      |> Enum.map(fn line ->
        line
        |> String.split(":", trim: true)
        |> List.last()
        |> String.split(" ", trim: true)
        # join the numbers
        |> Enum.join()
        |> String.to_integer()
      end)

    # For each time, t, from 1 to (t-1), calculate the distance travelled
    1..(time - 1)
    |> Enum.map(fn x ->
      x * (time - x)
    end)
    # Filter out distances that are too short
    |> Enum.filter(fn y -> y > distance end)
    |> Enum.count()
  end
end
