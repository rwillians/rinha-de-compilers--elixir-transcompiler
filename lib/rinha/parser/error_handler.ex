defmodule Rinha.Parser.ErrorHandler do
  @moduledoc false

  @doc false
  @spec format(String.t(), String.t(), pos_integer) :: binary

  def format(msg, program, offset) do
    %{acc: lines} =
      program
      |> String.trim_trailing("\n")
      |> String.split("\n")
      |> Enum.reduce(
        %{acc: [], offset: 0},
        &%{
          &2
          | acc: &2.acc ++ [{&2.offset, &1, &2.offset + String.length(&1)}],
            offset: &2.offset + String.length(&1)
        }
      )

    count = length([offset, lines])
    line_index = Enum.find_index(lines, &(offset >= elem(&1, 0) and offset <= elem(&1, 2)))
    line_number = line_index + 1

    {_, text_line_before, _} =
      cond do
        line_index < 1 -> {0, nil, 0}
        true -> Enum.at(lines, line_index - 1)
      end

    {offset_line_start, text_line, _} = Enum.at(lines, line_index)

    {_, text_line_after, _} =
      cond do
        (line_index + 1) < count -> Enum.at(lines, line_index + 1)
        true -> {0, nil, 0}
      end

    line_offset = offset - offset_line_start - 1

    msg =
      IO.ANSI.format([
        "\n\n",
        IO.ANSI.reset(),
        IO.ANSI.faint(),
        """
            ╭─
            ┆
        """,
        if not is_nil(text_line_before) do
          """
              ┆ #{to_string(line_number - 1) |> String.pad_leading(3, " ")}:  #{text_line_before}
          """
        else
          ""
        end,
        IO.ANSI.reset(),
        "\n      ",
        "#{to_string(line_number) |> String.pad_leading(3, " ")}:  #{text_line}\n",
        IO.ANSI.reset(),
        IO.ANSI.red(),
        "      ",
        "#{String.duplicate(" ", line_offset + 3)}^ #{msg}\n",
        "\n",
        IO.ANSI.reset(),
        IO.ANSI.faint(),
        if not is_nil(text_line_after) do
          """
              ┆ #{to_string(line_number + 1) |> String.pad_leading(3, " ")}:  #{text_line_after}
          """
        else
          ""
        end,
        """
            ┆
            ╰─
        """,
        IO.ANSI.reset()
      ])
      |> to_string()

    {msg, line_number}
  end
end
