use std::collections::HashSet;

/// Convert input string to 2D character grid
fn parse_grid(input: &str) -> Vec<Vec<char>> {
    input
        .lines()
        .filter(|line| !line.trim().is_empty())
        .map(|line| line.chars().collect())
        .collect()
}

/// Create all possible ordered pairs between elements of two lists
fn create_ordered_pairs<T: Clone>(list1: &[T], list2: &[T]) -> Vec<(T, T)> {
    list1
        .iter()
        .flat_map(|item1| {
            list2
                .iter()
                .map(move |item2| (item1.clone(), item2.clone()))
        })
        .collect()
}

/// Calculate positions along the line from start to end within grid bounds
fn calculate_antinode_positions(
    grid_size: usize,
    (start_row, start_col): (usize, usize),
    (end_row, end_col): (usize, usize),
) -> Vec<(usize, usize)> {
    if (start_row, start_col) == (end_row, end_col) {
        return Vec::new();
    }

    let row_step = end_row as isize - start_row as isize;
    let col_step = end_col as isize - start_col as isize;

    let mut result = Vec::new();
    let mut current = (end_row as isize, end_col as isize);

    loop {
        current = (current.0 + row_step, current.1 + col_step);

        if current.0 >= 0
            && current.0 < grid_size as isize
            && current.1 >= 0
            && current.1 < grid_size as isize
        {
            result.push((current.0 as usize, current.1 as usize));
        } else {
            break;
        }
    }

    result
}

/// Core solver function for both problem parts
fn solve_grid<F>(grid: &[Vec<char>], position_mapper: F) -> usize
where
    F: Fn(usize, (usize, usize), (usize, usize)) -> Vec<(usize, usize)>,
{
    let grid_size = grid.len();
    assert!(grid.iter().all(|row| row.len() == grid_size));

    // Create a list of valid characters (digits, lowercase and uppercase letters)
    let valid_chars: Vec<char> = ('0'..='9').chain('a'..='z').chain('A'..='Z').collect();

    // Find positions of each character in the grid
    let mut result_positions = HashSet::new();

    for &char in &valid_chars {
        let mut char_locations = Vec::new();

        // Find all positions of this character
        for (row, grid_row) in grid.iter().enumerate() {
            for (col, &cell) in grid_row.iter().enumerate() {
                if cell == char {
                    char_locations.push((row, col));
                }
            }
        }

        // Generate all pair combinations
        let pairs = create_ordered_pairs(&char_locations, &char_locations);

        // Map positions using the provided mapper function
        for ((r1, c1), (r2, c2)) in pairs {
            let mapped_points = position_mapper(grid_size, (r1, c1), (r2, c2));
            result_positions.extend(mapped_points);
        }
    }

    result_positions.len()
}

/// Part 1: Consider the first valid antinode position
pub fn part1(input: &str) -> u64 {
    let grid = parse_grid(input);

    solve_grid(&grid, |size, (r1, c1), (r2, c2)| {
        let positions = calculate_antinode_positions(size, (r1, c1), (r2, c2));
        if positions.is_empty() {
            Vec::new()
        } else {
            vec![positions[0]]
        }
    }) as u64
}

/// Part 2: Include endpoint and all valid antinodes
pub fn part2(input: &str) -> u64 {
    let grid = parse_grid(input);

    solve_grid(&grid, |size, (r1, c1), (r2, c2)| {
        let mut result = vec![(r2, c2)];
        result.extend(calculate_antinode_positions(size, (r1, c1), (r2, c2)));
        result
    }) as u64
}

#[cfg(test)]
mod tests {
    use super::*;

    const EXAMPLE_INPUT: &str = "............
........0...
.....0......
.......0....
....0.......
......A.....
............
............
........A...
.........A..
............
............";

    #[test]
    fn test_part1() {
        assert_eq!(part1(EXAMPLE_INPUT), 14);
    }

    #[test]
    fn test_part2() {
        assert_eq!(part2(EXAMPLE_INPUT), 34);
    }
}
