defmodule Benchmark do
  alias Implementation.{Manual, Then, ThenInlined}

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
