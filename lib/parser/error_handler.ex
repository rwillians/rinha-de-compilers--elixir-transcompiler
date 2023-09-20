defmodule Parser.ErrorHandler do
  @moduledoc false

  @doc false
  @spec format(
          {program :: binary, offset :: pos_integer},
          String.t()
        ) :: binary

  def format({program, err_offset}, msg) do
    %{data: lines_data} =
      program
      |> String.split("\n")
      |> Enum.reduce(
        %{data: [], prev: %{number: 0, end: 0}},
        fn text, acc ->
          prev_end = acc.prev.end
          end_line_offset = prev_end + String.length(text)

          new_line =
            %{
              start: prev_end,
              number: acc.prev.number + 1,
              text: text,
              end: end_line_offset
            }

          %{data: acc.data ++ [new_line], prev: new_line}
        end
      )

    count = length(lines_data)

    %{text: text_err_line} =
      err_line =
      Enum.find(lines_data, &(err_offset >= &1.start and err_offset <= &1.end))

    err_line_number = err_line.number
    err_line_offset = err_offset - err_line.start - 1

    %{text: text_line_before} =
      cond do
        err_line_number < 2 -> %{text: nil}
        true -> Enum.at(lines_data, err_line_number - 2)
      end

    %{text: text_line_after} =
      cond do
        err_line_number <= count -> Enum.at(lines_data, err_line_number)
        true -> %{text: nil}
      end

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
            ┆ #{to_string(err_line_number - 1) |> String.pad_leading(3, " ")}:  #{text_line_before}
        """
      else
        ""
      end,
      IO.ANSI.reset(),
      "\n",
      "      #{to_string(err_line_number) |> String.pad_leading(3, " ")}:  #{text_err_line}",
      "\n",
      IO.ANSI.reset(),
      IO.ANSI.red(),
      "      #{String.duplicate(" ", err_line_offset + 6)}^ #{msg}\n",
      "\n",
      IO.ANSI.reset(),
      IO.ANSI.faint(),
      if not is_nil(text_line_after) do
        """
            ┆ #{to_string(err_line_number + 1) |> String.pad_leading(3, " ")}:  #{text_line_after}
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
  end
end
