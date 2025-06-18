Mix.install(
  [
    {:nx, "~> 0.10"},
    {:exla, "~> 0.10"},
  ],
  config: [
    nx: [
      default_backend: EXLA.Backend,
      default_defn_options: [compiler: EXLA]
    ],
    exla: [clients: [cuda: [platform: :cuda, preallocate: false]]],
  ]
)

case EXLA.Client.get_supported_platforms() do
  %{cuda: cuda} when cuda > 0 -> :ok
end

:cuda = EXLA.Client.default_name()

Nx.Testing.assert_equal (Nx.iota({2, 2}) |> Nx.add(2)), Nx.tensor([[2, 3], [4, 5]])

IO.puts("== CUDA works ==")
