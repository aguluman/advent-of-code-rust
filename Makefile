.PHONY: all build test release lint clean setup new-day run-day help benchmark clippy fmt check run-release

# Default target
all: test lint

# Variables
DAYS := $(wildcard day*)
CURRENT_DAY := $(shell ls -d day* | sort -r | head -n 1)

# Build all days in debug mode
build:
	@echo "Building all days..."
	@for day in $(DAYS); do \
		echo "Building $$day..."; \
		cd $$day && cargo build && cd ..; \
	done

# Build a specific day
build-%:
	@echo "Building day $*..."
	@cd day$* && cargo build

# Build all days in release mode
release:
	@echo "Building all days in release mode..."
	@for day in $(DAYS); do \
		echo "Building $$day in release mode..."; \
		cd $$day && cargo build --release && cd ..; \
	done

# Run tests for all days
test:
	@echo "Running tests for all days..."
	@for day in $(DAYS); do \
		echo "Testing $$day..."; \
		cd $$day && cargo test && cd ..; \
	done

# Run tests for a specific day
test-%:
	@echo "Testing day $*..."
	@cd day$* && cargo test

# Lint all days
lint: clippy fmt-check

# Run clippy on all days
clippy:
	@echo "Running clippy on all days..."
	@for day in $(DAYS); do \
		echo "Linting $$day with clippy..."; \
		cd $$day && cargo clippy --all-targets --all-features -- -D warnings && cd ..; \
	done

# Format all code
fmt:
	@echo "Formatting code for all days..."
	@for day in $(DAYS); do \
		echo "Formatting $$day..."; \
		cd $$day && cargo fmt && cd ..; \
	done

# Check formatting for all code
fmt-check:
	@echo "Checking formatting for all days..."
	@for day in $(DAYS); do \
		echo "Checking formatting for $$day..."; \
		cd $$day && cargo fmt -- --check && cd ..; \
	done

# Run code checks
check:
	@echo "Running cargo check for all days..."
	@for day in $(DAYS); do \
		echo "Checking $$day..."; \
		cd $$day && cargo check && cd ..; \
	done

# Run benchmarks using criterion
benchmark:
	@echo "Running benchmarks for all days..."
	@for day in $(DAYS); do \
		echo "Benchmarking $$day..."; \
		cd $$day && cargo bench && cd ..; \
	done

# Clean all build artifacts
clean:
	@echo "Cleaning build artifacts..."
	@for day in $(DAYS); do \
		echo "Cleaning $$day..."; \
		cd $$day && cargo clean && cd ..; \
	done

