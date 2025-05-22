/// Parses the input string into a vector of equations
/// Each equation is represented as a tuple of (target_value, operands)
fn parse_input(input: &str) -> Vec<(u64, Vec<u64>)> {
    input
        .lines()
        .filter(|line| !line.trim().is_empty())
        .map(|line| {
            let parts: Vec<&str> = line.split(':').collect();
            if parts.len() != 2 {
                panic!("Invalid input format");
            }

            let target_value = parts[0].trim().parse::<u64>().unwrap();
            let operands = parts[1]
                .split_whitespace()
                .map(|s| s.parse::<u64>().unwrap())
                .collect();

            (target_value, operands)
        })
        .collect()
}

pub fn part1(input: &str) -> u64 {
    let equations = parse_input(input);

    equations
        .into_iter()
        .filter(|(target, operands)| {
            if operands.is_empty() {
                return false;
            }

            // Start with the first operand
            let mut results = vec![operands[0]];

            // Process remaining operands
            for &operand in &operands[1..] {
                let mut new_results = Vec::new();

                for &result in &results {
                    // Addition
                    new_results.push(result + operand);
                    // Multiplication
                    new_results.push(result * operand);
                }

                results = new_results;
            }

            // Check if target is in results
            results.contains(target)
        })
        .map(|(target, _)| target)
        .sum()
}

pub fn part2(input: &str) -> u64 {
    let equations = parse_input(input);

    equations
        .into_iter()
        .filter(|(target, operands)| {
            if operands.is_empty() {
                return false;
            }

            // Start with the first operand
            let mut results = vec![operands[0]];

            // Process remaining operands
            for &operand in &operands[1..] {
                let mut new_results = Vec::new();

                for &result in &results {
                    // Addition
                    new_results.push(result + operand);
                    // Multiplication
                    new_results.push(result * operand);
                    // Concatenation
                    let concat_value = format!("{}{}", result, operand).parse::<u64>().unwrap();
                    new_results.push(concat_value);
                }

                results = new_results;
            }

            // Check if target is in results
            results.contains(target)
        })
        .map(|(target, _)| target)
        .sum()
}

#[cfg(test)]
mod tests {
    use super::*;

    const EXAMPLE_INPUT: &str = "190: 10 19
3267: 81 40 27
83: 17 5
156: 15 6
7290: 6 8 6 15
161011: 16 10 13
192: 17 8 14
21037: 9 7 18 13
292: 11 6 16 20";

    #[test]
    fn test_part1() {
        assert_eq!(part1(EXAMPLE_INPUT), 3749);
    }

    #[test]
    fn test_part2() {
        assert_eq!(part2(EXAMPLE_INPUT), 11387);
    }
}
