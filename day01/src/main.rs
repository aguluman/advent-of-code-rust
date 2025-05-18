use day01::{part1, part2, parse};
use std::io::{self, Read};
use std::time::Instant;

fn main() {
    // Read input from stdin
    let mut input = String::new();
    io::stdin().read_to_string(&mut input).unwrap();
    let input = input.trim();
    
    let location_ids = parse(input);

    let start_time = Instant::now();
    
    println!("Part 1: {}", part1(&location_ids));
    println!("Part 2: {}", part2(&location_ids));

    let elapsed = start_time.elapsed();
    println!("Elapsed time: {:.4} seconds", elapsed.as_secs_f64());
}