# Create a new day from template
new-day:
	@read -p "Enter day number (e.g., 04): " day; \
	if [ -d "day$$day" ]; then \
		echo "day$$day already exists!"; \
		exit 1; \
	fi; \
	echo "Creating day$$day..."; \
	mkdir -p "day$$day/src"; \
	cp -r templates/day_template/* "day$$day/"; \
	sed -i "s/day_template/day$$day/g" "day$$day/Cargo.toml"; \
	echo "Created day$$day successfully!"

# Setup project from scratch
setup:
	@echo "Setting up project..."
	@if [ ! -d "templates" ]; then \
		echo "Creating templates directory..."; \
		mkdir -p templates/day_template/src; \
		echo '[package]\nname = "day_template"\nversion = "0.1.0"\nedition = "2024"\n\n[dependencies]' > templates/day_template/Cargo.toml; \
		echo '// main.rs template\nuse day_template::{part1, part2};\nuse std::io::{self, Read};\nuse std::time::Instant;\n\nfn main() {\n    // Read input from stdin\n    let mut input = String::new();\n    io::stdin().read_to_string(&mut input).unwrap();\n    let input = input.trim();\n\n    let start_time = Instant::now();\n\n    println!("Part 1: {}", part1(input));\n    println!("Part 2: {}", part2(input));\n\n    let elapsed = start_time.elapsed();\n    println!("Elapsed time: {:.4} seconds", elapsed.as_secs_f64());\n}' > templates/day_template/src/main.rs; \
		echo '// lib.rs template\n\npub fn part1(input: &str) -> u64 {\n    // TODO: Implement part 1\n    0\n}\n\npub fn part2(input: &str) -> u64 {\n    // TODO: Implement part 2\n    0\n}\n\n#[cfg(test)]\nmod tests {\n    use super::*;\n\n    const EXAMPLE_INPUT: &str = "";\n\n    #[test]\n    fn test_part1() {\n        assert_eq!(part1(EXAMPLE_INPUT), 0);\n    }\n\n    #[test]\n    fn test_part2() {\n        assert_eq!(part2(EXAMPLE_INPUT), 0);\n    }\n}' > templates/day_template/src/lib.rs; \
	fi

# Run a specific day with input file
run-day:
	@if [ -z "$(DAY)" ]; then \
		echo "Please specify a day with DAY=XX"; \
		exit 1; \
	fi; \
	if [ -z "$(INPUT)" ]; then \
		echo "Please specify an input file with INPUT=path/to/input.txt"; \
		exit 1; \
	fi; \
	echo "Running day$(DAY) with input $(INPUT)..."; \
	cd day$(DAY) && cargo run < $(INPUT)

# Run a specific day with input file in release mode
run-release:
	@if [ -z "$(DAY)" ]; then \
		echo "Please specify a day with DAY=XX"; \
		exit 1; \
	fi
	@if [ -z "$(INPUT)" ]; then \
		echo "Please specify an input file with INPUT=path/to/input.txt"; \
		exit 1; \
	fi
	@if [ "$(INPUT)" = "puzzle_input" ]; then \
		if [ -d "/mnt/c" ]; then \
			INPUT_PATH="/mnt/c/Users/chukw/Downloads/input.txt"; \
		elif [ "$(shell uname -s)" = "Linux" ]; then \
			INPUT_PATH="$(HOME)/Downloads/input.txt"; \
		else \
			INPUT_PATH="C:/Users/chukw/Downloads/input.txt"; \
		fi; \
	else \
		INPUT_PATH="$(INPUT)"; \
	fi; \
	echo "Building and running day$(DAY) in release mode with input $$INPUT_PATH..."; \
	cd day$(DAY) && cargo build --release && \
	if [ "$(shell uname -s)" = "Linux" ] || [ -d "/mnt/c" ]; then \
		cat "$$INPUT_PATH" | ../target/release/day$(DAY); \
	else \
		if command -v type >/dev/null 2>&1; then \
			type "$$INPUT_PATH" | ../target/release/day$(DAY).exe; \
		else \
			cat "$$INPUT_PATH" | ../target/release/day$(DAY).exe; \
		fi; \
	fi

# Run the current day (most recent) with input file
run-current:
	@if [ -z "$(INPUT)" ]; then \
		echo "Please specify an input file with INPUT=path/to/input.txt"; \
		exit 1; \
	fi
	@if [ "$(INPUT)" = "puzzle_input" ]; then \
		if [ -d "/mnt/c" ]; then \
			INPUT_PATH="/mnt/c/Users/chukw/Downloads/input.txt"; \
		elif [ "$(shell uname -s)" = "Linux" ]; then \
			INPUT_PATH="$(HOME)/Downloads/input.txt"; \
		else \
			INPUT_PATH="C:/Users/chukw/Downloads/input.txt"; \
		fi; \
	else \
		INPUT_PATH="$(INPUT)"; \
	fi; \
	echo "Running $(CURRENT_DAY) with input $$INPUT_PATH..."; \
	cd $(CURRENT_DAY) && cargo run < "$$INPUT_PATH"

# Show help
help:
	@echo "Advent of Code 2024 - Rust Makefile Help"
	@echo ""
	@echo "Available targets:"
	@echo "  all             : Run tests and linting (default)"
	@echo "  build           : Build all days in debug mode"
	@echo "  build-XX        : Build a specific day (e.g., build-01)"
	@echo "  release         : Build all days in release mode"
	@echo "  test            : Run tests for all days"
	@echo "  test-XX         : Run tests for a specific day (e.g., test-01)"
	@echo "  lint            : Run clippy and format check"
	@echo "  clippy          : Run clippy on all days"
	@echo "  fmt             : Format all code"
	@echo "  fmt-check       : Check formatting for all code"
	@echo "  check           : Run cargo check for all days"
	@echo "  benchmark       : Run benchmarks for all days"
	@echo "  clean           : Clean all build artifacts"
	@echo "  new-day         : Create a new day from template (interactive)"
	@echo "  setup           : Setup project from scratch"
	@echo "  run-day         : Run a specific day with input (DAY=XX INPUT=path/to/input.txt)"
	@echo "  run-release     : Build and run a specific day in release mode (DAY=XX INPUT=path/to/input.txt or INPUT=puzzle_input)"
	@echo "  run-current     : Run the current day with input (INPUT=path/to/input.txt)"
	@echo "  help            : Show this help message"
	@echo ""
	@echo "Examples:"
	@echo "  make build-01            # Build day01"
	@echo "  make test-03             # Run tests for day03"
	@echo "  make run-day DAY=02 INPUT=../inputs/day02.txt  # Run day02 with specified input"
	@echo "  make run-release DAY=01 INPUT=puzzle_input  # Build and run day01 in release mode with default input"
	@echo ""
