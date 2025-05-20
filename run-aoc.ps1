# run-aoc.ps1 - Helper script for Advent of Code Rust solutions
# This script replaces the functionality of the Makefile with Windows-native PowerShell

param(
    [Parameter(Position = 0)]
    [string]$Command,
    
    [Parameter(Position = 1)]
    [string]$Day,
    
    [Parameter(Position = 2)]
    [string]$InputPath
)

# Find the most recent year folder
$AvailableYears = Get-ChildItem -Directory -Filter "20??" | Sort-Object -Descending
if ($AvailableYears.Count -eq 0) {
    Write-Host "No year directories found. Please create a directory like 2024 first." -ForegroundColor Red
    exit 1
}
$Year = $AvailableYears[0].Name
Write-Host "Using year: $Year" -ForegroundColor Cyan

# Constants
# You can modify DefaultInputPath to point to your preferred location if you don't use the repo inputs
$DefaultInputPath = "C:\Users\chukw\Downloads\input.txt"
$RepoInputDir = Join-Path (Get-Location).Path "inputs\$Year"

# Check if inputs directory exists, create it if not
if (-not (Test-Path $RepoInputDir -PathType Container)) {
    Write-Host "Notice: Repository inputs directory not found at: $RepoInputDir" -ForegroundColor Yellow
    Write-Host "For best experience, consider creating this directory and placing your puzzle inputs there." -ForegroundColor Yellow
    Write-Host "Creating directory structure for you..." -ForegroundColor Cyan
    New-Item -Path $RepoInputDir -ItemType Directory -Force | Out-Null
    Write-Host "Created $RepoInputDir - You can now place your puzzle inputs there as:" -ForegroundColor Green
    Write-Host "- Day-specific files: $RepoInputDir\day01.txt, $RepoInputDir\day02.txt, etc." -ForegroundColor Green
    Write-Host "- Generic input file: $RepoInputDir\input.txt" -ForegroundColor Green
}

# Helper Functions
function GetDayDirectories {
    return Get-ChildItem -Path "$Year" -Directory -Filter "day*" | ForEach-Object { Join-Path $Year $_.Name }
}

function GetCurrentDay {
    $days = GetDayDirectories
    if ($days.Count -eq 0) {
        return $null
    }
    return ($days | Sort-Object -Descending)[0]
}

