# Advent of Code—Rust Solutions

This repository contains solutions for the [Advent of Code 2024](https://adventofcode.com/2024) and other years puzzles, implemented in Rust.

## Development Environment Setup

This project provides several ways to set up a consistent development environment:

### Using Nix (Recommended)

If you have [Nix](https://nixos.org/) and [direnv](https://direnv.net/) installed:

1. Allow the `.envrc` file:
   ```bash
   direnv allow
   ```

2. Nix will automatically set up the development environment with all required tools.

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

## Automated Workflow

This project includes automated tools for a streamlined Advent of Code workflow:

1. **Automatic Input Management**:
   - Downloads puzzle inputs automatically
   - Stores inputs in `inputs/2024/day01.txt` format
   - Falls back to default locations if needed

2. **Smart Answer Submission**:
   - Runs your solution and extracts both Part 1 and Part 2 answers
   - Saves answers in `answers/2024/submit_dayXX.txt`
   - Tracks submission status (Correct/Incorrect)
   - Automatically handles Part 1 before Part 2 submission
   - Shows helpful messages for incorrect answers (too high/low)

3. **Input File Priority**:
   - Path specified in commands (e.g., `make run-day DAY=01 INPUT=path/to/custom/input.txt`)
   - Day-specific file in repository: `inputs/2024/day01.txt`
   - Generic input file in repository: `inputs/2024/input.txt`
   - Default download location (as specified in `.envrc` or script constants)

### Setting Up Input Files

For new users, we recommend:

1. Create an `inputs/2024/` directory in your project root if it doesn't exist
2. Create an `.env` file in your project root with your Advent of Code session token:
   ```
   AUTH_TOKEN=your_session_token_here
   ```
3. Use the automated download and submit features (see below), or manually:
   - Download your puzzle inputs from the [Advent of Code website](https://adventofcode.com/2024)
   - Save day-specific inputs as `inputs/2024/day01.txt`, `inputs/2024/day02.txt`, etc.
   - Alternatively, save the current day's input as `inputs/2024/input.txt`

The scripts will automatically find these files when using the `puzzle_input` parameter:

```bash
# Using repository input files, DAY=XX represent day
make run-release DAY=01 INPUT=puzzle_input
```

```powershell
# Using repository input files in PowerShell, 01/XX represent day
.\run-aoc.ps1 run-release 01 puzzle_input
```

## Build and Run

The project supports two build systems: a `Makefile` for Unix-like environments (Linux, macOS, WSL) and a `PowerShell script` for native Windows environments.

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

#### Run and Submit Solutions

```bash
# Download input for a specific day
make download DAY=01

# Run a day's solution and be prompted to submit answers
make run-submit DAY=01 INPUT=inputs/2024/day01.txt

# Download input, run solution, and be prompted to submit answers
make run-submit DAY=01 INPUT=download

# Submit a specific part's answer manually
make submit DAY=01 PART=1  # Submit Part 1
make submit DAY=01 PART=2  # Submit Part 2

# Check submission status for a day
make check-status DAY=01

# Basic Run Commands
make run-day DAY=01 INPUT=path/to/input.txt         # Run with input
make run-release DAY=01 INPUT=path/to/input.txt     # Run in release mode
make run-release DAY=01 INPUT=puzzle_input          # Use default input path
make run-current INPUT=path/to/input.txt            # Run most recent day
make run-current INPUT=puzzle_input                 # Use default input path
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

#### See All Available Commands

```bash
make help
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

#### Run and Submit Solutions

```powershell
# Download input for a specific day
.\run-aoc.ps1 download 01

# Run a day's solution and be prompted to submit answers
.\run-aoc.ps1 run-submit 01 inputs\2024\day01.txt

# Download input, run solution, and be prompted to submit answers
.\run-aoc.ps1 run-submit 01 download

# Submit a specific part's answer manually
.\run-aoc.ps1 submit 01 1  # Submit Part 1
.\run-aoc.ps1 submit 01 2  # Submit Part 2

# Check submission status for a day
.\run-aoc.ps1 check 01


# Basic Run Commands
.\run-aoc.ps1 run-day 01 path\to\input.txt            # Run with input
.\run-aoc.ps1 run-release 01 path\to\input.txt        # Run in release mode
.\run-aoc.ps1 run-release 01 puzzle_input             # Use default input path
.\run-aoc.ps1 run-current path\to\input.txt           # Run most recent day
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

#### Get Help | Show all available commands

```powershell
# Show all available commands
.\run-aoc.ps1 help
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

### Example Workflows

#### PowerShell (Windows)
```powershell
# Complete workflow for a new day
.\run-aoc.ps1 download 01                         # Download input
.\run-aoc.ps1 run-submit 01 puzzle_input         # Run and submit answers
.\run-aoc.ps1 submit 01 2                        # Submit Part 2 directly

# Or more concisely
.\run-aoc.ps1 run-submit 01 download             # Download, run, and submit in one command
```

#### Make (Unix/Linux/WSL)
```bash
# Complete workflow for a new day
make download DAY=01                             # Download input
make run-submit DAY=01 INPUT=puzzle_input       # Run and submit answers
make submit DAY=01 PART=2                       # Submit Part 2 directly

# Or more concisely
make run-submit DAY=01 INPUT=download           # Download, run, and submit in one command
```

These scripts will handle downloading inputs, running solutions, saving answers, and managing submissions automatically. They also provide helpful feedback for incorrect answers and maintain submission status.
