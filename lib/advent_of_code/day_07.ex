defmodule AdventOfCode.Day07 do
  @type hand_data :: %{
          hand: [integer()],
          original_hand: String.t(),
          bid: integer(),
          # lower better
          strength: integer()
        }

  def hand_to_numbers(hand) do
    hand
    |> String.split("", trim: true)
    |> Enum.map(fn card ->
      case card do
        "A" -> 14
        "K" -> 13
        "Q" -> 12
        "J" -> 11
        "T" -> 10
        _ -> String.to_integer(card)
      end
    end)
  end

  def hand_to_numbers_joker(hand) do
    hand
    |> String.split("", trim: true)
    |> Enum.map(fn card ->
      case card do
        "A" -> 14
        "K" -> 13
        "Q" -> 12
        # joker is weak individually
        "J" -> 1
        "T" -> 10
        _ -> String.to_integer(card)
      end
    end)
  end

  def compute_hand_strength(hand) do
    case Enum.sort(hand, :desc) do
      # 5 same hards
      [a, a, a, a, a] -> 1
      # 4 same cards
      [a, a, a, a, _] -> 2
      [_, a, a, a, a] -> 2
      # full house
      [a, a, a, b, b] -> 3
      [a, a, b, b, b] -> 3
      # 3 of a kind
      [a, a, a, _, _] -> 4
      [_, a, a, a, _] -> 4
      [_, _, a, a, a] -> 4
      # 2 pairs
      [a, a, b, b, _] -> 5
      [a, a, _, b, b] -> 5
      [_, a, a, b, b] -> 5
      # 1 pair
      [a, a, _, _, _] -> 6
      [_, a, a, _, _] -> 6
      [_, _, a, a, _] -> 6
      [_, _, _, a, a] -> 6
      # High card
      [_, _, _, _, _] -> 7
    end
  end

  def splice(list, index, value) do
    Enum.take(list, max(index, 0)) ++ [value] ++ Enum.drop(list, index + 1)
  end

  # Helper function to replace a card at a specific index
  defp replace_card(hand, index, replacement) do
    hand
    |> Enum.with_index()
    |> Enum.map(fn {card, idx} -> if idx == index, do: replacement, else: card end)
  end

  # Helper function to recursively generate all possible hands by replacing jokers
  defp generate_possible_hands(_, [], acc, _), do: acc

  defp generate_possible_hands(hand, [joker_index | rest], acc, replacement_range) do
    new_hands =
      replacement_range
      |> Enum.flat_map(fn replacement ->
        acc
        |> Enum.map(fn current_hand -> replace_card(current_hand, joker_index, replacement) end)
      end)

    generate_possible_hands(hand, rest, new_hands, replacement_range)
  end

  def compute_hand_strength_joker(hand) do
    # Find the indices of all jokers in the hand
    joker_indices =
      hand
      |> Enum.with_index()
      |> Enum.filter(fn {card, _} -> card == 1 end)
      |> Enum.map(fn {_, index} -> index end)

    # Generate all possible hands by replacing jokers
    possible_hands = generate_possible_hands(hand, joker_indices, [hand], 2..14)

    # Compute the strength of each possible hand
    possible_hands
    |> Enum.map(&compute_hand_strength/1)
    |> Enum.min()
  end

  def part1(input) do
    num_hands =
      input
      |> String.split("\n", trim: true)
      |> Enum.count()

    input
    |> String.split("\n", trim: true)
    |> Enum.map(&String.split(&1, " ", trim: true))
    |> IO.inspect(label: "hands")
    |> Enum.map(fn [hand, bid] ->
      hand_as_num = hand_to_numbers(hand)

      %{
        hand: hand_as_num,
        original_hand: hand,
        bid: String.to_integer(bid),
        strength: compute_hand_strength(hand_as_num)
      }
    end)
    |> IO.inspect(label: "hand strengths")
    |> Enum.sort(fn hand1, hand2 ->
      if hand1.strength == hand2.strength do
        # compare cards one by one until one is greater
        different_nums =
          Enum.zip(hand1.hand, hand2.hand)
          # Find first different card
          |> Enum.find(fn {card1, card2} ->
            card1 != card2
          end)
          |> IO.inspect(label: "different_nums")

        # Higher card wins
        elem(different_nums, 0) > elem(different_nums, 1)
      else
        hand1.strength < hand2.strength
      end
    end)
    |> IO.inspect(label: "sorted hand strengths")
    # multiply each bid by max..1 depending on position
    |> Enum.with_index()
    |> Enum.map(fn {hand, index} ->
      hand.bid * (num_hands - index)
    end)
    |> Enum.sum()
  end

  def part2(input) do
    num_hands =
      input
      |> String.split("\n", trim: true)
      |> Enum.count()

    input
    |> String.split("\n", trim: true)
    |> Enum.map(&String.split(&1, " ", trim: true))
    |> Enum.map(fn [hand, bid] ->
      hand_as_num = hand_to_numbers_joker(hand)

      %{
        hand: hand_as_num,
        original_hand: hand,
        bid: String.to_integer(bid),
        strength: compute_hand_strength_joker(hand_as_num)
      }
    end)
    |> Enum.sort(fn hand1, hand2 ->
      if hand1.strength == hand2.strength do
        # compare cards one by one until one is greater
        different_nums =
          Enum.zip(hand1.hand, hand2.hand)
          # Find first different card
          |> Enum.find(fn {card1, card2} ->
            card1 != card2
          end)

        # Higher card wins
        elem(different_nums, 0) > elem(different_nums, 1)
      else
        hand1.strength < hand2.strength
      end
    end)
    # multiply each bid by max..1 depending on position
    |> Enum.with_index()
    |> Enum.map(fn {hand, index} ->
      hand.bid * (num_hands - index)
    end)
    |> Enum.sum()
  end
end