function ShowHelp {
    Write-Host "Advent of Code $Year - Rust PowerShell Script Help" -ForegroundColor Cyan
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
    Write-Host "  .\run-aoc.ps1 clean           : Clean all build artifacts"
    Write-Host "  .\run-aoc.ps1 new-day         : Create a new day from template (interactive)"
    Write-Host "  .\run-aoc.ps1 setup           : Setup project from scratch"    Write-Host "  .\run-aoc.ps1 run-day XX path/to/input.txt     : Run a specific day with input file"
    Write-Host "  .\run-aoc.ps1 run-release XX path/to/input.txt : Run a specific day in release mode"
    Write-Host "  .\run-aoc.ps1 run-release XX puzzle_input      : Use default input path"
    Write-Host "  .\run-aoc.ps1 run-current path/to/input.txt    : Run the current day with input file"
    Write-Host "  .\run-aoc.ps1 run-current puzzle_input         : Run the current day with default input"
    Write-Host ""
    Write-Host "Input path handling:"
    Write-Host "  - Absolute paths: C:\path\to\input.txt"
    Write-Host "  - Relative paths from workspace root: inputs/2024/day01.txt"
    Write-Host "  - Root-relative paths: /inputs/2024/day01.txt (converted to workspace-relative)"
    Write-Host "  .\run-aoc.ps1 download XX       : Download puzzle input for day XX"
    Write-Host "  .\run-aoc.ps1 check XX          : Check submission status for day XX"    
    Write-Host "  .\run-aoc.ps1 submit XX P       : Submit answer for day XX part P (1 or 2)"
    Write-Host "  .\run-aoc.ps1 force-submit XX P : Force-submit answer for day XX part P (bypasses completion check)"
    Write-Host "  .\run-aoc.ps1 run-submit XX path : Run day XX and prompt to submit answers"
    Write-Host "  .\run-aoc.ps1 run-submit XX download : Download input, run day XX, and prompt to submit"
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
    $dayDir = "$Year/day$day"
    
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
    $dayDir = "$Year/day$day"
    
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
    $dayDir = "$Year/day$day"
    
    # Check if the day already exists
    if (Test-Path $dayDir -PathType Container) {
        Write-Host "$dayDir already exists!" -ForegroundColor Red
        exit 1
    }
    
    # Make sure the year directory exists
    if (-not (Test-Path $Year -PathType Container)) {
        Write-Host "Creating $Year directory..." -ForegroundColor Cyan
        New-Item -Path $Year -ItemType Directory -Force | Out-Null
    }
    
    Write-Host "Creating $dayDir..." -ForegroundColor Cyan
    
    # Create directory structure
    New-Item -Path "$dayDir/src" -ItemType Directory -Force | Out-Null
    
    # Copy template files
    Copy-Item -Recurse -Force "templates/day_template/*" "$dayDir/"
    
    # Update Cargo.toml
    (Get-Content "$dayDir/Cargo.toml") -replace 'day_template', "day$day" | Set-Content "$dayDir/Cargo.toml"
    
    # Update workspace Cargo.toml to include the new day
    Write-Host "Updating workspace Cargo.toml..." -ForegroundColor Cyan
    $cargoToml = Get-Content "Cargo.toml"
    $updatedCargoToml = @()
    $commentFound = $false
    
    foreach ($line in $cargoToml) {
        if ($line -eq '    # Add new days as they are created' -and -not $commentFound) {
            $updatedCargoToml += "    `"$Year/day$day`","
            $updatedCargoToml += $line
            $commentFound = $true
        }
        else {
            $updatedCargoToml += $line
        }
    }
    
    if (-not $commentFound) {
        Write-Host "Could not find comment marker in Cargo.toml. Please add `"$Year/day$day`" manually." -ForegroundColor Yellow
    }
    else {
        $updatedCargoToml | Set-Content "Cargo.toml"
        Write-Host "Updated Cargo.toml with new day." -ForegroundColor Green
    }
    
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
    $dayDir = "$Year/day$day"
    
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
    $dayDir = "$Year/day$day"
    
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
        # Check repository inputs first - use absolute paths from workspace root
        $day = PadDayNumber $day
        $workspaceRoot = (Get-Location).Path
        $daySpecificInput = Join-Path $workspaceRoot "inputs\$Year\day$day.txt"
        $genericInput = Join-Path $workspaceRoot "inputs\$Year\input.txt"
        
        Write-Host "Checking for day-specific input at: $daySpecificInput" -ForegroundColor Yellow
        Write-Host "Checking for generic input at: $genericInput" -ForegroundColor Yellow
        
        if (Test-Path $daySpecificInput) {
            Write-Host "Using day-specific input file" -ForegroundColor Green
            $inputPath = $daySpecificInput
        }
        elseif (Test-Path $genericInput) {
            Write-Host "Using generic input file" -ForegroundColor Green
            $inputPath = $genericInput
        }
        else {
            Write-Host "Using default input path" -ForegroundColor Yellow
            # Default to downloads folder
            $inputPath = $DefaultInputPath
            if (-not (Test-Path $inputPath)) {
                Write-Host "Warning: Default input path does not exist: $inputPath" -ForegroundColor Red
                exit 1
            }
        }
    }
    else {
        # Convert relative paths to absolute paths
        if (-not [System.IO.Path]::IsPathRooted($inputPath)) {
            $workspaceRoot = (Get-Location).Path
            $inputPath = Join-Path $workspaceRoot $inputPath
            Write-Host "Using absolute path: $inputPath" -ForegroundColor Yellow
        }
        
        # Handle paths starting with \ by treating them as relative to workspace root
        if ($inputPath -match '^\\') {
            $workspaceRoot = (Get-Location).Path
            $inputPath = Join-Path $workspaceRoot $inputPath.TrimStart('\')
            Write-Host "Converted to workspace path: $inputPath" -ForegroundColor Yellow
        }

        # Verify that the specified input path exists
        if (-not (Test-Path $inputPath)) {
            Write-Host "Input file not found: $inputPath" -ForegroundColor Red
            Write-Host "Note: Input paths can be:"
            Write-Host "  - Absolute paths: C:\path\to\input.txt"
            Write-Host "  - Relative to workspace: inputs\2024\day02.txt"
            Write-Host "  - Starting with \: \inputs\2024\day02.txt (relative to workspace)"
            exit 1
        }
    }Write-Host "Building and running $dayDir in release mode with input $inputPath..." -ForegroundColor Cyan
    Push-Location $dayDir
    cargo build --release
    # Get just the day directory name without the year prefix
    $dayName = ($dayDir -split '/')[-1]
    
    # Check if the executable exists in the day's target directory
    $exePath = Join-Path (Get-Location).Path "target\release\$dayName.exe"
    
    if (Test-Path $exePath) {
        Write-Host "Running $exePath with input from $inputPath" -ForegroundColor Green
        Get-Content $inputPath | & "$exePath"
    }
    else {
        # Check if the executable exists in the workspace target directory instead
        Pop-Location
        $workspaceTarget = Join-Path (Get-Location).Path "target\release\$dayName.exe"
        Push-Location $dayDir
        if (Test-Path $workspaceTarget) {
            Write-Host "Using workspace target: $workspaceTarget" -ForegroundColor Yellow
            Get-Content $inputPath | & "$workspaceTarget"
        }
        else {
            Write-Host "Executable not found at: $exePath" -ForegroundColor Red
            Write-Host "Also not found at: $workspaceTarget" -ForegroundColor Red
            Write-Host "Trying fallback method with cargo run..." -ForegroundColor Yellow
            # Go back to the day directory and run cargo directly
            Pop-Location
            Push-Location $dayDir
            Get-Content $inputPath | cargo run --release
        }
    }
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
    }    # Handle puzzle_input special case
    if ($inputPath -eq "puzzle_input") {
        # Extract day number from current day directory
        $dayNum = ($currentDay -split '/')[-1] -replace "day", ""
        $workspaceRoot = (Get-Location).Path
        $daySpecificInput = Join-Path $workspaceRoot "inputs\$Year\day$dayNum.txt"
        $genericInput = Join-Path $workspaceRoot "inputs\$Year\input.txt"
        
        Write-Host "Checking for day-specific input at: $daySpecificInput" -ForegroundColor Yellow
        Write-Host "Checking for generic input at: $genericInput" -ForegroundColor Yellow
        
        if (Test-Path $daySpecificInput) {
            Write-Host "Using day-specific input file" -ForegroundColor Green
            $inputPath = $daySpecificInput
        }
        elseif (Test-Path $genericInput) {
            Write-Host "Using generic input file" -ForegroundColor Green
            $inputPath = $genericInput
        }
        else {
            # Default to downloads folder
            $inputPath = $DefaultInputPath
            Write-Host "Using default input path: $inputPath" -ForegroundColor Yellow
            if (-not (Test-Path $inputPath)) {
                Write-Host "Warning: Default input path does not exist!" -ForegroundColor Red
                exit 1
            }
        }
    }
    else {
        # Verify that the specified input path exists
        if (-not (Test-Path $inputPath)) {
            Write-Host "Input file not found: $inputPath" -ForegroundColor Red
            exit 1
        }
    }    Write-Host "Running $currentDay with input $inputPath..." -ForegroundColor Cyan
    Push-Location $currentDay
    # Extract just the day directory name without the year prefix
    $dayName = ($currentDay -split '/')[-1]
    
    # Check if the executable exists in the day's target directory
    $exePath = Join-Path (Get-Location).Path "target\release\$dayName.exe"
    
    if (Test-Path $exePath) {
        Write-Host "Using release build executable: $exePath" -ForegroundColor Green
        Get-Content $inputPath | & "$exePath"
    }
    else {
        # Check if the executable exists in the workspace target directory instead
        Pop-Location
        $workspaceTarget = Join-Path (Get-Location).Path "target\release\$dayName.exe"
        Push-Location $currentDay
        
        if (Test-Path $workspaceTarget) {
            Write-Host "Using workspace target: $workspaceTarget" -ForegroundColor Yellow
            Get-Content $inputPath | & "$workspaceTarget"
        }
        else {
            Write-Host "No release build found, using cargo run" -ForegroundColor Yellow
            # Use Get-Content and pipe rather than stdin redirection for better compatibility
            Get-Content $inputPath | cargo run
        }
    }
    Pop-Location
}

