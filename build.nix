{ pkgs ? import <nixpkgs> { } }:

let
  # Import the default.nix to reuse the build configuration
  aoc-package = import ./default.nix { inherit pkgs; };
  
  # Define the days to build
  days = [
    "day01"
    "day02"
    "day03"
    # Add new days as they are created
  ];
  
  # Function to build a single day
  buildDay = day: pkgs.rustPlatform.buildRustPackage {
    pname = day;
    version = "0.1.0";
    src = ./${day};
    
    cargoLock = {
      lockFile = ./${day}/Cargo.lock;
    };
    
    meta = with pkgs.lib; {
      description = "Advent of Code 2024 - ${day}";
    };
  };
  
  # Map the buildDay function over all days
  dayPackages = builtins.listToAttrs (
    builtins.map (day: { name = day; value = buildDay day; }) days
  );
in
{
  # Export the entire package
  inherit aoc-package;
  
  # Export each day individually
  days = dayPackages;
  
  # Create a combined package with all binaries
  all = pkgs.symlinkJoin {
    name = "advent-of-code-2024-rust-all";
    paths = builtins.attrValues dayPackages;
  };
}
