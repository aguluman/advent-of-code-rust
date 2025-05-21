{ pkgs ? import <nixpkgs> { overlays = [ (import (fetchTarball "https://github.com/oxalica/rust-overlay/archive/master.tar.gz")) ]; } }:

let
  # Use a specific rust version
  rust-toolchain = pkgs.rust-bin.stable.latest.default.override {
    extensions = [ "rust-src" "rust-analyzer" "clippy" "rustfmt" ];
    targets = [ 
      "x86_64-pc-windows-msvc"   # For Windows with MSVC
      "x86_64-pc-windows-gnu"    # For Windows with GNU
      "x86_64-unknown-linux-gnu" # For Linux
    ];
  };
in
pkgs.mkShell {
  name = "advent-of-code-rust";
  
  buildInputs = with pkgs; [
    # Rust toolchain
    rust-toolchain
    
    # Development tools
    cargo-watch
    cargo-criterion  # For benchmarking
    cargo-nextest    # Better test runner
    cargo-audit      # Security audits
    
    # Additional dependencies
    gnumake          # For the Makefile
    direnv           # For .envrc support
  ];

  # Shell hook to setup environment
  shellHook = ''
    echo "🦀 Advent of Code 2024 - Rust Development Environment 🦀"
    echo "Run 'make help' to see available commands."
  '';
}
