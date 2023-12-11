defmodule AdventOfCode.Day10 do
  @type position() :: {integer(), integer()}

  @north {-1, 0}
  @south {1, 0}
  @east {0, 1}
  @west {0, -1}

  @directions [@north, @south, @east, @west]

  @ground "."
  @start "S"

  @pipes %{
    "-" => [@east, @west],
    "|" => [@north, @south],
    "L" => [@north, @east],
    "J" => [@north, @west],
    "7" => [@south, @west],
    "F" => [@south, @east]
  }

  def parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&String.split(&1, "", trim: true))
  end

  def add_dir(pos, dir) do
    {row, col} = pos
    {row_delta, col_delta} = dir

    {row + row_delta, col + col_delta}
  end

  def negate_dir(dir) do
    {row, col} = dir
    {-row, -col}
  end

  @doc """
  Find all positions of a symbol in the grid
  """
  def find_symbol(grid, symbol) do
    grid
    |> Enum.with_index()
    |> Enum.map(fn {row, row_index} ->
      row
      |> Enum.with_index()
      |> Enum.map(fn {cell, col_index} ->
        if cell == symbol do
          {row_index, col_index}
        end
      end)
      |> Enum.filter(&(&1 != nil))
    end)
    |> List.flatten()
  end

  @doc """
  Replace positions in the grid with a symbol
  """
  def replace_position(grid, positions, symbol) do
    grid
    |> Enum.with_index()
    |> Enum.map(fn {row, row_index} ->
      row
      |> Enum.with_index()
      |> Enum.map(fn {cell, col_index} ->
        if Enum.member?(positions, {row_index, col_index}) do
          symbol
        else
          cell
        end
      end)
    end)
  end

  @doc """
  Follow a pipe in the grid from a given position in a given direction
  """
  def follow_pipe(grid, start_pos, direction) do
    new_pos = add_dir(start_pos, direction)
    do_follow_pipe(grid, new_pos, direction, [])
  end

  @spec do_follow_pipe([[integer()]], position(), {integer(), integer()}, [position()]) :: [
          position()
        ]
  def do_follow_pipe(grid, current_pos, direction, path) do
    {row, col} = current_pos

    # If we're out of bounds, return nil
    if row < 0 or row >= Enum.count(grid) or col < 0 or col >= Enum.count(Enum.at(grid, 0)) do
      nil
    else
      # Otherwise, check the cell we just moved into
      cell = Enum.at(Enum.at(grid, row), col)

      # If we hit a ground cell, return nil
      if cell == @ground do
        nil
      else
        # If we hit a pipe, recurse
        if Map.has_key?(@pipes, cell) do
          # To get new direction, get the vectors for the pipe and remove the one pointing at the direction we came from
          new_dir =
            @pipes[cell]
            |> Enum.filter(&(&1 != negate_dir(direction)))
            |> List.first()

          do_follow_pipe(grid, add_dir(current_pos, new_dir), new_dir, path ++ [{row, col}])
        else
          # Otherwise, we hit the S letter again - return the path to get to it
          path ++ [{row, col}]
        end
      end
    end
  end

  @doc """
  Find the loop in the grid starting from a given position
  """
  @spec find_loop([[integer()]], position()) :: [position()]
  def find_loop(grid, start_pos) do
    @directions
    |> Enum.map(fn dir ->
      follow_pipe(grid, start_pos, dir)
    end)
    |> Enum.filter(&(&1 != nil))
    # There is only one loop in the grid (assumption based on task) so just get first element
    |> List.first()
  end

  def part1(input) do
    grid = parse(input) |> IO.inspect(label: "Parsed Input")

    start_pos =
      grid
      |> find_symbol(@start)
      # only one start
      |> List.first()
      |> IO.inspect(label: "Start")

    # Find positions of the loop in the grid
    loop_positions = find_loop(grid, start_pos) |> IO.inspect(label: "Loop Positions")

    # Max distance from start is just half its length
    length(loop_positions) / 2
  end

  @doc """
  Convert a list of points to a list of sets of edges
  """
  def points_to_edges(grid, points) do
    # Points is a chain of points which can start NOT on a vertex
    # We need to get the first vertex index and reshuffle the list so that it starts with a vertex
    first_vertex_index =
      points
      |> Enum.with_index()
      |> Enum.find(fn {point, _} ->
        {row, col} = point
        cell = Enum.at(Enum.at(grid, row), col)

        not (cell == "-" or cell == "|")
      end)
      |> elem(1)

    # Reshuffle the list so that it starts with a vertex
    points = Enum.drop(points, first_vertex_index) ++ Enum.take(points, first_vertex_index)

    points
    # Chunk points while we go through - or |, since other symbols are turns - vertices
    |> Enum.chunk_while(
      [],
      fn point, acc ->
        {row, col} = point
        cell = Enum.at(Enum.at(grid, row), col)

        is_vertex = not (cell == "-" or cell == "|")

        cond do
          # Start of chunk, add point to acc
          acc == [] -> {:cont, [point]}
          # Hit a vertex, return finished chunk and start new one with current vertex
          is_vertex -> {:cont, acc ++ [point], [point]}
          # Otherwise, add point to acc
          true -> {:cont, acc ++ [point]}
        end
      end,
      fn acc ->
        # Emit the last chunk + first point to close the loop
        {:cont, acc ++ [List.first(points)], acc}
      end
    )
    |> Enum.map(&MapSet.new/1)
  end

  @doc """
  Count intersections - count one per edge since edges are | or - and ray is -
  """
  def count_intersections(intersections, loop_edges) do
    loop_edges
    |> Enum.filter(fn edge -> MapSet.intersection(edge, intersections) |> MapSet.size() > 0 end)
    |> Enum.count()
  end

  # Regex magic to count intersections, happens to work in the test data don't ask how
  @border_regex ~r/L-*7|F-*J|\|/

  def part2(input) do
    grid = parse(input) |> IO.inspect(label: "Parsed Input")

    start_pos =
      grid
      |> find_symbol(@start)
      # only one start
      |> List.first()

    # Find positions of the loop in the grid
    loop_positions = find_loop(grid, start_pos) |> IO.inspect(label: "Loop Positions")

    # Print loop as found in order
    loop_positions
    |> Enum.with_index()
    |> IO.inspect(label: "Loop Positions with Index")
    |> Enum.reduce(grid, fn {{row, col}, idx}, acc ->
      List.update_at(acc, row, fn row ->
        List.update_at(row, col, fn _ -> idx end)
      end)
    end)
    |> Enum.map(&Enum.join(&1, "\t"))
    |> Enum.join("\n")
    |> IO.puts()

    # based on the direction between first and last points in loop, determine symbol in S to replace with
    {last_row, last_col} = Enum.at(loop_positions, -2)
    {first_row, first_col} = Enum.at(loop_positions, -1)
    {second_row, second_col} = Enum.at(loop_positions, 0)

    vector_before =
      {last_row - first_row, last_col - first_col} |> IO.inspect(label: "Vector Before")

    vector_after =
      {second_row - first_row, second_col - first_col} |> IO.inspect(label: "Vector After")

    # fIND MATCHING SYMBOL
    symbol =
      @pipes
      |> Enum.filter(fn {_, vectors} ->
        Enum.member?(vectors, vector_before) and Enum.member?(vectors, vector_after)
      end)
      |> List.first()
      |> elem(0)
      |> IO.inspect(label: "Symbol")

    grid =
      List.update_at(grid, first_row, fn row ->
        List.update_at(row, first_col, fn _ -> symbol end)
      end)

    # get all ground points in grid
    ground_positions = grid |> find_symbol(@ground)

    # for each ground point, cast a ray in one direction (here we pick going right) and count how many times it hits the loop
    inner_points =
      ground_positions
      |> Enum.filter(fn {ground_row, ground_col} ->
        row = Enum.at(grid, ground_row)
        row = Enum.take(row, ground_col)
        row_string = Enum.join(row, "")

        # Count regex hits - properly we'd do a proper ray and handle edge cases but the regex happens to work
        Regex.scan(@border_regex, row_string)
        |> Enum.count()
        |> rem(2) == 1
      end)
      |> IO.inspect(label: "Ground Points with odd number of intersections")

    # Print the grid with the inner points marked as I for debugging
    replace_position(grid, inner_points, "I")
    |> Enum.map(&Enum.join(&1, ""))
    |> Enum.join("\n")
    |> IO.puts()

    Enum.count(inner_points)
  end
end
