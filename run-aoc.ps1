# run-aoc.ps1 - Helper script for Advent of Code 2024 Rust solutions
# This script replaces the functionality of the Makefile with Windows-native PowerShell

param(
    [Parameter(Position = 0)]
    [string]$Command,
    
    [Parameter(Position = 1)]
    [string]$Day,
    
    [Parameter(Position = 2)]
    [string]$Input
)

# Constants
$DefaultInputPath = "C:\Users\chukw\Downloads\input.txt"

# Helper Functions
function GetDayDirectories {
    return Get-ChildItem -Directory -Filter "day*" | ForEach-Object { $_.Name }
}

function GetCurrentDay {
    $days = GetDayDirectories
    if ($days.Count -eq 0) {
        return $null
    }
    return ($days | Sort-Object -Descending)[0]
}

function ShowHelp {
    Write-Host "Advent of Code 2024 - Rust PowerShell Script Help" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Available commands:"
    Write-Host "  .\run-aoc.ps1 all             : Run tests and linting (default)"
    Write-Host "  .\run-aoc.ps1 build           : Build all days in debug mode"
    Write-Host "  .\run-aoc.ps1 build XX        : Build a specific day (e.g., build 01)"
    Write-Host "  .\run-aoc.ps1 release         : Build all days in release mode"
    Write-Host "  .\run-aoc.ps1 test            : Run tests for all days"
    Write-Host "  .\run-aoc.ps1 test XX         : Run tests for a specific day (e.g., test 01)"
    Write-Host "  .\run-aoc.ps1 lint            : Run clippy and format check"
    Write-Host "  .\run-aoc.ps1 clippy          : Run clippy on all days"
    Write-Host "  .\run-aoc.ps1 fmt             : Format all code"
    Write-Host "  .\run-aoc.ps1 fmt-check       : Check formatting for all code"
    Write-Host "  .\run-aoc.ps1 check           : Run cargo check for all days"
    Write-Host "  .\run-aoc.ps1 benchmark       : Run benchmarks for all days"
    Write-Host "  .\run-aoc.ps1 clean           : Clean all build artifacts"
    Write-Host "  .\run-aoc.ps1 new-day         : Create a new day from template (interactive)"
    Write-Host "  .\run-aoc.ps1 setup           : Setup project from scratch"
    Write-Host "  .\run-aoc.ps1 run-day XX path/to/input.txt : Run a specific day with input"
    Write-Host "  .\run-aoc.ps1 run-release XX path/to/input.txt : Run a specific day in release mode"
    Write-Host "  .\run-aoc.ps1 run-release XX puzzle_input    : Use default input path"
    Write-Host "  .\run-aoc.ps1 run-current path/to/input.txt : Run the current day with input"
    Write-Host "  .\run-aoc.ps1 help            : Show this help message"
    Write-Host ""
    Write-Host "Examples:"
    Write-Host "  .\run-aoc.ps1 build 01            # Build day01"
    Write-Host "  .\run-aoc.ps1 test 03             # Run tests for day03"
    Write-Host "  .\run-aoc.ps1 run-day 02 ..\inputs\day02.txt  # Run day02 with specified input"
    Write-Host "  .\run-aoc.ps1 run-release 01 puzzle_input     # Build and run day01 in release mode with default input"
    Write-Host ""
}

function PadDayNumber {
    param([string]$dayNumber)
    
    if ($dayNumber -match '^\d{1,2}$') {
        # If already a number (1 or 2 digits), pad to 2 digits
        return $dayNumber.PadLeft(2, '0')
    }
    return $dayNumber
}

function BuildAllDays {
    $days = GetDayDirectories
    Write-Host "Building all days..." -ForegroundColor Cyan
    foreach ($day in $days) {
        Write-Host "Building $day..." -ForegroundColor Green
        Push-Location $day
        cargo build
        Pop-Location
    }
}

function BuildSpecificDay {
    param([string]$day)
    
    $day = PadDayNumber $day
    $dayDir = "day$day"
    
    if (-not (Test-Path $dayDir -PathType Container)) {
        Write-Host "Day $day does not exist!" -ForegroundColor Red
        exit 1
    }
    
    Write-Host "Building $dayDir..." -ForegroundColor Green
    Push-Location $dayDir
    cargo build
    Pop-Location
}

function BuildAllDaysRelease {
    $days = GetDayDirectories
    Write-Host "Building all days in release mode..." -ForegroundColor Cyan
    foreach ($day in $days) {
        Write-Host "Building $day in release mode..." -ForegroundColor Green
        Push-Location $day
        cargo build --release
        Pop-Location
    }
}

