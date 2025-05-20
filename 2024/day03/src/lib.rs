use std::str::Chars;

/// Represents a multiplication instruction
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct Instruction {
    first: u64,
    second: u64,
    enabled: bool,
}

impl Instruction {
    /// Create a new instruction
    fn new(first: u64, second: u64, enabled: bool) -> Self {
        Self {
            first,
            second,
            enabled,
        }
    }

    /// Returns the result of the multiplication
    fn result(&self) -> u64 {
        self.first * self.second
    }
}

/// Check if a sequence of characters matches the expected pattern
fn chars_match_seq(chars: &mut Chars, pattern: &str) -> bool {
    let mut chars_copy = chars.clone();
    for expected in pattern.chars() {
        match chars_copy.next() {
            Some(c) if c == expected => {}
            _ => return false,
        }
    }

    // Consume the matched characters from the original iterator
    for _ in 0..pattern.len() {
        chars.next();
    }

    true
}

/// Parse mul instruction parameters (x,y)
fn parse_mul_params(chars: &mut Chars) -> Option<(u64, u64)> {
    let first = parse_number(chars)?;

    // Expect a comma after the first number
    if chars.next() != Some(',') {
        return None;
    }

    let second = parse_number(chars)?;

    // Expect a closing parenthesis
    if chars.next() != Some(')') {
        return None;
    }

    Some((first, second))
}

/// Parse a 1-3 digit number
fn parse_number(chars: &mut Chars) -> Option<u64> {
    let mut num_str = String::with_capacity(3);
    let chars_copy = chars.clone();

    // Collect 1-3 digits
    for c in chars_copy {
        if c.is_ascii_digit() {
            num_str.push(c);
            if num_str.len() >= 3 {
                break;
            }
        } else {
            break;
        }
    }

    if num_str.is_empty() {
        return None;
    }

    // Consume the digits from the original iterator
    for _ in 0..num_str.len() {
        chars.next();
    }

    num_str.parse::<u64>().ok()
}

/// Parse the input to extract valid multiplication instructions
pub fn parse_instructions(input: &str, handle_conditionals: bool) -> Vec<Instruction> {
    let mut instructions = Vec::new();
    let mut chars = input.chars();
    let mut enabled = true; // Instructions start enabled

    while let Some(ch) = chars.next() {
        match ch {
            'm' if chars_match_seq(&mut chars, "ul(") => {
                if let Some((first, second)) = parse_mul_params(&mut chars) {
                    instructions.push(Instruction::new(first, second, enabled));
                }
            }
            'd' if handle_conditionals
                && chars_match_seq(&mut chars, "o(")
                && chars.next() == Some(')') =>
            {
                enabled = true;
            }
            'd' if handle_conditionals
                && chars_match_seq(&mut chars, "on't(")
                && chars.next() == Some(')') =>
            {
                enabled = false;
            }
            _ => {} // Skip other characters
        }
    }

    instructions
}

/// Part 1: Find valid multiplications in corrupted memory and sum their results
pub fn part1(input: &str) -> u64 {
    parse_instructions(input, false)
        .iter()
        .map(|instr| instr.result())
        .sum()
}

/// Part 2: Find valid multiplications in corrupted memory with do/don't controls
pub fn part2(input: &str) -> u64 {
    parse_instructions(input, true)
        .iter()
        .filter(|instr| instr.enabled)
        .map(|instr| instr.result())
        .sum()
}

#[cfg(test)]
mod tests {
    use super::*;

    const EXAMPLE_INPUT_1: &str =
        "xmul(2,4)%&mul[3,7]!@^do_not_mul(5,5)+mul(32,64]then(mul(11,8)mul(8,5))";
    const EXAMPLE_INPUT_2: &str =
        "xmul(2,4)&mul[3,7]!^don't()_mul(5,5)+mul(32,64](mul(11,8)undo()?mul(8,5))";

    #[test]
    fn test_part1() {
        assert_eq!(part1(EXAMPLE_INPUT_1), 161);
    }

    #[test]
    fn test_part2() {
        assert_eq!(part2(EXAMPLE_INPUT_2), 48);
    }

    #[test]
    fn test_parse_instructions() {
        let instructions = parse_instructions("mul(2,4)", false);
        assert_eq!(instructions.len(), 1);
        assert_eq!(instructions[0].first, 2);
        assert_eq!(instructions[0].second, 4);
        assert_eq!(instructions[0].result(), 8);

        // Test with invalid characters
        let instructions = parse_instructions("mul(2,x)", false);
        assert_eq!(instructions.len(), 0);

        // Test with missing closing parenthesis
        let instructions = parse_instructions("mul(2,4", false);
        assert_eq!(instructions.len(), 0);
    }
}
