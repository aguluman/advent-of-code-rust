/// Checks if a report is safe, according to the safety criteria,
/// Optimized version that doesn't create intermediate collections
pub fn is_safe(report: &[i32]) -> bool {
    if report.len() < 2 {
        return false; // Not enough elements to form pairs
    }

    // Check the first pair to determine if we're looking for increasing or decreasing
    let first_increasing = report[0] > report[1];

    // Initialize to match the expected pattern (all increasing or all decreasing)
    let mut valid_direction = true;

    // Check all pairs in one pass
    for i in 0..report.len() - 1 {
        let curr = report[i];
        let next = report[i + 1];

        let is_curr_pair_increasing = curr > next;

        // Direction check - all must be increasing or all decreasing
        if is_curr_pair_increasing != first_increasing {
            valid_direction = false;
            break;
        }

        // Difference check - must be between 1 and 3 inclusive
        let diff = (curr - next).abs();
        if !(1..=3).contains(&diff) {
            return false;
        }
    }

    valid_direction
}

/// Check if removing one element can make the report safe
/// Uses a more efficient approach by avoiding repeated allocations
fn can_be_made_safe(report: &[i32]) -> bool {
    if report.len() < 3 {
        return false; // Need at least 3 elements to remove 1 and have a valid pair
    }

    for skip_idx in 0..report.len() {
        // Create a temporary buffer to check safety without allocating multiple times
        let mut temp_report = Vec::with_capacity(report.len() - 1);

        for (i, &val) in report.iter().enumerate() {
            if i != skip_idx {
                temp_report.push(val);
            }
        }

        if is_safe(&temp_report) {
            return true;
        }
    }

    false
}

/// Part 1: Count the number of safe reports
pub fn part1(input: &str) -> usize {
    let reports = parse(input);
    reports.iter().filter(|report| is_safe(report)).count()
}

/// Part 2: Count reports that can become safe by removing one element
pub fn part2(input: &str) -> usize {
    let reports = parse(input);
    reports
        .iter()
        .filter(|report| can_be_made_safe(report))
        .count()
}

/// Parse function to convert string input to a vector of integer vectors
/// Uses pre-allocation for better performance
pub fn parse(input: &str) -> Vec<Vec<i32>> {
    // Pre-count the number of lines for capacity planning
    let line_count = input.lines().filter(|line| !line.trim().is_empty()).count();
    let mut result = Vec::with_capacity(line_count);

    for line in input.lines().filter(|line| !line.trim().is_empty()) {
        // Estimate the number of numbers in this line based on whitespace
        let num_count = line.split_whitespace().count();
        let mut nums = Vec::with_capacity(num_count);

        for s in line.split_whitespace() {
            // Use unwrap_or for safety but maintain performance
            if let Ok(num) = s.parse::<i32>() {
                nums.push(num);
            }
        }

        result.push(nums);
    }

    result
}

#[cfg(test)]
mod tests {
    use super::*;

    const EXAMPLE_INPUT: &str = "7 6 4 2 1
1 2 7 8 9
9 7 6 2 1
1 3 2 4 5
8 6 4 4 1
1 3 6 7 9";

    #[test]
    fn test_part1() {
        assert_eq!(part1(EXAMPLE_INPUT), 2);
    }

    #[test]
    fn test_part2() {
        assert_eq!(part2(EXAMPLE_INPUT), 4);
    }
}
