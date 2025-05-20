use std::collections::{HashMap, HashSet};
use itertools::Itertools;
use rayon::prelude::*;

type Rule = (i32, i32);
type UpdateList = Vec<i32>;

/// Parse the input string into rules and updates
fn parse_input(input: &str) -> (Vec<Rule>, Vec<UpdateList>) {
    // Split input into blocks by empty lines
    let blocks: Vec<&str> = input.split("\n\n").collect();
    if blocks.len() < 2 {
        return (Vec::new(), Vec::new());
    }

    let rules_block = blocks[0];
    let updates_block = blocks[1];

    // Count lines to pre-allocate collections
    let rule_line_count = rules_block.lines().filter(|line| !line.trim().is_empty()).count();
    let update_line_count = updates_block.lines().filter(|line| !line.trim().is_empty()).count();

    // Parse rules with pre-allocation
    let mut rules = Vec::with_capacity(rule_line_count);
    for line in rules_block.lines().filter(|line| !line.trim().is_empty()) {
        let parts: Vec<&str> = line.split('|').collect();
        if parts.len() == 2 {
            if let (Ok(p), Ok(q)) = (parts[0].trim().parse::<i32>(), parts[1].trim().parse::<i32>()) {
                rules.push((p, q));
            }
        }
    }

    // Parse updates with pre-allocation
    let mut updates = Vec::with_capacity(update_line_count);
    for line in updates_block.lines().filter(|line| !line.trim().is_empty()) {
        let update: Vec<i32> = line.split(',')
            .filter_map(|x| x.trim().parse::<i32>().ok())
            .collect();
        updates.push(update);
    }

    (rules, updates)
}

// Define a more descriptive type for the return value
type FollowingMap = HashMap<i32, HashSet<i32>>;
type SplitResult<'a> = (FollowingMap, (Vec<&'a UpdateList>, Vec<&'a UpdateList>));

/// Split updates into correct and incorrect based on rules
#[allow(clippy::type_complexity)]
fn split_updates<'a>(rules: &[Rule], updates: &'a [UpdateList]) -> SplitResult<'a> {
    // Extract unique pages more efficiently
    let mut pages = Vec::with_capacity(rules.len() * 2);
    for &(p, q) in rules {
        pages.push(p);
        pages.push(q);
    }
    // Use sort_unstable which is faster than sorted() from itertools
    pages.sort_unstable();
    pages.dedup();

    // Debug assertion - can be commented out in production
    for (p, q) in pages.iter().cartesian_product(pages.iter()) {
        assert!(
            p == q || 
            rules.iter().any(|(x, y)| x == p && y == q) || 
            rules.iter().any(|(x, y)| x == q && y == p)
        );
    }

    // Build following map with pre-allocation
    let mut following: HashMap<i32, HashSet<i32>> = HashMap::with_capacity(rules.len());
    for &(p, q) in rules {
        following.entry(p)
            .or_insert_with(|| HashSet::with_capacity(4)) // Pre-allocate small capacity for most cases
            .insert(q);
    }

    // Pre-allocate for results based on approximate distribution
    let expected_correct = updates.len() / 2;
    let mut correct = Vec::with_capacity(expected_correct);
    let mut incorrect = Vec::with_capacity(updates.len() - expected_correct);
    
    // Check if updates are valid - optimized implementation
    for update in updates {
        let mut is_valid = true;
        'outer: for (i, &p) in update.iter().enumerate() {
            for &q in update.iter().skip(i+1) {
                // More efficient lookups
                let p_follows_q = following.get(&p).map(|v| v.contains(&q)).unwrap_or(true);
                let q_follows_p = following.get(&q).map(|v| !v.contains(&p)).unwrap_or(true);
                
                if !(p_follows_q && q_follows_p) {
                    is_valid = false;
                    break 'outer;
                }
            }
        }
        if is_valid {
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
    
    // Optimized processing using parallel execution
    let sum: i32 = correct_updates.par_iter()
        .map(|&updates| {
            updates[updates.len() / 2]
        })
        .sum();
    
    sum as u64
}

/// Part 2: Process incorrect updates
pub fn part2(input: &str) -> u64 {
    let (rules, updates) = parse_input(input);
    let (following, (_, incorrect_updates)) = split_updates(&rules, &updates);
    
    // Process updates in parallel and avoid unnecessary cloning
    let sum: i32 = incorrect_updates.par_iter()
        .map(|&updates| {
            // Avoid clone by copying values into a new vector
            let mut sorted_updates: Vec<i32> = Vec::with_capacity(updates.len());
            sorted_updates.extend_from_slice(updates);
            
            // Precompute relationships for more efficient sorting
            let mut relationships = vec![vec![false; updates.len()]; updates.len()];
            for i in 0..updates.len() {
                let p = updates[i];
                if let Some(follows) = following.get(&p) {
                    for (j, &q) in updates.iter().enumerate() {
                        if i != j {
                            relationships[i][j] = follows.contains(&q);
                        }
                    }
                }
            }
            
            // Sort using precomputed relationships
            let mut indices: Vec<usize> = (0..updates.len()).collect();
            indices.sort_unstable_by(|&i, &j| {
                if relationships[i][j] {
                    std::cmp::Ordering::Less
                } else if relationships[j][i] {
                    std::cmp::Ordering::Greater
                } else {
                    std::cmp::Ordering::Equal
                }
            });
            
            // Reorder based on sorted indices
            let sorted_values: Vec<i32> = indices.iter().map(|&i| updates[i]).collect();
            
            // Get the middle value
            sorted_values[sorted_values.len() / 2]
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