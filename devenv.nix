{ config, lib, pkgs, ... }: let
  cudaPackages = pkgs.cudaPackages;
  cudaPath     = cudaPackages.cudatoolkit;
in {
  packages = with pkgs; [
    gcc
    gnumake
    livebook
  ];

  languages.elixir.enable = true;

  env = {
    XLA_TARGET = "cuda12";
    XLA_FLAGS  = "--xla_gpu_cuda_data_dir='${cudaPath}'";
    CUDA_PATH  = cudaPath;

    LIVEBOOK_HOME      = "${config.devenv.root}/notebooks";
    LIVEBOOK_DATA_PATH = "${config.devenv.root}/data/livebook";
  };

  enterShell = ''
    export LD_LIBRARY_PATH="/run/opengl-driver/lib:$LD_LIBRARY_PATH" # for NixOS
    export LD_LIBRARY_PATH="${cudaPath}/lib:$LD_LIBRARY_PATH"
    export LD_LIBRARY_PATH="${cudaPackages.cudnn.lib}/lib:$LD_LIBRARY_PATH"
    export LD_LIBRARY_PATH="${cudaPackages.nccl}/lib:$LD_LIBRARY_PATH"
    export LD_LIBRARY_PATH="${cudaPackages.libnvjitlink.lib}/lib:$LD_LIBRARY_PATH"

    elixir ${./cuda-xla-test.exs} || exit 1
  '';
}
