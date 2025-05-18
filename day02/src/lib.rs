/// Creates pairs of adjacent elements in a vector
pub fn pairwise(lst: &[i32]) -> Vec<(i32, i32)> {
    lst.windows(2).map(|w| (w[0], w[1])).collect()
}

/// Checks if a report is safe according to the safety criteria
pub fn is_safe(report: &[i32]) -> bool {
    let pairs = pairwise(report);

    // Check if all pairs are increasing or all pairs are decreasing
    let all_increasing = pairs.iter().all(|(x, y)| x > y);
    let all_decreasing = pairs.iter().all(|(x, y)| x < y);

    // Check if absolute difference is between 1 and 3 inclusive
    let all_valid_diff = pairs.iter().all(|(x, y)| {
        let diff = (x - y).abs();
        diff >= 1 && diff <= 3
    });

    (all_increasing || all_decreasing) && all_valid_diff
}

/// Removes element at specified index from a vector
pub fn remove_at(n: usize, lst: &[i32]) -> Vec<i32> {
    lst.iter()
        .enumerate()
        .filter(|&(i, _)| i != n)
        .map(|(_, &x)| x)
        .collect()
}

/// Part 1: Count the number of safe reports
pub fn part1(reports: &[Vec<i32>]) -> usize {
    reports.iter().filter(|report| is_safe(report)).count()
}

/// Part 2: Count reports that can become safe by removing one element
pub fn part2(reports: &[Vec<i32>]) -> usize {
    reports
        .iter()
        .filter(|report| (0..report.len()).any(|i| is_safe(&remove_at(i, report))))
        .count()
}

/// Parse function to convert string input to a vector of integer vectors
pub fn parse(input: &str) -> Vec<Vec<i32>> {
    input
        .lines()
        .filter(|line| !line.trim().is_empty())
        .map(|line| {
            line.split_whitespace()
                .map(|s| s.parse::<i32>().unwrap())
                .collect()
        })
        .collect()
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
        let reports = parse(EXAMPLE_INPUT);
        assert_eq!(part1(&reports), 2);
    }

    #[test]
    fn test_part2() {
        let reports = parse(EXAMPLE_INPUT);
        assert_eq!(part2(&reports), 4);
    }
}
