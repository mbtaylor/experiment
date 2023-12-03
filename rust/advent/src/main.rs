use std::io;
use std::env;
use regex::Regex;

fn main() {
    let mut args: Vec<String> = env::args().collect();
    if args.len() != 2 {
        panic!("Usage: {} <id>", args.remove(0));
    }
    let id = args.remove(1);
    let id = id.as_str();
    let result = match id {
        "01a" => calc01a(read_lines()),
        "01b" => calc01b(read_lines()),
        "02a" => calc02a(read_lines()),
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

fn calc01a(lines: Vec<String>) -> i32 {
    let mut tot = 0;
    for line in lines {
        let mut d1 = 0;
        let mut d2 = 0;
        for c in line.as_bytes() {
            let d = ( *c as i32 ) - 0x30;
            if d >= 0 && d <= 9 {
                if d1 == 0 {
                    d1 = d;
                }
                d2 = d;
            }
        }
        let dd = d1 * 10 + d2;
        tot += dd;
    }
    tot
}

fn calc01b(lines: Vec<String>) -> i32 {
    let mut lines2 = Vec::new();
    for line in lines {
        lines2.push(line.replace("one", "one1one")
                        .replace("two", "two2two")
                        .replace("three", "three3three")
                        .replace("four", "four4four")
                        .replace("five", "five5five")
                        .replace("six", "six6six")
                        .replace("seven", "seven7seven")
                        .replace("eight", "eight8eight")
                        .replace("nine", "nine9nine"));
    }
    calc01a(lines2)
}

struct Bag(i32, i32, i32);

struct Sample(i32, i32, i32);

struct Game {
    id: i32,
    samples: Vec<Sample>,
}

impl Bag {
    fn is_possible(&self, game: &Game) -> bool {
        for sample in &game.samples {
            if sample.0 > self.0 ||
               sample.1 > self.1 ||
               sample.2 > self.2 {
                return false;
            }
        }
        true
    }
}

fn calc02a(lines: Vec<String>) -> i32 {
    let bag = Bag(12, 13, 14);
    let mut tot = 0;
    for game in read_games(lines) {
        if bag.is_possible(&game) {
            tot += game.id;
        }
    }
    tot
}

fn read_games(lines: Vec<String>) -> Vec<Game> {
    let g_re = Regex::new("Game +([0-9]+): +(.*)").unwrap();
    let s_re = Regex::new("[^;]+").unwrap();
    let c_re = Regex::new("[^,]+").unwrap();
    let t_re = Regex::new("([0-9]+) ([a-z]+)").unwrap();
    let mut games: Vec<Game> = Vec::new();
    for line in lines {
        let Some(caps) = g_re.captures(&line[..]) else {
            panic!("No match {}", line);
        };
        let g_id: i32 = caps[1].parse().expect("Game ID not an int");
        // println!("{}", g_id);
        let samples_txt = &caps[2];
        // println!("   {}", samples_txt);
        let mut samples: Vec<Sample> = Vec::new();
        for sample_match in s_re.find_iter(samples_txt) {
            let sample = sample_match.as_str();
            // println!("   ...{}", sample);
            let mut r = 0;
            let mut g = 0;
            let mut b = 0;
            for count_match in c_re.find_iter(sample) {
                let count = count_match.as_str().trim();
                let item_caps = t_re.captures(count).expect("No count");
                let item_n: i32 = item_caps[1].parse().expect("Bad num");
                match &item_caps[2] {
                    "red" => r = item_n,
                    "green" => g = item_n,
                    "blue" => b = item_n,
                    _ => (),
                }
            }
            samples.push(Sample(r, g, b));
        }
        games.push(Game{id: g_id, samples: samples});
    }
    games
}


