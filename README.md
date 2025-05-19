# Advent of Code 2024 - Rust Solutions

This repository contains solutions for the [Advent of Code 2024](https://adventofcode.com/2024) puzzles, implemented in Rust.

## Development Environment Setup

This project provides several ways to set up a consistent development environment:

### Using Nix (Recommended)

If you have [Nix](https://nixos.org/) and [direnv](https://direnv.net/) installed:

1. Allow the `.envrc` file:
   ```bash
   direnv allow
   ```

2. Nix will automatically setup the development environment with all required tools.

### Using Nix Shell Manually

If you have [Nix](https://nixos.org/) installed but not direnv:

```bash
nix-shell
```

### Traditional Setup

1. Install [Rust](https://www.rust-lang.org/tools/install)
2. Clone this repository:
   ```bash
   git clone https://github.com/your-username/advent-of-code-2024-rust
   cd advent-of-code-2024-rust
   ```

## Project Structure

Each day's puzzle is implemented as a separate Rust crate:

- `day01/`: Solution for Day 1
- `day02/`: Solution for Day 2
- `etc`
- ...

## Build and Run

The project supports two build systems: a `Makefile` for Unix-like environments (Linux, macOS, WSL) and a PowerShell script for native Windows environments.

### Unix/Linux/WSL Build System (Makefile)

If you're using a Unix-like environment (including WSL on Windows):

#### Build

```bash
# Build all days in debug mode
make build

# Build a specific day
make build-01

# Build all days in release mode
make release
```

#### Test

```bash
# Run tests for all days
make test

# Run tests for a specific day
make test-01
```

#### Run

```bash
# Run a specific day with input
make run-day DAY=01 INPUT=path/to/input.txt

# Run a specific day in release mode with input
make run-release DAY=01 INPUT=path/to/input.txt

# Run a specific day in release mode with default input path
make run-release DAY=01 INPUT=puzzle_input

# Run the current (most recent) day with input
make run-current INPUT=path/to/input.txt

# Run the current (most recent) day with default input path
make run-current INPUT=puzzle_input
```

#### Create a New Day

```bash
make new-day
# Enter the day number when prompted
```

#### Quality Checks

```bash
# Run linting (clippy and formatting check)
make lint

# Format all code
make fmt

# Check only
make check
```

### Windows Native Build System (PowerShell)

For Windows users who prefer to work natively (without WSL), a PowerShell script is provided:

#### Build

```powershell
# Build all days in debug mode
.\run-aoc.ps1 build

# Build a specific day
.\run-aoc.ps1 build 01

# Build all days in release mode
.\run-aoc.ps1 release
```

#### Test

```powershell
# Run tests for all days
.\run-aoc.ps1 test

# Run tests for a specific day
.\run-aoc.ps1 test 01
```

#### Run

```powershell
# Run a specific day with input
.\run-aoc.ps1 run-day 01 path\to\input.txt

# Run a specific day in release mode with input
.\run-aoc.ps1 run-release 01 path\to\input.txt

# Use default input path (Downloads folder)
.\run-aoc.ps1 run-release 01 puzzle_input

# Run the current (most recent) day with input
.\run-aoc.ps1 run-current path\to\input.txt
```

#### Create a New Day

```powershell
.\run-aoc.ps1 new-day
# Enter the day number when prompted
```

#### Quality Checks

```powershell
# Run linting (clippy and formatting check)
.\run-aoc.ps1 lint

# Format all code
.\run-aoc.ps1 fmt

# Check formatting
.\run-aoc.ps1 fmt-check

# Run cargo check
.\run-aoc.ps1 check
```

#### Initial Setup

```powershell
# Set up project from scratch (creates templates)
.\run-aoc.ps1 setup
```

#### Get Help

```powershell
# Show all available commands
.\run-aoc.ps1 help
```

### See All Available Commands

```bash
make help
```

## Building with Nix

This repository also includes Nix build files:

```bash
# Build everything
nix-build build.nix -A all

# Build a specific day
nix-build build.nix -A days.day01
```

## License

[MIT License](License.md)