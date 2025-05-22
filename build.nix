{ pkgs ? import <nixpkgs> { } }:

let
  # Import the default.nix to reuse the build configuration
  aoc-package = import ./default.nix { inherit pkgs; };
    # Automatically detect all day directories  
  # Define explicit days to build - this section can be updated by scripts
  explicitDays = [
    "2024/day01"
    "2024/day02"
    "2024/day03"
    "2024/day04"
    "2024/day05"
    "2024/day06"
    "2024/day07"
    "2024/day08"
    # Add new days as they are created
  ];
  
  # Also auto-detect directories as a fallback
  days = let
    # Find the most recent year directory (assumes year directories like 2024, 2023, etc.)
    years = builtins.filter (x: builtins.match "[0-9]{4}" x != null) 
                        (builtins.attrNames (builtins.readDir ./.));
    currentYear = builtins.head (builtins.sort (a: b: a > b) years);
    
    # Read all entries in the year directory
    yearDir = if builtins.length years > 0 then ./${currentYear} else ./.;
    dirEntries = builtins.readDir yearDir;
    
    # Filter to only get day directories (matching "day##" pattern)
    isDayDir = name: type: 
      type == "directory" && builtins.match "day[0-9]{2}" name != null;
    
    # Extract just the directory names that match day pattern
    dayDirs = builtins.attrNames 
      (builtins.filterAttrs isDayDir dirEntries);
        # If we have a year structure, prefix with year, otherwise use as-is
    prefixYear = day: 
      if builtins.length years > 0 
      then "${currentYear}/${day}" 
      else day;
      
    # Get the list of day directories, either from explicit list or auto-detection
    finalDayDirs = 
      if builtins.length explicitDays > 0 
      then explicitDays 
      else builtins.sort (a: b: a < b) dayDirs;
  in
    if builtins.length explicitDays > 0
    then explicitDays
    else builtins.map prefixYear (builtins.sort (a: b: a < b) dayDirs);
  
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
    name = "advent-of-code-rust-all";
    paths = builtins.attrValues dayPackages;
  };
}
