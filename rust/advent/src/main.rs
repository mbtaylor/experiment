#![allow(unused_variables)]

use std::io;
use std::env;

mod day01;
mod day02;
mod day03;
mod day04;
mod day05;
mod day06;
mod day07;
mod day08;
mod day09;
mod day10;
mod day11;
mod day12;
mod day13;
mod day14;
mod day15;
mod day16;
mod day18;

fn main() {
    let mut args: Vec<String> = env::args().collect();
    if args.len() != 2 {
        panic!("Usage: {} <id>", args.remove(0));
    }
    let id = args.remove(1);
    let id = id.as_str();
    let result = match id {
        "01a" => day01::calc01a(read_lines()) as i64,
        "01b" => day01::calc01b(read_lines()) as i64,
        "02a" => day02::calc02a(read_lines()) as i64,
        "02b" => day02::calc02b(read_lines()) as i64,
        "03a" => day03::calc03a(read_lines()) as i64,
        "03b" => day03::calc03b(read_lines()) as i64,
        "04a" => day04::calc04a(read_lines()) as i64,
        "04b" => day04::calc04b(read_lines()) as i64,
        "05a" => day05::calc05a(read_lines()),
        "05b" => day05::calc05b(read_lines()),
        "06a" => day06::calc06a(read_lines()),
        "06b" => day06::calc06b(read_lines()),
        "07a" => day07::calc07a(read_lines()),
        "07b" => day07::calc07b(read_lines()),
        "08a" => day08::calc08a(read_lines()),
        "08b" => day08::calc08b(read_lines()),
        "09a" => day09::calc09a(read_lines()),
        "09b" => day09::calc09b(read_lines()),
        "10a" => day10::calc10a(read_lines()),
        "10b" => day10::calc10b(read_lines()),
        "11a" => day11::calc11a(read_lines()),
        "11b" => day11::calc11b(read_lines()),
        "12a" => day12::calc12a(read_lines()),
        "12b" => day12::calc12b(read_lines()),
        "13a" => day13::calc13a(read_lines()),
        "13b" => day13::calc13b(read_lines()),
        "14a" => day14::calc14a(read_lines()),
        "14b" => day14::calc14b(read_lines()),
        "15a" => day15::calc15a(read_lines()),
        "15b" => day15::calc15b(read_lines()),
        "16a" => day16::calc16a(read_lines()),
        "16b" => day16::calc16b(read_lines()),
        "18a" => day18::calc18a(read_lines()),
        _ => panic!("Unknown ID {}", id),
    };
    println!("{} -> {}", id, result);
}

fn read_lines() -> Vec<String> {
    let stdin = io::stdin();
    let mut lines = Vec::new();
    loop {
       let mut line = String::new();
       match stdin.read_line(&mut line) {
           Ok(siz) => match siz {
               0 => break,
               _ => {},
           },
           Err(error) => {
               println!("{}", error);
               break;
           },
       }
       lines.push(String::from(line.trim()));
    }
    lines
}
