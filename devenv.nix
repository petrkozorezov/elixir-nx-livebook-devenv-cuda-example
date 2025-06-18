{ config, lib, pkgs, ... }: let
  cudaPackages = pkgs.cudaPackages;
  cudaPath     = cudaPackages.cudatoolkit;
  nvidiaDriver = pkgs.linuxPackages.nvidia_x11;
in {
  packages = with pkgs; [
    gcc
    gnumake
    livebook
  ];

  languages.elixir.enable = true;

  env = {
    NIX_LD = "${pkgs.glibc}/lib/ld-linux-x86-64.so.2";

    XLA_TARGET = "cuda12";
    XLA_FLAGS  = "--xla_gpu_cuda_data_dir='${cudaPath}'";
    CUDA_PATH  = cudaPath;

    LIVEBOOK_HOME      = "${config.devenv.root}/notebooks";
    LIVEBOOK_DATA_PATH = "${config.devenv.root}/data/livebook";
  };

  processes.livebook.exec = "livebook start";
  process.managers.process-compose.tui.enable = false;

  enterShell = ''
    export LD_LIBRARY_PATH="/run/opengl-driver/lib:$LD_LIBRARY_PATH" # for NixOS
    export LD_LIBRARY_PATH="${cudaPath}/lib:$LD_LIBRARY_PATH"
    export LD_LIBRARY_PATH="${cudaPackages.cudatoolkit}/lib:$LD_LIBRARY_PATH"
    export LD_LIBRARY_PATH="${cudaPackages.cudnn.lib}/lib:$LD_LIBRARY_PATH"
    export LD_LIBRARY_PATH="${cudaPackages.nccl}/lib:$LD_LIBRARY_PATH"
    export LD_LIBRARY_PATH="${cudaPackages.libnvjitlink.lib}/lib:$LD_LIBRARY_PATH"
    # echo LD_LIBRARY_PATH=$LD_LIBRARY_PATH

    elixir ${./cuda-xla-test.exs} || exit 1
  '';
}
