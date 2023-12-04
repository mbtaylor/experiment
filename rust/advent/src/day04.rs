use regex::Regex;
use std::collections::HashSet;

struct Card {
    _id: i32,
    wins: Vec<i32>,
    gots: Vec<i32>,
}

impl Card {
    fn from_line(line: String) -> Card {
        let card_re = Regex::new("Card +([0-9]+):([0-9 ]+)[|]([0-9 ]+)")
                     .unwrap();
        let caps = card_re.captures(&line).expect("bad line");
        let id: i32 = caps[1].parse().expect("bad id");
        let wins = parse_numbers(&caps[2]);
        let gots = parse_numbers(&caps[3]);
        Card{_id: id, wins: wins, gots: gots}
    }
    fn win_count(&self) -> i32 {
        let mut winmap: HashSet<i32> = HashSet::new();
        for win in &self.wins {
            winmap.insert(win.clone());
        }
        let mut c = 0;
        for got in &self.gots {
            if winmap.contains(&got) {
                c += 1;
            }
        }
        c
    }
}

fn parse_numbers(text: &str) -> Vec<i32> {
    let mut nums: Vec<i32> = Vec::new();
    for word in text.trim().split_whitespace() {
        nums.push(word.parse().expect("bad num"));
    }
    nums
}

pub fn calc04a(lines: Vec<String>) -> i32 {
    let mut score = 0;
    for line in lines {
        let card = Card::from_line(line);
        let wc = card.win_count();
        if wc > 0 {
            score += 1 << ( wc - 1 );
        }
    }
    score
}