function GetSessionToken {
    # First check if .env file exists
    $EnvPath = Join-Path (Get-Location).Path ".env"
    if (Test-Path $EnvPath) {
        # Parse the .env file to extract AUTH_TOKEN
        $envContent = Get-Content $EnvPath -Raw
        if ($envContent -match 'AUTH_TOKEN=([^\r\n]+)') {
            $token = $Matches[1]
            Write-Host "Using session token from .env file" -ForegroundColor Green
            return $token
        }
    }
    
    # If we couldn't get it from .env, ask the user
    $token = Read-Host "Enter your Advent of Code session token"
    
    # Ask if they want to save it to .env
    $saveToken = Read-Host "Do you want to save this token for future use? (y/n)"
    if ($saveToken -eq "y") {
        "AUTH_TOKEN=$token" | Out-File -FilePath $EnvPath
        Write-Host "Token saved to .env file" -ForegroundColor Green
    }
    
    return $token
}

function CheckSubmissionStatus {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Year,
        
        [Parameter(Mandatory = $true)]
        [string]$Day,
        
        [Parameter(Mandatory = $false)]
        [string]$SessionToken
    )
    
    $day = PadDayNumber $Day
    $dayNum = [int]$day
    
    # Get session token if not provided
    if ([string]::IsNullOrEmpty($SessionToken)) {
        $SessionToken = GetSessionToken
    }
    
    try {
        # Fetch the puzzle page
        $url = "https://adventofcode.com/$Year/day/$dayNum"
        $headers = @{
            "Cookie"     = "session=$SessionToken"
            "User-Agent" = "github.com/advent-of-code-rust"
        }
        
        Write-Host "Checking submission status for Year ${Year} Day ${day}..." -ForegroundColor Cyan
        $response = Invoke-WebRequest -Uri $url -Headers $headers -UseBasicParsing
        
        $content = $response.Content
        $status = @{
            "Part1"     = $false
            "Part2"     = $false
            "Available" = $true
        }
        
        # Check if the problem is available
        if ($content -match "Please log in to get your puzzle input") {
            Write-Host "You need to be logged in to access this puzzle." -ForegroundColor Yellow
            $status.Available = $false
            return $status
        }
        
        # Check if puzzle is not yet available
        if ($content -match "Please wait until the puzzle is available") {
            Write-Host "This puzzle is not yet available." -ForegroundColor Yellow
            $status.Available = $false
            return $status
        }
        
        # First check for both parts complete message
        # Check primary completion indicator first
        if ($content -match "Both parts of this puzzle are complete! They provide two gold stars: \*\*") {
            $status.Part1 = $true
            $status.Part2 = $true
            # Update answer file with correct statuses
            UpdateAnswerStatus -Year $Year -Day $day -Part 1 -Status "Correct"
            UpdateAnswerStatus -Year $Year -Day $day -Part 2 -Status "Correct"
        }
        else {
            # Fall back to checking individual completion messages
            if ($content -match "(one gold star: \*|You have completed Part One!)") {
                $status.Part1 = $true
                UpdateAnswerStatus -Year $Year -Day $day -Part 1 -Status "Correct"
            }
            if ($content -match "You have completed Day $dayNum!") {
                $status.Part2 = $true
                UpdateAnswerStatus -Year $Year -Day $day -Part 2 -Status "Correct"
            }
        }
        
        return $status
    }
    catch {
        Write-Host "Error checking submission status: $_" -ForegroundColor Red
        return @{
            "Part1"     = $false
            "Part2"     = $false
            "Available" = $false
            "Error"     = $_
        }
    }
}

