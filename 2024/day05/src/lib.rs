use itertools::Itertools;
use std::collections::{HashMap, HashSet};

type Rule = (i32, i32);
type UpdateList = Vec<i32>;
type FollowingMap = HashMap<i32, HashSet<i32>>;
type UpdatePartition<'a> = (Vec<&'a UpdateList>, Vec<&'a UpdateList>);

/// Parse the input string into rules and updates
fn parse_input(input: &str) -> (Vec<Rule>, Vec<UpdateList>) {
    // Split input into blocks by empty lines
    let blocks: Vec<&str> = input.split("\n\n").collect();
    if blocks.len() < 2 {
        return (Vec::new(), Vec::new());
    }

    let rules_block = blocks[0];
    let updates_block = blocks[1];

    // Parse rules
    let rules: Vec<Rule> = rules_block
        .lines()
        .filter(|line| !line.trim().is_empty())
        .filter_map(|line| {
            let parts: Vec<&str> = line.split('|').collect();
            if parts.len() == 2 {
                let p = parts[0].trim().parse::<i32>().ok()?;
                let q = parts[1].trim().parse::<i32>().ok()?;
                Some((p, q))
            } else {
                None
            }
        })
        .collect();

    // Parse updates
    let updates: Vec<UpdateList> = updates_block
        .lines()
        .filter(|line| !line.trim().is_empty())
        .map(|line| {
            line.split(',')
                .filter_map(|x| x.trim().parse::<i32>().ok())
                .collect()
        })
        .collect();

    (rules, updates)
}
/// Split updates into correct and incorrect based on rules
fn split_updates<'a>(
    rules: &[Rule],
    updates: &'a [UpdateList],
) -> (FollowingMap, UpdatePartition<'a>) {
    // Extract unique pages
    let pages: Vec<i32> = rules
        .iter()
        .flat_map(|(p, q)| vec![*p, *q])
        .sorted()
        .dedup()
        .collect();

    // Debug assertion - can be commented out in production
    for (p, q) in pages.iter().cartesian_product(pages.iter()) {
        assert!(
            p == q
                || rules.iter().any(|(x, y)| x == p && y == q)
                || rules.iter().any(|(x, y)| x == q && y == p)
        );
    }

    // Build the following map
    let mut following: HashMap<i32, HashSet<i32>> = HashMap::new();
    for &(p, q) in rules {
        following.entry(p).or_default().insert(q);
    }

    // Check if updates are valid
    let check_updates = |update_list: &UpdateList| -> bool {
        for (i, &p) in update_list.iter().enumerate() {
            for &q in update_list.iter().skip(i + 1) {
                let p_q = following.get(&p).map(|v| v.contains(&q)).unwrap_or(true);

                let q_p = following.get(&q).map(|v| !v.contains(&p)).unwrap_or(true);

                if !(p_q && q_p) {
                    return false;
                }
            }
        }
        true
    };

    // Partition updates
    let mut correct: Vec<&UpdateList> = Vec::new();
    let mut incorrect: Vec<&UpdateList> = Vec::new();

    for update in updates {
        if check_updates(update) {
            correct.push(update);
        } else {
            incorrect.push(update);
        }
    }

    (following, (correct, incorrect))
}

/// Part 1: Process correct updates
pub fn part1(input: &str) -> u64 {
    let (rules, updates) = parse_input(input);
    let (_, (correct_updates, _)) = split_updates(&rules, &updates);

    let sum: i32 = correct_updates
        .iter()
        .map(|updates| updates[updates.len() / 2])
        .sum();

    sum as u64
}

/// Part 2: Process incorrect updates
pub fn part2(input: &str) -> u64 {
    let (rules, updates) = parse_input(input);
    let (following, (_, incorrect_updates)) = split_updates(&rules, &updates);

    let sum: i32 = incorrect_updates
        .iter()
        .map(|&updates| {
            // Create a sorted version based on the following relationship
            let mut sorted_updates = updates.clone();
            sorted_updates.sort_by(|&p, &q| match following.get(&p) {
                Some(v) if v.contains(&q) => std::cmp::Ordering::Less,
                _ => std::cmp::Ordering::Greater,
            });

            sorted_updates[sorted_updates.len() / 2]
        })
        .sum();

    sum as u64
}

#[cfg(test)]
mod tests {
    use super::*;

    const EXAMPLE_INPUT: &str = "47|53
97|13
97|61
97|47
75|29
61|13
75|53
29|13
97|29
53|29
61|53
97|53
61|29
47|13
75|47
97|75
47|61
75|61
47|29
75|13
53|13

75,47,61,53,29
97,61,53,29,13
75,29,13
75,97,47,61,53
61,13,29
97,13,75,29,47";

    #[test]
    fn test_part1() {
        assert_eq!(part1(EXAMPLE_INPUT), 143);
    }

    #[test]
    fn test_part2() {
        assert_eq!(part2(EXAMPLE_INPUT), 123);
    }
}
