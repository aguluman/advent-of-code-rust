@echo off
REM run-aoc.bat - Helper script for Advent of Code 2024 Rust solutions
REM Usage: run-aoc.bat DAY [INPUT_PATH]

setlocal enabledelayedexpansion

REM Check if day parameter is provided
if "%1"=="" (
    echo Please provide a day number
    echo Usage: run-aoc.bat DAY [INPUT_PATH]
    exit /b 1
)

set DAY=%1
set DAY_DIR=day%DAY%
set INPUT_PATH=%2

REM If INPUT_PATH is "puzzle_input", use the fixed input path
if "%INPUT_PATH%"=="puzzle_input" (
    set INPUT_PATH=C:\Users\chukw\Downloads\input.txt
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
cd %DAY_DIR% && cargo build --release && type "%INPUT_PATH%" | .\target\release\day%DAY%.exe

exit /b 0