function DownloadPuzzleInput {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Year,
        
        [Parameter(Mandatory = $true)]
        [string]$Day
    )
    
    $day = PadDayNumber $Day
    
    # Create inputs directory if it doesn't exist
    $InputDir = Join-Path (Get-Location).Path "inputs\$Year"
    if (-not (Test-Path $InputDir -PathType Container)) {
        New-Item -Path $InputDir -ItemType Directory -Force | Out-Null
        Write-Host "Created inputs directory: $InputDir" -ForegroundColor Green
    }
    
    $OutputFile = Join-Path $InputDir "day$day.txt"
    
    # Check if we already have the input file
    if (Test-Path $OutputFile) {
        Write-Host "Input file already exists at: $OutputFile" -ForegroundColor Yellow
        $overwrite = Read-Host "Do you want to download again? (y/n)"
        if ($overwrite -ne "y") {
            return $OutputFile
        }
    }
    
    # Get session token
    $SessionToken = GetSessionToken
    
    # Check if puzzle is available
    $status = CheckSubmissionStatus -Year $Year -Day $Day -SessionToken $SessionToken
    if (-not $status.Available) {
        Write-Host "Puzzle is not yet available or there was an error accessing it." -ForegroundColor Red
        return $null
    }
    
    # Download the input
    try {
        $url = "https://adventofcode.com/$Year/day/$([int]$day)/input"
        $headers = @{
            "Cookie"     = "session=$SessionToken"
            "User-Agent" = "github.com/advent-of-code-rust"
        }
        
        Write-Host "Downloading input for Year ${Year} Day ${day} from ${url}" -ForegroundColor Cyan
        $response = Invoke-WebRequest -Uri $url -Headers $headers -UseBasicParsing
        
        if ($response.StatusCode -eq 200) {
            $content = $response.Content
            $content | Out-File -FilePath $OutputFile -NoNewline
            Write-Host "Successfully downloaded and saved input to $OutputFile" -ForegroundColor Green
            return $OutputFile
        }
        else {
            Write-Host "Failed to download input. Status code: $($response.StatusCode)" -ForegroundColor Red
            return $null
        }
    }
    catch {
        Write-Host "Error downloading input: $_" -ForegroundColor Red
        return $null
    }
}