function TestAllDays {
    $days = GetDayDirectories
    Write-Host "Running tests for all days..." -ForegroundColor Cyan
    foreach ($day in $days) {
        Write-Host "Testing $day..." -ForegroundColor Green
        Push-Location $day
        cargo test
        Pop-Location
    }
}

function TestSpecificDay {
    param([string]$day)
    
    $day = PadDayNumber $day
    $dayDir = "day$day"
    
    if (-not (Test-Path $dayDir -PathType Container)) {
        Write-Host "Day $day does not exist!" -ForegroundColor Red
        exit 1
    }
    
    Write-Host "Testing $dayDir..." -ForegroundColor Green
    Push-Location $dayDir
    cargo test
    Pop-Location
}

function ClippyAllDays {
    $days = GetDayDirectories
    Write-Host "Running clippy on all days..." -ForegroundColor Cyan
    foreach ($day in $days) {
        Write-Host "Linting $day with clippy..." -ForegroundColor Green
        Push-Location $day
        cargo clippy --all-targets --all-features -- -D warnings
        Pop-Location
    }
}

function FormatAllDays {
    $days = GetDayDirectories
    Write-Host "Formatting code for all days..." -ForegroundColor Cyan
    foreach ($day in $days) {
        Write-Host "Formatting $day..." -ForegroundColor Green
        Push-Location $day
        cargo fmt
        Pop-Location
    }
}

function FormatCheckAllDays {
    $days = GetDayDirectories
    Write-Host "Checking formatting for all days..." -ForegroundColor Cyan
    foreach ($day in $days) {
        Write-Host "Checking formatting for $day..." -ForegroundColor Green
        Push-Location $day
        cargo fmt -- --check
        Pop-Location
    }
}

function CheckAllDays {
    $days = GetDayDirectories
    Write-Host "Running cargo check for all days..." -ForegroundColor Cyan
    foreach ($day in $days) {
        Write-Host "Checking $day..." -ForegroundColor Green
        Push-Location $day
        cargo check
        Pop-Location
    }
}

function BenchmarkAllDays {
    $days = GetDayDirectories
    Write-Host "Running benchmarks for all days..." -ForegroundColor Cyan
    foreach ($day in $days) {
        Write-Host "Benchmarking $day..." -ForegroundColor Green
        Push-Location $day
        cargo bench
        Pop-Location
    }
}

function CleanAllDays {
    $days = GetDayDirectories
    Write-Host "Cleaning build artifacts..." -ForegroundColor Cyan
    foreach ($day in $days) {
        Write-Host "Cleaning $day..." -ForegroundColor Green
        Push-Location $day
        cargo clean
        Pop-Location
    }
}

function CreateNewDay {
    # Prompt for day number
    $day = Read-Host "Enter day number (e.g., 04)"
    
    $day = PadDayNumber $day
    $dayDir = "day$day"
    
    # Check if the day already exists
    if (Test-Path $dayDir -PathType Container) {
        Write-Host "$dayDir already exists!" -ForegroundColor Red
        exit 1
    }
    
    Write-Host "Creating $dayDir..." -ForegroundColor Cyan
    
    # Create directory structure
    New-Item -Path "$dayDir/src" -ItemType Directory -Force | Out-Null
    
    # Copy template files
    Copy-Item -Recurse -Force "templates/day_template/*" "$dayDir/"
    
    # Update Cargo.toml
    (Get-Content "$dayDir/Cargo.toml") -replace 'day_template', $dayDir | Set-Content "$dayDir/Cargo.toml"
    
    Write-Host "Created $dayDir successfully!" -ForegroundColor Green
}

