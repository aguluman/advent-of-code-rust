@echo off
REM run-aoc.bat - Helper script for Advent of Code Rust solutions
REM Usage: run-aoc.bat DAY [INPUT_PATH]

setlocal enabledelayedexpansion

REM Find the most recent year folder
set YEAR=
for /d %%Y in (20??) do (
    if "!YEAR!"=="" (
        set YEAR=%%Y
    ) else (
        if %%Y GTR !YEAR! (
            set YEAR=%%Y
        )
    )
)

if "!YEAR!"=="" (
    echo No year directories found. Please create a directory like 2024 first.
    exit /b 1
)

echo Using year: !YEAR!

REM Check if day parameter is provided
if "%1"=="" (
    echo Please provide a day number
    echo Usage: run-aoc.bat DAY [INPUT_PATH]
    exit /b 1
)

set DAY=%1
set DAY_DIR=!YEAR!\day%DAY%
set INPUT_PATH=%2

REM If INPUT_PATH is "puzzle_input", use repository input paths or default
if "%INPUT_PATH%"=="puzzle_input" (
    set REPO_INPUT_DIR=%CD%\inputs\!YEAR!
    set DAY_SPECIFIC_INPUT=%REPO_INPUT_DIR%\day%DAY%.txt
    set GENERIC_INPUT=%REPO_INPUT_DIR%\input.txt
    
    REM Check if repository inputs directory exists, if not create it
    if not exist "%REPO_INPUT_DIR%" (
        echo Notice: Repository inputs directory not found.
        echo Creating directory: %REPO_INPUT_DIR%
        mkdir "%REPO_INPUT_DIR%" 2>nul
        echo Created %REPO_INPUT_DIR% - You can now place your puzzle inputs there.
        echo - Day-specific files: %REPO_INPUT_DIR%\day01.txt, etc.
        echo - Generic input file: %REPO_INPUT_DIR%\input.txt
    )
    
    if exist "%DAY_SPECIFIC_INPUT%" (
        echo Using day-specific input file: %DAY_SPECIFIC_INPUT%
        set INPUT_PATH=%DAY_SPECIFIC_INPUT%
    ) else if exist "%GENERIC_INPUT%" (
        echo Using generic input file: %GENERIC_INPUT%
        set INPUT_PATH=%GENERIC_INPUT%
    ) else (
        echo No input files found in repository. Using default path.
        set INPUT_PATH=C:\Users\chukw\Downloads\input.txt
    )
)

REM Default to fixed input path if no input is provided
if "%INPUT_PATH%"=="" (
    REM You can change this to your specific puzzle input path
    set INPUT_PATH=C:\Users\chukw\Downloads\input.txt
)

REM Check if the day directory exists
if not exist "%DAY_DIR%" (
    echo Day %DAY% does not exist
    exit /b 1
)

echo Building and running day%DAY% in release mode with input %INPUT_PATH%...
cd %DAY_DIR% && cargo build --release && type "%INPUT_PATH%" | ..\..\target\release\day%DAY%.exe

exit /b 0
