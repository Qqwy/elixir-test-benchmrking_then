# BenchmarkingThen

This repo contains snippets to benchmark the overhead of `Kernel.then/2` vs. manually doing the same and vs using `@compile :inline`.

Run `mix run lib/benchmark.exs` to run the benchmarks on your machine.

Look at the `main` branch for the OTP24 version and the `otp23` branch for the OTP23 version.
_(The only difference between the branches are the Elixir and Erlang versions in the `.tool-versions` file to be used with the [ASDF version manager](asdf-vm.com/))_

# Benchmark details

We compare three alternatives:

- `Manual` simulates a pipeline applied to an argument, which is then modified by putting it in a tuple and finally part of this tuple is returned.
- `Then` simulates how this would be streamlined by using `Kernel.then/2`
- `ThenInlined` has the same code as `Then` but its module also contains `@compile :inline`.

Note that we perform some work at the end of the pipeline to prevent the compiler from performing tail optimization, which would obfuscate the difference in performance and memory of these techniques.

Each benchmark run runs the given functions 1000 times over all elements in a list, to simulate a pipeline being run in a tight loop. This makes differences in performance more apparent.

# Benchmark outcomes

I ran the benchmark on OTP24 and on OTP23 (in both caes using Elixir 1.13.1) to compare the difference of the JIT.

Even better would be to compile Erlang 24 with both 'emu' and 'jit'-support and compare these; this is left as an exercise for the reader ;-).

## OTP 24

```
Operating System: Linux
CPU Information: Intel(R) Core(TM) i7-6700HQ CPU @ 2.60GHz
Number of Available Cores: 8
Available memory: 31.19 GB
Elixir 1.13.1
Erlang 24.1.2

Benchmark suite executing with the following configuration:
warmup: 2 s
time: 10 s
memory time: 2 s
parallel: 1
inputs: 1000
Estimated total run time: 42 s

Benchmarking Manual with input 1000...
Benchmarking Then with input 1000...
Benchmarking ThenInlined with input 1000...

##### With input 1000 #####
Name                  ips        average  deviation         median         99th %
ThenInlined       56.32 K       17.76 μs    ±68.00%       17.35 μs       23.81 μs
Manual            55.08 K       18.16 μs    ±69.69%       17.41 μs       32.24 μs
Then              42.86 K       23.33 μs    ±41.04%       22.57 μs       47.12 μs

Comparison: 
ThenInlined       56.32 K
Manual            55.08 K - 1.02x slower +0.40 μs
Then              42.86 K - 1.31x slower +5.57 μs

Memory usage statistics:

Name           Memory usage
ThenInlined        15.63 KB
Manual             15.63 KB - 1.00x memory usage +0 KB
Then               39.06 KB - 2.50x memory usage +23.44 KB

**All measurements for memory usage were the same**
```

## OTP 23

```
CPU Information: Intel(R) Core(TM) i7-6700HQ CPU @ 2.60GHz
Number of Available Cores: 8
Available memory: 31.19 GB
Elixir 1.13.1
Erlang 23.0

Benchmark suite executing with the following configuration:
warmup: 2 s
time: 10 s
memory time: 2 s
parallel: 1
inputs: 1000
Estimated total run time: 42 s

Benchmarking Manual with input 1000...
Benchmarking Then with input 1000...
Benchmarking ThenInlined with input 1000...

##### With input 1000 #####
Name                  ips        average  deviation         median         99th %
ThenInlined       29.78 K       33.59 μs    ±38.77%       32.77 μs       45.99 μs
Manual            29.26 K       34.17 μs    ±30.56%       32.76 μs       60.73 μs
Then              27.46 K       36.42 μs    ±32.40%       35.21 μs       57.80 μs

Comparison: 
ThenInlined       29.78 K
Manual            29.26 K - 1.02x slower +0.59 μs
Then              27.46 K - 1.08x slower +2.83 μs

Memory usage statistics:

Name           Memory usage
ThenInlined        39.06 KB
Manual             39.06 KB - 1.00x memory usage +0 KB
Then               39.06 KB - 1.00x memory usage +0 KB

**All measurements for memory usage were the same**

```

## Findings

It is very odd to see that on OTP 24, significantly more memory is used for `Then`.

And while performance of the tight loop has almost doubled, the relative difference in performance between `Manual`/`ThenInlined` and `Then` is 30%, which seems significant.

# Looking at the disassembled code

By calling `:erts_debug.df(ModuleName)` we can look at the disassembled code.
**Note that at least on my computer this does not work under OTP24 (it produces files with blank lines)***, so these results were obtained on the OTP23 branch:

- [Implementation.Manual](https://github.com/Qqwy/elixir-test-benchmrking_then/blob/otp23/Elixir.Implementation.Manual.dis)
- [Implementation.Then](https://github.com/Qqwy/elixir-test-benchmrking_then/blob/otp23/Elixir.Implementation.Then.dis)
- [Implementation.ThenInlined](https://github.com/Qqwy/elixir-test-benchmrking_then/blob/otp23/Elixir.Implementation.ThenInlined.dis)

From these we can see that the anonymous function introduced by `Kernel.then/2` is _not_ inlined except when `@compile :inlin` is set.


