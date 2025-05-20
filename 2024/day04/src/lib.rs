/// Represents a character in the grid or None for out of bounds
type GridChar = Option<char>;

/// Parse the input string into a 2D character grid
fn parse_grid(input: &str) -> Vec<Vec<char>> {
    input
        .lines()
        .filter(|line| !line.trim().is_empty())
        .map(|line| line.chars().collect())
        .collect()
}

/// Get character at position (i,j) in the grid, returning None if out of bounds
fn get_char(grid: &[Vec<char>], i: isize, j: isize) -> GridChar {
    if i >= 0 && (i as usize) < grid.len() && j >= 0 && (j as usize) < grid[i as usize].len() {
        Some(grid[i as usize][j as usize])
    } else {
        None
    }
}

/// Part 1: Count the number of "XMAS" patterns in the grid in all 8 directions
pub fn part1(input: &str) -> u64 {
    let grid: Vec<Vec<char>> = parse_grid(input);

    let mut count: u64 = 0;

    for i in 0..grid.len() {
        for j in 0..grid[i].len() {
            let i_signed: isize = i as isize;
            let j_signed: isize = j as isize;

            // Check all 8 directions
            let directions: Vec<Vec<GridChar>> = vec![
                // North
                (0..4)
                    .map(|d| get_char(&grid, i_signed - d, j_signed))
                    .collect(),
                // Northeast
                (0..4)
                    .map(|d| get_char(&grid, i_signed - d, j_signed + d))
                    .collect(),
                // East
                (0..4)
                    .map(|d| get_char(&grid, i_signed, j_signed + d))
                    .collect(),
                // Southeast
                (0..4)
                    .map(|d| get_char(&grid, i_signed + d, j_signed + d))
                    .collect(),
                // South
                (0..4)
                    .map(|d| get_char(&grid, i_signed + d, j_signed))
                    .collect(),
                // Southwest
                (0..4)
                    .map(|d| get_char(&grid, i_signed + d, j_signed - d))
                    .collect(),
                // West
                (0..4)
                    .map(|d| get_char(&grid, i_signed, j_signed - d))
                    .collect(),
                // Northwest
                (0..4)
                    .map(|d| get_char(&grid, i_signed - d, j_signed - d))
                    .collect(),
            ];

            // Check for "XMAS" pattern in each direction
            for direction in directions {
                if direction == vec![Some('X'), Some('M'), Some('A'), Some('S')] {
                    count += 1;
                }
            }
        }
    }

    count
}

/// Check if three characters form "MAS"
fn is_mas(c1: GridChar, c2: GridChar, c3: GridChar) -> bool {
    c1 == Some('M') && c2 == Some('A') && c3 == Some('S')
}

/// Part 2: Count characters forming an X pattern with "MAS" on opposite sides
pub fn part2(input: &str) -> u64 {
    let grid: Vec<Vec<char>> = parse_grid(input);

    let mut count: u64 = 0;

    for i in 0..grid.len() {
        for j in 0..grid[i].len() {
            let i_signed: isize = i as isize;
            let j_signed: isize = j as isize;
            let current: GridChar = Some(grid[i][j]);

            // Get characters in diagonal positions
            let ne: GridChar = get_char(&grid, i_signed - 1, j_signed + 1);
            let nw: GridChar = get_char(&grid, i_signed - 1, j_signed - 1);
            let se: GridChar = get_char(&grid, i_signed + 1, j_signed + 1);
            let sw: GridChar = get_char(&grid, i_signed + 1, j_signed - 1);

            // Check if they form X patterns with "MAS" on opposite sides
            let condition1: bool = is_mas(ne, current, sw) || is_mas(sw, current, ne);
            let condition2: bool = is_mas(nw, current, se) || is_mas(se, current, nw);

            if condition1 && condition2 {
                count += 1;
            }
        }
    }

    count
}

#[cfg(test)]
mod tests {
    use super::*;

    const EXAMPLE_INPUT: &str = "MMMSXXMASM\n\
         MSAMXMSMSA\n\
         AMXSXMAAMM\n\
         MSAMASMSMX\n\
         XMASAMXAMM\n\
         XXAMMXXAMA\n\
         SMSMSASXSS\n\
         SAXAMASAAA\n\
         MAMMMXMMMM\n\
         MXMXAXMASX";

    #[test]
    fn test_part1() {
        assert_eq!(part1(EXAMPLE_INPUT), 18);
    }

    #[test]
    fn test_part2() {
        assert_eq!(part2(EXAMPLE_INPUT), 9);
    }
}
