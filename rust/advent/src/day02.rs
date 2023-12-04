use regex::Regex;
use std::cmp;

struct Bag(i32, i32, i32);

struct Sample(i32, i32, i32);

struct Game {
    id: i32,
    samples: Vec<Sample>,
}

impl Game {
    fn is_possible(&self, bag: &Bag) -> bool {
        for sample in &self.samples {
            if sample.0 > bag.0 ||
               sample.1 > bag.1 ||
               sample.2 > bag.2 {
                return false;
            }
        }
        true
    }
    fn min_bag(&self) -> Bag {
        let mut bag = Bag(0, 0, 0);
        for sample in &self.samples {
            bag.0 = cmp::max(bag.0, sample.0);
            bag.1 = cmp::max(bag.1, sample.1);
            bag.2 = cmp::max(bag.2, sample.2);
        }
        bag
    }
}

pub fn calc02a(lines: Vec<String>) -> i32 {
    let bag = Bag(12, 13, 14);
    let mut tot = 0;
    for game in read_games(lines) {
        if game.is_possible(&bag) {
            tot += game.id;
        }
    }
    tot
}

pub fn calc02b(lines: Vec<String>) -> i32 {
    let mut tot = 0;
    for game in read_games(lines) {
        let bag = game.min_bag();
        let power = bag.0 * bag.1 * bag.2;
        tot += power;
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
