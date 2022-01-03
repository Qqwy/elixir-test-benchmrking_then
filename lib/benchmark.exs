defmodule Benchmark do
  alias Implementation.{Manual, Then, ThenInlined}

  # We run the benchmark on all elements in a list
  # as we're simulating something which will often be run in a tight loop
  def run() do
    Benchee.run(
      %{
        "Manual" => fn list -> Enum.map(list, &Manual.example/1) end,
        "Then" => fn list -> Enum.map(list, &Then.example/1) end,
        "ThenInlined" => fn list -> Enum.map(list, &ThenInlined.example/1) end,

      },
      time: 10,
      memory_time: 2,
      inputs: %{
        "1000" => Enum.to_list(1..1000),
      }
    )
  end
end

Benchmark.run()
