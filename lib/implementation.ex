defmodule Implementation do
  defmodule External do
    def increment(val) do
      val + 1
    end
  end

  defmodule Manual do
    def example(x) do
      x =
        x
        |> External.increment()
      res = {:ok, x}
      elem(res, 1)
    end
  end

  defmodule Then do
    def example(x) do
      res =
        x
        |> then(&External.increment/1)
        |> then(&{:ok, &1})

      elem(res, 1)
    end
  end

  defmodule ThenInlined do
    @compile :inline
    def example(x) do
      res =
        x
        |> then(&External.increment/1)
        |> then(&{:ok, &1})

      elem(res, 1)
    end
  end
end
