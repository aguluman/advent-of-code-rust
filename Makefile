.PHONY: all build test release lint clean setup new-day run-day help benchmark clippy fmt check run-release

# Default target
all: test lint

# Variables
YEAR := $(shell ls -d [0-9][0-9][0-9][0-9] | sort -r | head -n 1)
DAYS := $(wildcard $(YEAR)/day*)
CURRENT_DAY := $(shell ls -d $(YEAR)/day* 2>/dev/null | sort -r | head -n 1)

# Build all days in debug mode
build:
	@echo "Building all days..."
	@for day in $(DAYS); do \
		echo "Building $$day..."; \
		cd $$day && cargo build && cd ../..; \
	done

# Build a specific day
build-%:
	@echo "Building day $*..."
	@cd $(YEAR)/day$* && cargo build

# Build all days in release mode
release:
	@echo "Building all days in release mode..."
	@for day in $(DAYS); do \
		echo "Building $$day in release mode..."; \
		cd $$day && cargo build --release && cd ../..; \
	done

# Run tests for all days
test:
	@echo "Running tests for all days..."
	@for day in $(DAYS); do \
		echo "Testing $$day..."; \
		cd $$day && cargo test && cd ../..; \
	done

# Run tests for a specific day
test-%:
	@echo "Testing day $*..."
	@cd $(YEAR)/day$* && cargo test

# Lint all days
lint: clippy fmt-check

# Run clippy on all days
clippy:
	@echo "Running clippy on all days..."
	@for day in $(DAYS); do \
		echo "Linting $$day with clippy..."; \
		cd $$day && cargo clippy --all-targets --all-features -- -D warnings && cd ../..; \
	done

# Format all code
fmt:
	@echo "Formatting code for all days..."
	@for day in $(DAYS); do \
		echo "Formatting $$day..."; \
		cd $$day && cargo fmt && cd ../..; \
	done

# Check formatting for all code
fmt-check:
	@echo "Checking formatting for all days..."
	@for day in $(DAYS); do \
		echo "Checking formatting for $$day..."; \
		cd $$day && cargo fmt -- --check && cd ../..; \
	done

# Run code checks
check:
	@echo "Running cargo check for all days..."
	@for day in $(DAYS); do \
		echo "Checking $$day..."; \
		cd $$day && cargo check && cd ../..; \
	done

# Run benchmarks using criterion
benchmark:
	@echo "Running benchmarks for all days..."
	@for day in $(DAYS); do \
		echo "Benchmarking $$day..."; \
		cd $$day && cargo bench && cd ../..; \
	done

# Clean all build artifacts
clean:
	@echo "Cleaning build artifacts..."
	@for day in $(DAYS); do \
		echo "Cleaning $$day..."; \
		cd $$day && cargo clean && cd ../..; \
	done