function SetupProject {
    Write-Host "Setting up project..." -ForegroundColor Cyan
    
    if (-not (Test-Path "templates" -PathType Container)) {
        Write-Host "Creating templates directory..." -ForegroundColor Green
        New-Item -Path "templates/day_template/src" -ItemType Directory -Force | Out-Null
        
        # Create Cargo.toml template
        @'
[package]
name = "day_template"
version = "0.1.0"
edition = "2024"

[dependencies]
'@ | Set-Content "templates/day_template/Cargo.toml"
        
        # Create main.rs template
        @'
// main.rs template
use day_template::{part1, part2};
use std::io::{self, Read};
use std::time::Instant;

fn main() {
    // Read input from stdin
    let mut input = String::new();
    io::stdin().read_to_string(&mut input).unwrap();
    let input = input.trim();

    let start_time = Instant::now();

    println!("Part 1: {}", part1(input));
    println!("Part 2: {}", part2(input));

    let elapsed = start_time.elapsed();
    println!("Elapsed time: {:.4} seconds", elapsed.as_secs_f64());
}
'@ | Set-Content "templates/day_template/src/main.rs"
        
        # Create lib.rs template
        @'
// lib.rs template

pub fn part1(input: &str) -> u64 {
    // TODO: Implement part 1
    0
}

pub fn part2(input: &str) -> u64 {
    // TODO: Implement part 2
    0
}

#[cfg(test)]
mod tests {
    use super::*;

    const EXAMPLE_INPUT: &str = "";

    #[test]
    fn test_part1() {
        assert_eq!(part1(EXAMPLE_INPUT), 0);
    }

    #[test]
    fn test_part2() {
        assert_eq!(part2(EXAMPLE_INPUT), 0);
    }
}
'@ | Set-Content "templates/day_template/src/lib.rs"
    }
}

function RunDay {
    param(
        [string]$day,
        [string]$inputPath
    )
    
    $day = PadDayNumber $day
    $dayDir = "day$day"
    
    if (-not (Test-Path $dayDir -PathType Container)) {
        Write-Host "Day $day does not exist!" -ForegroundColor Red
        exit 1
    }
    
    if ([string]::IsNullOrEmpty($inputPath)) {
        Write-Host "Please specify an input file!" -ForegroundColor Red
        exit 1
    }
    
    Write-Host "Running $dayDir with input $inputPath..." -ForegroundColor Cyan
    Push-Location $dayDir
    Get-Content $inputPath | cargo run
    Pop-Location
}

function RunDayRelease {
    param(
        [string]$day,
        [string]$inputPath
    )
    
    $day = PadDayNumber $day
    $dayDir = "day$day"
    
    if (-not (Test-Path $dayDir -PathType Container)) {
        Write-Host "Day $day does not exist!" -ForegroundColor Red
        exit 1
    }
    
    if ([string]::IsNullOrEmpty($inputPath)) {
        # Default to the default input path
        $inputPath = $DefaultInputPath
    }
    
    # Handle puzzle_input special case
    if ($inputPath -eq "puzzle_input") {
        $inputPath = $DefaultInputPath
    }
      Write-Host "Building and running $dayDir in release mode with input $inputPath..." -ForegroundColor Cyan
    Push-Location $dayDir
    cargo build --release
    Get-Content $inputPath | & ".\target\release\$($dayDir).exe"
    Pop-Location
}

function RunCurrentDay {
    param([string]$inputPath)
    
    $currentDay = GetCurrentDay
    if ($null -eq $currentDay) {
        Write-Host "No day directories found!" -ForegroundColor Red
        exit 1
    }
    
    if ([string]::IsNullOrEmpty($inputPath)) {
        Write-Host "Please specify an input file!" -ForegroundColor Red
        exit 1
    }
    
    Write-Host "Running $currentDay with input $inputPath..." -ForegroundColor Cyan
    Push-Location $currentDay
    Get-Content $inputPath | cargo run
    Pop-Location
}

# Main logic
if ($null -eq $Command -or $Command -eq "help") {
    ShowHelp
    exit 0
}

# Process the command
switch ($Command) {
    "all" { 
        TestAllDays
        ClippyAllDays
        FormatCheckAllDays
    }
    "build" {
        if ($Day) {
            BuildSpecificDay $Day
        } else {
            BuildAllDays
        }
    }
    "release" { BuildAllDaysRelease }
    "test" {
        if ($Day) {
            TestSpecificDay $Day
        } else {
            TestAllDays
        }
    }
    "lint" {
        ClippyAllDays
        FormatCheckAllDays
    }
    "clippy" { ClippyAllDays }
    "fmt" { FormatAllDays }
    "fmt-check" { FormatCheckAllDays }
    "check" { CheckAllDays }
    "benchmark" { BenchmarkAllDays }
    "clean" { CleanAllDays }
    "new-day" { CreateNewDay }
    "setup" { SetupProject }
    "run-day" {
        if (-not $Day) {
            Write-Host "Please specify a day!" -ForegroundColor Red
            exit 1
        }
        RunDay $Day $Input
    }
    "run-release" {
        if (-not $Day) {
            Write-Host "Please specify a day!" -ForegroundColor Red
            exit 1
        }
        RunDayRelease $Day $Input
    }
    "run-current" { RunCurrentDay $Day }
    default {
        Write-Host "Unknown command: $Command" -ForegroundColor Red
        ShowHelp
        exit 1
    }
}