function SubmitAnswer {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Year,
        
        [Parameter(Mandatory = $true)]
        [string]$Day,
        
        [Parameter(Mandatory = $true)]
        [int]$Part,
        
        [Parameter(Mandatory = $true)]
        [string]$Answer
    )
    
    $day = PadDayNumber $Day
    $dayNum = [int]$day
    
    # Get session token
    $SessionToken = GetSessionToken
    
    # Check submission status first
    $status = CheckSubmissionStatus -Year $Year -Day $Day -SessionToken $SessionToken
    
    if (-not $status.Available) {
        Write-Host "Puzzle is not available." -ForegroundColor Red
        return $false
    }
    # Check if already completed
    if (($Part -eq 1 -and $status.Part1) -or ($Part -eq 2 -and $status.Part2)) {
        Write-Host "You have already solved Year $Year Day $day Part $Part!" -ForegroundColor Green
        return $true
    }
    # Check if part 2 is unlocked
    if ($Part -eq 2 -and -not $status.Part1) {
        # Check the answer file to see if we have a "Correct" status for Part 1
        $answerFile = Join-Path (Get-Location).Path "answers\$Year\submit_day$day.txt"
        $part1Completed = $false
        
        if (Test-Path $answerFile) {
            $fileContent = Get-Content $answerFile -Raw
            if ($fileContent -match "Part1:.*\[Status: Correct\]") {
                $part1Completed = $true
                Write-Host "Found Part 1 marked as correct in answer file. Proceeding with Part 2 submission." -ForegroundColor Green
            }
        }
        
        if (-not $part1Completed) {
            Write-Host "Part 1 needs to be completed before submitting Part 2." -ForegroundColor Yellow
            Write-Host "If you believe this is incorrect and have already completed Part 1, use 'force-submit' instead:" -ForegroundColor Yellow
            Write-Host "  .\run-aoc.ps1 force-submit $day 2" -ForegroundColor Cyan
            return $false
        }
    }
    try {
        $url = "https://adventofcode.com/$Year/day/$dayNum/answer"
        $headers = @{
            "Cookie"     = "session=$SessionToken"
            "User-Agent" = "github.com/advent-of-code-rust"
        }
        $formData = @{
            "level"  = $Part
            "answer" = $Answer
        }
        
        Write-Host "Submitting answer for Year ${Year} Day ${day} Part ${Part}: ${Answer}" -ForegroundColor Cyan
        $response = Invoke-WebRequest -Uri $url -Method Post -Headers $headers -Body $formData -UseBasicParsing
        
        # Parse the response to determine if the answer was correct
        $content = $response.Content
        
        if ($content -match "That's the right answer") {
            Write-Host "Correct answer! Well done." -ForegroundColor Green
            # Update status in answers file
            UpdateAnswerStatus -Year $Year -Day $day -Part $Part -Status "Correct"
            return $true
        }
        elseif ($content -match "You gave an answer too recently") {
            # Extract the time to wait
            if ($content -match "You have ([0-9]+m [0-9]+s) left to wait") {
                $waitTime = $Matches[1]
                Write-Host "You need to wait $waitTime before submitting again." -ForegroundColor Yellow
            }
            else {
                Write-Host "You need to wait before submitting again." -ForegroundColor Yellow
            }
            return $false
        }
        elseif ($content -match "That's not the right answer") {
            if ($content -match "your answer is too (high|low)") {
                $direction = $Matches[1]
                Write-Host "Incorrect answer. Your answer is too $direction." -ForegroundColor Red
            }
            else {
                Write-Host "Incorrect answer." -ForegroundColor Red
            }
            # Update status in answers file
            UpdateAnswerStatus -Year $Year -Day $day -Part $Part -Status "Incorrect"
            return $false
        }
        elseif ($content -match "You don't seem to be solving the right level") {
            Write-Host "You've already solved this part or are not on this level yet." -ForegroundColor Yellow
            return $false
        }
        else {
            Write-Host "Unexpected response from Advent of Code. Please check manually." -ForegroundColor Red
            return $false
        }
    }
    catch {
        Write-Host "Error submitting answer: $_" -ForegroundColor Red
        return $false
    }
}