# Create a new day from template
new-day:
	@read -p "Enter day number (e.g., 04): " day; \
	if [ -d "$(YEAR)/day$$day" ]; then \
		echo "$(YEAR)/day$$day already exists!"; \
		exit 1; \
	fi; \
	echo "Creating $(YEAR)/day$$day..."; \
	mkdir -p "$(YEAR)/day$$day/src"; \
	cp -r templates/day_template/* "$(YEAR)/day$$day/"; \
	sed -i "s/day_template/day$$day/g" "$(YEAR)/day$$day/Cargo.toml"; \
	echo "Updating workspace Cargo.toml..."; \
	sed -i '/# Add new days as they are created/i \    "$(YEAR)/day'$$day'",' Cargo.toml; \
	echo "Created $(YEAR)/day$$day successfully!"

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
		echo "Please specify a day number using DAY=XX"; \
		exit 1; \
	fi; \
	if [ -z "$(INPUT)" ]; then \
		echo "Please specify an input file using INPUT=path/to/input.txt"; \
		exit 1; \
	fi; \
	if [ ! -f "$(INPUT)" ]; then \
		echo "Input file not found: $(INPUT)"; \
		exit 1; \
	fi; \
	echo "Running day$(DAY) with input $(INPUT)..."; \
	cd $(YEAR)/day$(DAY) && cat $(PWD)/$(INPUT) | cargo run

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
		if [ ! -d "inputs/$(YEAR)" ]; then \
			echo "Notice: Repository inputs directory not found."; \
			echo "Creating directory: inputs/$(YEAR)"; \
			mkdir -p inputs/$(YEAR); \
			echo "Created inputs/$(YEAR) - You can now place your puzzle inputs there."; \
			echo "- Day-specific files: inputs/$(YEAR)/day01.txt, etc."; \
			echo "- Generic input file: inputs/$(YEAR)/input.txt"; \
		fi; \
		if [ -f "inputs/$(YEAR)/day$(DAY).txt" ]; then \
			INPUT_PATH="inputs/$(YEAR)/day$(DAY).txt"; \
			echo "Using day-specific input file: $$INPUT_PATH"; \
		elif [ -f "inputs/$(YEAR)/input.txt" ]; then \
			INPUT_PATH="inputs/$(YEAR)/input.txt"; \
			echo "Using generic input file: $$INPUT_PATH"; \
		elif [ -d "/mnt/c" ]; then \
			INPUT_PATH="/mnt/c/Users/chukw/Downloads/input.txt"; \
			echo "Using default download path: $$INPUT_PATH"; \
		elif [ "$(shell uname -s)" = "Linux" ]; then \
			INPUT_PATH="$(HOME)/Downloads/input.txt"; \
			echo "Using default download path: $$INPUT_PATH"; \
		else \
			INPUT_PATH="C:/Users/chukw/Downloads/input.txt"; \
			echo "Using default download path: $$INPUT_PATH"; \
		fi; \
	else \
		INPUT_PATH="$(INPUT)"; \
	fi; \
	echo "Building and running day$(DAY) in release mode with input $$INPUT_PATH..."; \
	cd $(YEAR)/day$(DAY) && cargo build --release && \
	if [ "$(shell uname -s)" = "Linux" ] || [ -d "/mnt/c" ]; then \
		cat "$$INPUT_PATH" | ../../target/release/day$(DAY); \
	else \
		if command -v type >/dev/null 2>&1; then \
			type "$$INPUT_PATH" | ../../target/release/day$(DAY).exe; \
		else \
			cat "$$INPUT_PATH" | ../../target/release/day$(DAY).exe; \
		fi; \
	fi

# Run the current day (most recent) with input file
run-current:
	@if [ -z "$(INPUT)" ]; then \
		echo "Please specify an input file with INPUT=path/to/input.txt"; \
		exit 1; \
	fi
	@if [ "$(INPUT)" = "puzzle_input" ]; then \
		DAY_NUM=$$(echo $(CURRENT_DAY) | sed 's/.*day//'); \
		if [ ! -d "inputs/$(YEAR)" ]; then \
			echo "Notice: Repository inputs directory not found."; \
			echo "Creating directory: inputs/$(YEAR)"; \
			mkdir -p inputs/$(YEAR); \
			echo "Created inputs/$(YEAR) - You can now place your puzzle inputs there."; \
		fi; \
		if [ -f "inputs/$(YEAR)/day$$DAY_NUM.txt" ]; then \
			INPUT_PATH="inputs/$(YEAR)/day$$DAY_NUM.txt"; \
			echo "Using day-specific input file: $$INPUT_PATH"; \
		elif [ -f "inputs/$(YEAR)/input.txt" ]; then \
			INPUT_PATH="inputs/$(YEAR)/input.txt"; \
			echo "Using generic input file: $$INPUT_PATH"; \
		elif [ -d "/mnt/c" ]; then \
			INPUT_PATH="/mnt/c/Users/chukw/Downloads/input.txt"; \
			echo "Using default download path: $$INPUT_PATH"; \
		elif [ "$(shell uname -s)" = "Linux" ]; then \
			INPUT_PATH="$(HOME)/Downloads/input.txt"; \
			echo "Using default download path: $$INPUT_PATH"; \
		else \
			INPUT_PATH="C:/Users/chukw/Downloads/input.txt"; \
			echo "Using default download path: $$INPUT_PATH"; \
		fi; \
	else \
		INPUT_PATH="$(INPUT)"; \
	fi; \
	echo "Running $(CURRENT_DAY) with input $$INPUT_PATH..."; \
	cd $(CURRENT_DAY) && cargo run < "$$INPUT_PATH"


# Download puzzle input
download:
	@if [ -z "$(DAY)" ]; then \
		echo "Please specify a day number using DAY=XX"; \
		exit 1; \
	fi; \
	echo "Downloading input for day $(DAY)..."; \
	mkdir -p inputs/$(YEAR); \
	if [ -f "inputs/$(YEAR)/day$(DAY).txt" ] && [ "$${FORCE:-}" != "1" ]; then \
		echo "Input file already exists. Use FORCE=1 to overwrite."; \
		exit 0; \
	fi; \
	SESSION_TOKEN=$$(grep AUTH_TOKEN .env | cut -d'=' -f2); \
	if [ -z "$$SESSION_TOKEN" ]; then \
		echo "No session token found in .env file. Please add AUTH_TOKEN=your_token"; \
		exit 1; \
	fi; \
	echo "Downloading from https://adventofcode.com/$(YEAR)/day/$$((10#$(DAY)))/input"; \
	curl -s --cookie "session=$$SESSION_TOKEN" \
		"https://adventofcode.com/$(YEAR)/day/$$((10#$(DAY)))/input" \
		-o "inputs/$(YEAR)/day$(DAY).txt"; \
	if [ $$? -eq 0 ]; then \
		echo "Successfully downloaded input to inputs/$(YEAR)/day$(DAY).txt"; \
	else \
		echo "Failed to download input"; \
		exit 1; \
	fi

# Check submission status
check-status:
	@if [ -z "$(DAY)" ]; then \
		echo "Please specify a day with DAY=XX"; \
		exit 1; \
	fi; \
	SESSION_TOKEN=$$(grep AUTH_TOKEN .env | cut -d'=' -f2); \
	if [ -z "$$SESSION_TOKEN" ]; then \
		echo "No session token found in .env file"; \
		exit 1; \
	fi; \
	echo "Checking status for day $(DAY)..."; \
	RESPONSE=$$(curl -s --cookie "session=$$SESSION_TOKEN" \
		"https://adventofcode.com/$(YEAR)/day/$$((10#$(DAY)))" \
		-H "User-Agent: github.com/advent-of-code-rust"); \
	if echo "$$RESPONSE" | grep -q "Both parts of this puzzle are complete! They provide two gold stars: \*\*"; then \
		echo "Part 1: Completed ✓"; \
		echo "Part 2: Completed ✓"; \
	elif echo "$$RESPONSE" | grep -q "one gold star: \*\|You have completed Part One"; then \
		echo "Part 1: Completed ✓"; \
		echo "Part 2: Not completed"; \
	else \
		echo "Part 1: Not completed"; \
		echo "Part 2: Not completed"; \
	fi

# Submit an answer (improved)
submit:
	@if [ -z "$(DAY)" ]; then \
		echo "Please specify a day with DAY=XX"; \
		exit 1; \
	fi; \
	if [ -z "$(PART)" ]; then \
		echo "Please specify a part with PART=1 or PART=2"; \
		exit 1; \
	fi; \
	ANSWER_FILE="answers/$(YEAR)/submit_day$(DAY).txt"; \
	if [ ! -f "$$ANSWER_FILE" ]; then \
		echo "No answers file found at $$ANSWER_FILE"; \
		exit 1; \
	fi; \
	ANSWER=$$(grep "^Part$(PART):" "$$ANSWER_FILE" | cut -d':' -f2 | sed 's/\[Status:.*\]//g' | tr -d ' ' | head -n1); \
	if [ -z "$$ANSWER" ]; then \
		echo "No answer found for Part $(PART)!"; \
		exit 1; \
	fi; \
	echo "Found answer for Day $(DAY) Part $(PART): $$ANSWER"; \
	SESSION_TOKEN=$$(grep AUTH_TOKEN .env | cut -d'=' -f2); \
	if [ -z "$$SESSION_TOKEN" ]; then \
		echo "No session token found in .env file!"; \
		exit 1; \
	fi; \
	if [ "$(PART)" = "2" ]; then \
		if grep -q "Part1:.*\[Status: Correct\]" "$$ANSWER_FILE"; then \
			echo "Found Part 1 marked as correct in answer file. Proceeding with Part 2 submission."; \
		else \
			echo "Checking Part 1 status..."; \
			RESPONSE=$$(curl -s --cookie "session=$$SESSION_TOKEN" \
				-H "User-Agent: github.com/advent-of-code-rust" \
				"https://adventofcode.com/$(YEAR)/day/$$((10#$(DAY)))"); \
			if echo "$$RESPONSE" | grep -q "You have completed Part One!"; then \
				echo "Part 1 is completed. Proceeding with Part 2 submission."; \
			else \
				echo "You need to complete Part 1 before submitting Part 2."; \
				exit 1; \
			fi; \
		fi; \
	fi; \
	echo "Submitting answer..."; \
	RESPONSE=$$(curl -s -X POST --cookie "session=$$SESSION_TOKEN" \
		-H "User-Agent: github.com/advent-of-code-rust" \
		-d "level=$(PART)&answer=$$ANSWER" \
		"https://adventofcode.com/$(YEAR)/day/$$((10#$(DAY)))/answer"); \
	if echo "$$RESPONSE" | grep -q "That's the right answer!"; then \
		echo "Correct answer! Well done."; \
		sed -i "s/^Part$(PART): $$ANSWER\(\s*\[Status:.*\]\)\?$$/Part$(PART): $$ANSWER [Status: Correct]/" "$$ANSWER_FILE"; \
	elif echo "$$RESPONSE" | grep -q "You gave an answer too recently"; then \
		if echo "$$RESPONSE" | grep -q "You have \([0-9]*m [0-9]*s\)"; then \
			WAIT_TIME=$$(echo "$$RESPONSE" | grep -o "You have [0-9]*m [0-9]*s" | cut -d' ' -f2-); \
			echo "You need to wait $$WAIT_TIME before submitting again."; \
		else \
			echo "You need to wait before submitting again."; \
		fi; \
	elif echo "$$RESPONSE" | grep -q "That's not the right answer"; then \
		if echo "$$RESPONSE" | grep -q "your answer is too \(high\|low\)"; then \
			DIRECTION=$$(echo "$$RESPONSE" | grep -o "too \(high\|low\)" | cut -d' ' -f2); \
			echo "Incorrect answer. Your answer is too $$DIRECTION."; \
		else \
			echo "Incorrect answer."; \
		fi; \
		sed -i "s/^Part$(PART): $$ANSWER\(\s*\[Status:.*\]\)\?$$/Part$(PART): $$ANSWER [Status: Incorrect]/" "$$ANSWER_FILE"; \
	elif echo "$$RESPONSE" | grep -q "You don't seem to be solving the right level"; then \
		echo "You've already solved this part or are not on this level yet."; \
	else \
		echo "Unexpected response. Please check manually."; \
	fi

# Run with auto-submission option
run-submit:
	@if [ -z "$(DAY)" ]; then \
		echo "Please specify a day number using DAY=XX"; \
		exit 1; \
	fi; \
	INPUT="$(INPUT)"; \
	if [ -z "$$INPUT" ]; then \
		echo "Please specify an input file using INPUT=path/to/input.txt or INPUT=download"; \
		exit 1; \
	fi; \
	if [ "$$INPUT" = "download" ]; then \
		$(MAKE) download DAY=$(DAY); \
		INPUT="inputs/$(YEAR)/day$(DAY).txt"; \
	fi; \
	if [ ! -f "$$INPUT" ]; then \
		echo "Input file not found: $$INPUT"; \
		exit 1; \
	fi; \
	mkdir -p answers/$(YEAR); \
	ANSWER_FILE="answers/$(YEAR)/submit_day$(DAY).txt"; \
	echo "Running day$(DAY) with input $$INPUT..."; \
	OUTPUT=$$(cd $(YEAR)/day$(DAY) && cat $(PWD)/$$INPUT | cargo run --release); \
	echo "$$OUTPUT"; \
	PART1=$$(echo "$$OUTPUT" | grep "Part 1:" | cut -d':' -f2 | tr -d ' '); \
	PART2=$$(echo "$$OUTPUT" | grep "Part 2:" | cut -d':' -f2 | tr -d ' '); \
	if [ ! -z "$$PART1" ]; then \
		echo "Part1: $$PART1" > "$$ANSWER_FILE"; \
	fi; \
	if [ ! -z "$$PART2" ]; then \
		echo "Part2: $$PART2" >> "$$ANSWER_FILE"; \
	fi; \
	echo "Answers saved to $$ANSWER_FILE"; \
	echo "Checking submission status..."

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
	@echo "  make download DAY=XX         : Download puzzle input for day XX"
	@echo "  make check-status DAY=XX     : Check submission status for day XX"
	@echo "  make submit DAY=XX PART=P    : Submit answer for day XX part P (1 or 2)"
	@echo "  make run-submit DAY=XX INPUT=path : Run day XX and prompt to submit answers"
	@echo "  make run-submit DAY=XX INPUT=download : Download input, run day XX, and prompt to submit"
	@echo "  help            : Show this help message"
	@echo ""
	@echo "Examples:"
	@echo "  make build-01            # Build day01"
	@echo "  make test-03             # Run tests for day03"
	@echo "  make run-day DAY=02 INPUT=../inputs/day02.txt  # Run day02 with specified input"
	@echo "  make run-release DAY=01 INPUT=puzzle_input  # Build and run day01 in release mode with default input"
	@echo ""
