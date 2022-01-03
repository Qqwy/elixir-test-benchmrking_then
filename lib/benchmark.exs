defmodule Benchmark do
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
      {:ok, x}
    end
  end

  defmodule Then do
    def example(x) do
      x
      |> then(&External.increment/1)
      |> then(&{:ok, &1})
    end
  end

  defmodule ThenInlined do
    @compile :inline
    def example(x) do
      x
      |> then(&External.increment/1)
      |> then(&{:ok, &1})
    end
  end

  def run() do
    Benchee.run(
      %{
        "Manual" => fn list -> Enum.map(list, &Manual.example/1) end,
        "Then" => fn list -> Enum.map(list, &Then.example/1) end,
        "ThenInlined" => fn list -> Enum.map(list, &ThenInlined.example/1) end,

      },
      time: 2,
      memory_time: 2,
      inputs: %{
        "10" => Enum.to_list(1..10),
        "100" => Enum.to_list(1..100),
        "1000" => Enum.to_list(1..1000),
      }
    )
  end
end

Benchmark.run()
