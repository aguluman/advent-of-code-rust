/// Direction represents possible movements in the grid.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
enum Direction {
    Up,    // Move upward
    Right, // Move rightward
    Down,  // Move downward
    Left,  // Move leftward
}

impl Direction {
    /// Returns the next direction in clockwise rotation.
    fn next_direction(&self) -> Direction {
        match self {
            Direction::Up => Direction::Right,
            Direction::Right => Direction::Down,
            Direction::Down => Direction::Left,
            Direction::Left => Direction::Up,
        }
    }
}

/// Parse input string to 2D grid
fn parse_grid(input: &str) -> Vec<Vec<char>> {
    input
        .lines()
        .filter(|s| !s.trim().is_empty())
        .map(|row| row.chars().collect())
        .collect()
}

pub fn part1(input: &str) -> u64 {
    let map = parse_grid(input);
    let n = map.len();

    // Verify all rows have the same length
    if map.iter().any(|row| row.len() != n) {
        panic!("Invalid map: not all rows have the same length");
    }

    // Find a starting position marked with '^'
    let (start_i, start_j) = (0..n)
        .flat_map(|i| (0..n).map(move |j| (i, j)))
        .find(|&(i, j)| map[i][j] == '^')
        .expect("No starting position found");

    // Start simulation with the initial position and Up direction
    let mut i = start_i;
    let mut j = start_j;
    let mut dir = Direction::Up;
    let mut history = vec![(start_i, start_j)];

    loop {
        // Compute the next position based on the current direction
        let next_pos = match dir {
            Direction::Up => {
                if i >= 1 {
                    Some((i - 1, j))
                } else {
                    None
                }
            }
            Direction::Right => {
                if j < n - 1 {
                    Some((i, j + 1))
                } else {
                    None
                }
            }
            Direction::Down => {
                if i < n - 1 {
                    Some((i + 1, j))
                } else {
                    None
                }
            }
            Direction::Left => {
                if j >= 1 {
                    Some((i, j - 1))
                } else {
                    None
                }
            }
        };

        if let Some((ni, nj)) = next_pos {
            if map[ni][nj] == '#' {
                // Hit the wall - stay in place but rotate
                dir = dir.next_direction();
            } else {
                // Move forward + track position
                i = ni;
                j = nj;
                history.push((ni, nj));
            }
        }
        // Out of bounds: stay put (implicit else case)

        // Check if we're stuck (same position and direction after a move)
        if next_pos.is_none()
            || (next_pos.is_some() && map[next_pos.unwrap().0][next_pos.unwrap().1] == '#')
        {
            let stuck_condition = match next_pos {
                Some((ni, nj)) => ni == i && nj == j,
                None => true,
            };

            if stuck_condition {
                // Count unique positions
                let mut unique_positions = history.clone();
                unique_positions.sort();
                unique_positions.dedup();
                return unique_positions.len() as u64;
            }
        }
    }
}

pub fn part2(input: &str) -> u64 {
    let map = parse_grid(input);
    let n = map.len();

    // Verify all rows have the same length
    if map.iter().any(|row| row.len() != n) {
        panic!("Invalid map: not all rows have the same length");
    }

    // Find a starting position marked with '^'
    let (start_i, start_j) = (0..n)
        .flat_map(|i| (0..n).map(move |j| (i, j)))
        .find(|&(i, j)| map[i][j] == '^')
        .expect("No starting position found");

    // Function to check if the blocking position creates a loop
    fn find_loop(map: &[Vec<char>], start_i: usize, start_j: usize, start_dir: Direction) -> bool {
        use std::collections::{HashSet, VecDeque};

        let n = map.len();
        let mut history = HashSet::new();
        let mut queue = VecDeque::new();
        queue.push_back((start_i, start_j, start_dir));

        while !queue.is_empty() {
            let (i, j, dir) = queue.pop_front().unwrap();

            // Compute the next position based on the current direction
            let next_pos = match dir {
                Direction::Up => {
                    if i >= 1 {
                        Some((i - 1, j))
                    } else {
                        None
                    }
                }
                Direction::Right => {
                    if j + 1 < n {
                        Some((i, j + 1))
                    } else {
                        None
                    }
                }
                Direction::Down => {
                    if i + 1 < n {
                        Some((i + 1, j))
                    } else {
                        None
                    }
                }
                Direction::Left => {
                    if j >= 1 {
                        Some((i, j - 1))
                    } else {
                        None
                    }
                }
            };

            if let Some((ni, nj)) = next_pos {
                let (ni, nj, nd) = if map[ni][nj] == '#' {
                    (i, j, dir.next_direction())
                } else {
                    (ni, nj, dir)
                };

                let state = (ni, nj, nd);
                if history.contains(&state) {
                    return true; // Loop found
                } else {
                    history.insert(state);
                    queue.push_back(state);
                }
            }
        }

        false
    }

    // Instead of using threads directly, we'll use a regular loop
    // This part could be optimized with rayon for parallelism if needed
    let mut loop_count = 0;

    for i in 0..n {
        for j in 0..n {
            if map[i][j] == '.' {
                // Create a new map with a wall at (i, j)
                let mut new_map = map.clone();
                new_map[i][j] = '#';

                // Check if this creates a loop
                if find_loop(&new_map, start_i, start_j, Direction::Up) {
                    loop_count += 1;
                }
            }
        }
    }

    loop_count
}

#[cfg(test)]
mod tests {
    use super::*;

    const EXAMPLE_INPUT: &str = "....#.....
.........#
..........
..#.......
.......#..
..........
.#..^.....
........#.
#.........
......#...";

    #[test]
    fn test_part1() {
        assert_eq!(part1(EXAMPLE_INPUT), 41);
    }

    #[test]
    fn test_part2() {
        assert_eq!(part2(EXAMPLE_INPUT), 6);
    }
}
