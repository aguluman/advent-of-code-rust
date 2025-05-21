{ pkgs ? import <nixpkgs> { } }:

let
  rust-toolchain = pkgs.rust-bin.stable.latest.default.override {
    extensions = [ "rust-src" "rust-analyzer" "clippy" "rustfmt" ];
    targets = [ 
      "x86_64-pc-windows-msvc"   # For Windows with MSVC
      "x86_64-pc-windows-gnu"    # For Windows with GNU
      "x86_64-unknown-linux-gnu" # For Linux
    ];
  };
in
pkgs.rustPlatform.buildRustPackage {
  pname = "advent-of-code-rust";
  version = "0.1.0";
  
  src = ./.;
  
  cargoLock = {
    lockFile = ./Cargo.lock;
    outputHashes = {
      # Add lockfile hashes if needed
    };
  };
  
  nativeBuildInputs = [ rust-toolchain ];
  
  meta = with pkgs.lib; {
    description = "Solutions for Advent of Code 2024 in Rust";
    homepage = "https://github.com/aguluman/advent-of-code-rust";
    license = licenses.mit;  # Adjust as needed
    maintainers = [ ];
  };
}
