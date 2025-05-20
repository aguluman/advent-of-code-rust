use std::collections::HashMap;

/// Part 1: Sum absolute differences between sorted lists
pub fn part1(input: &str) -> i32 {
    let location_ids = parse(input);
    let (mut lefts, mut rights): (Vec<_>, Vec<_>) = location_ids.iter().cloned().unzip();
    lefts.sort_unstable();
    rights.sort_unstable();

    lefts
        .iter()
        .zip(rights.iter())
        .map(|(l, r)| (l - r).abs())
        .sum()
}

/// Part 2: Calculate weighted sum based on frequency counter
pub fn part2(input: &str) -> i64 {
    let location_ids = parse(input);
    let left: Vec<i32> = location_ids.iter().map(|&(l, _)| l).collect();
    let right: Vec<i32> = location_ids.iter().map(|&(_, r)| r).collect();

    // Create a frequency counter map for right elements
    let mut counter: HashMap<i32, i32> = HashMap::new();
    for &r in &right {
        *counter.entry(r).or_insert(0) += 1;
    }

    // Sum left elements multiplied by their frequency in right
    left.iter().fold(0i64, |acc, &l| {
        let count = *counter.get(&l).unwrap_or(&0);
        acc + (l as i64 * count as i64)
    })
}

/// Parse function to convert string input to a vector of integer pairs
pub fn parse(input: &str) -> Vec<(i32, i32)> {
    input
        .lines()
        .filter(|line| !line.trim().is_empty())
        .filter_map(|line| {
            let parts: Vec<&str> = line.split_whitespace().collect();
            if parts.len() < 2 {
                return None;
            }

            let first = parts[0].parse::<i32>().ok()?;
            let second = parts[1].parse::<i32>().ok()?;

            Some((first, second))
        })
        .collect()
}

#[cfg(test)]
mod tests {
    use super::*;

    const EXAMPLE_INPUT: &str = "3   4
 4   3
 2   5
 1   3
 3   9
 3   3";

    #[test]
    fn test_part1() {
        assert_eq!(part1(EXAMPLE_INPUT), 11);
    }

    #[test]
    fn test_part2() {
        assert_eq!(part2(EXAMPLE_INPUT), 31);
    }
}