function UpdateAnswerStatus {
    param(
        [string]$Year,
        [string]$Day,
        [int]$Part,
        [string]$Status
    )
    
    $day = PadDayNumber $Day
    $answerFile = Join-Path (Get-Location).Path "answers\$Year\submit_day$day.txt"
    
    if (Test-Path $answerFile) {
        $content = Get-Content $answerFile
        $updated = @()
        $found = $false
        
        foreach ($line in $content) {
            # Check if line matches Part[1-9]:
            if ($line -match "^Part$Part`:" ) {
                $found = $true
                
                # If line already has status, update it
                if ($line -match "\[Status: .*\]") {
                    $updated += $line -replace "\[Status: .*\]", "[Status: $Status]"
                }
                else {
                    # If no status, add it
                    $updated += "$line [Status: $Status]"
                }
            }
            else {
                $updated += $line
            }
        }
        
        if ($found) {
            $updated | Set-Content $answerFile
        }
    }
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
        }
        else {
            BuildAllDays
        }
    }
    "release" { BuildAllDaysRelease }
    "test" {
        if ($Day) {
            TestSpecificDay $Day
        }
        else {
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
    "clean" { CleanAllDays }
    "new-day" { CreateNewDay }
    "setup" { SetupProject }
    "run-day" {
        if (-not $Day) {
            Write-Host "Please specify a day!" -ForegroundColor Red
            exit 1
        }
        RunDay $Day $InputPath
    }
    "run-release" {
        if (-not $Day) {
            Write-Host "Please specify a day!" -ForegroundColor Red
            exit 1
        }
        RunDayRelease $Day $InputPath
    }
    "run-current" { RunCurrentDay $Day }
    "download" {
        if (-not $Day) {
            Write-Host "Please specify a day!" -ForegroundColor Red
            exit 1
        }
        DownloadPuzzleInput -Year $Year -Day $Day
    }
    "submit" {
        if (-not $Day) {
            Write-Host "Please specify a day!" -ForegroundColor Red
            exit 1
        }
        
        $part = if ($InputPath) { [int]$InputPath } else { 1 }
        
        # Read the saved answers
        $answerFile = Join-Path (Get-Location).Path "answers\$Year\submit_day$Day.txt"
        if (-not (Test-Path $answerFile)) {
            Write-Host "No saved answers found for Day $Day!" -ForegroundColor Red
            exit 1
        }
        
        $answer = $null
        foreach ($line in (Get-Content $answerFile)) {
            if ($line -match "^Part$part`:" ) {
                if ($line -match "^Part$part`:(.*?)(\s*\[Status\:|\s*$)") {
                    $answer = $Matches[1].Trim()
                }
                break
            }
        }
        
        if ($answer) {
            SubmitAnswer -Year $Year -Day $Day -Part $part -Answer $answer
        }
        else {
            Write-Host "No answer found for Part $part!" -ForegroundColor Red
        }
    }
    "check" {
        if (-not $Day) {
            Write-Host "Please specify a day!" -ForegroundColor Red
            exit 1
        }
        $status = CheckSubmissionStatus -Year $Year -Day $Day
        
        if ($status.Available) {
            # Output status in same format as Makefile
            Write-Host "[Year ${Year} Day ${Day}]" -ForegroundColor Cyan
            Write-Host "Part 1: " -NoNewline
            if ($status.Part1) {
                Write-Host "✓" -ForegroundColor Green -NoNewline
                Write-Host " complete"
            }
            else {
                Write-Host "✗" -ForegroundColor Red -NoNewline
                Write-Host " incomplete"
            }
            Write-Host "Part 2: " -NoNewline
            if ($status.Part2) {
                Write-Host "✓" -ForegroundColor Green -NoNewline
                Write-Host " complete"
            }
            else {
                Write-Host "✗" -ForegroundColor Red -NoNewline
                Write-Host " incomplete"
            }
        }
    }
    "run-submit" {
        if (-not $Day) {
            Write-Host "Please specify a day!" -ForegroundColor Red
            exit 1
        }
        
        # If inputPath is "download", get the input from AoC
        if ($InputPath -eq "download") {
            $downloadedInput = DownloadPuzzleInput -Year $Year -Day $Day
            if ($downloadedInput) {
                $InputPath = $downloadedInput
            }
            else {
                exit 1
            }
        }
        
        # Run the solution
        $day = PadDayNumber $Day
        $dayDir = "$Year/day$day"
        
        if (-not (Test-Path $dayDir -PathType Container)) {
            Write-Host "Day $day does not exist!" -ForegroundColor Red
            exit 1
        }
        
        # Create answers directory
        $OutputDir = Join-Path (Get-Location).Path "answers\$Year"
        if (-not (Test-Path $OutputDir -PathType Container)) {
            New-Item -Path $OutputDir -ItemType Directory -Force | Out-Null
        }
        $answerFile = Join-Path $OutputDir "submit_day$day.txt"
        
        # Run the solution and capture output
        Write-Host "Running day $day with input $InputPath..." -ForegroundColor Cyan
        
        # Run in current PowerShell and capture output
        Push-Location $dayDir
        cargo build --release
        Pop-Location
        
        # Get the binary path (workspace or day-specific)
        $dayName = "day$day"
        $exePath = Join-Path (Get-Location).Path "target\release\$dayName.exe"
        if (-not (Test-Path $exePath)) {
            $exePath = Join-Path (Join-Path $dayDir "target\release") "$dayName.exe"
            if (-not (Test-Path $exePath)) {
                Write-Host "Could not find executable for day $day" -ForegroundColor Red
                exit 1
            }
        }
        
        # Capture output by running the command and storing its output
        $outputCapture = Get-Content $InputPath | & $exePath
        
        # Display the output
        $outputCapture | ForEach-Object { Write-Host $_ }
        
        # Extract the answers using regex
        $answers = @{}
        $outputString = $outputCapture -join "`n"
        if ($outputString -match "Part 1`:\s*([0-9a-zA-Z]+)") {
            $answers.Part1 = $Matches[1].Trim()
        }
        if ($outputString -match "Part 2`:\s*([0-9a-zA-Z]+)") {
            $answers.Part2 = $Matches[1].Trim()
        }
        
        # Save answers
        $answerContent = @()
        if ($answers.Part1) { $answerContent += "Part1: $($answers.Part1)" }
        if ($answers.Part2) { $answerContent += "Part2: $($answers.Part2)" }
        
        if ($answerContent.Count -gt 0) {
            $answerContent | Set-Content $answerFile
            Write-Host "Answers saved to $answerFile" -ForegroundColor Green
            
            # Check submission status
            $status = CheckSubmissionStatus -Year $Year -Day $Day
            # Prompt to submit answers
            if ($answers.Part1 -and -not $status.Part1) {
                $submitPart1 = Read-Host "Do you want to submit Part 1 answer? (y/n)"
                if ($submitPart1 -eq "y") {
                    $result = SubmitAnswer -Year $Year -Day $Day -Part 1 -Answer $answers.Part1
                    
                    # If Part 1 was successfully submitted, check status again and try Part 2
                    if ($result -eq $true -and $answers.Part2) {
                        # Brief pause to allow website to update
                        Start-Sleep -Seconds 1
                        
                        # Refresh status after Part 1 submission
                        $status = CheckSubmissionStatus -Year $Year -Day $Day
                        
                        if (-not $status.Part2) {
                            $submitPart2 = Read-Host "Do you want to submit Part 2 answer? (y/n)"
                            if ($submitPart2 -eq "y") {
                                SubmitAnswer -Year $Year -Day $Day -Part 2 -Answer $answers.Part2
                            }
                        }
                    }
                }
            }
            elseif ($answers.Part2 -and -not $status.Part2 -and $status.Part1) {
                $submitPart2 = Read-Host "Do you want to submit Part 2 answer? (y/n)"
                if ($submitPart2 -eq "y") {
                    SubmitAnswer -Year $Year -Day $Day -Part 2 -Answer $answers.Part2
                }
            }
        }
        else {
            Write-Host "Could not extract answers from output" -ForegroundColor Red
        }
    }
    "force-submit" {
        if (-not $Day) {
            Write-Host "Please specify a day!" -ForegroundColor Red
            exit 1
        }
        
        $part = if ($InputPath) { [int]$InputPath } else { 1 }
        
        # Read the saved answers
        $answerFile = Join-Path (Get-Location).Path "answers\$Year\submit_day$Day.txt"
        if (-not (Test-Path $answerFile)) {
            Write-Host "No saved answers found for Day $Day!" -ForegroundColor Red
            exit 1
        }
        
        $answer = $null
        foreach ($line in (Get-Content $answerFile)) {
            if ($line -match "^Part$part`:" ) {
                if ($line -match "^Part$part`:(.*?)(\s*\[Status\:|\s*$)") {
                    $answer = $Matches[1].Trim()
                }
                break
            }
        }
        
        if ($answer) {
            # Directly submit without checking submission status
            Write-Host "Force submitting answer for Year ${Year} Day ${Day} Part ${part}: ${answer}" -ForegroundColor Cyan
            
            # Get session token
            $SessionToken = GetSessionToken
            
            try {
                $day = PadDayNumber $Day
                $dayNum = [int]$day
                
                $url = "https://adventofcode.com/$Year/day/$dayNum/answer"
                $headers = @{
                    "Cookie"     = "session=$SessionToken"
                    "User-Agent" = "github.com/advent-of-code-rust"
                }
                $formData = @{
                    "level"  = $part
                    "answer" = $answer
                }
                
                $response = Invoke-WebRequest -Uri $url -Method Post -Headers $headers -Body $formData -UseBasicParsing
                
                # Parse the response to determine if the answer was correct
                $content = $response.Content
                
                if ($content -match "That's the right answer") {
                    Write-Host "Correct answer! Well done." -ForegroundColor Green
                    # Update status in answers file
                    UpdateAnswerStatus -Year $Year -Day $day -Part $part -Status "Correct"
                }
                elseif ($content -match "You gave an answer too recently") {
                    # Extract the time to wait
                    if ($content -match "You have ([0-9]+m [0-9]+s) left to wait") {
                        $waitTime = $Matches[1]
                        Write-Host "You need to wait $waitTime before submitting again." -ForegroundColor Yellow
                    }
                    else {
                        Write-Host "You need to wait before submitting again." -ForegroundColor Yellow
                    }
                }
                elseif ($content -match "That's not the right answer") {
                    if ($content -match "your answer is too (high|low)") {
                        $direction = $Matches[1]
                        Write-Host "Incorrect answer. Your answer is too $direction." -ForegroundColor Red
                    }
                    else {
                        Write-Host "Incorrect answer." -ForegroundColor Red
                    }
                    # Update status in answers file
                    UpdateAnswerStatus -Year $Year -Day $day -Part $part -Status "Incorrect"
                }
                elseif ($content -match "You don't seem to be solving the right level") {
                    Write-Host "You've already solved this part or are not on this level yet." -ForegroundColor Yellow
                }
                else {
                    Write-Host "Unexpected response from Advent of Code. Please check manually." -ForegroundColor Red
                }
            }
            catch {
                Write-Host "Error submitting answer: $_" -ForegroundColor Red
            }
        }
        else {
            Write-Host "No answer found for Part $part!" -ForegroundColor Red
        }
    }
    default {
        Write-Host "Unknown command: $Command" -ForegroundColor Red
        ShowHelp
        exit 1
    }
}
