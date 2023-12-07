
use std::cmp::PartialEq;
use std::cmp::Eq;
use std::cmp::Ord;
use std::cmp::PartialOrd;

#[derive(Debug)]
struct HandBid {
    hand: Hand,
    bid: i32,
}

#[derive(Debug,PartialEq,Eq,PartialOrd,Ord)]
struct Hand {
    htype: HandType,
    cards: [u8; 5],
}

impl Hand {
    fn new(cards_txt: &str) -> Hand {
        let mut mcards = [0; 5];
        for (i, c) in cards_txt.as_bytes().iter().enumerate() {
            mcards[i] = "23456789TJQKA".find(*c as char).unwrap() as u8;
        }
        let cards = mcards;
        Hand{
            cards: cards,
            htype: Self::hand_type(&cards),
        }
    }
    fn hand_type(cards: &[u8; 5]) -> HandType {
        let mut counts: [i32; 13] = [0; 13];
        for c in cards {
            counts[*c as usize] += 1;
        }
        counts.sort_by(|a, b| b.cmp(a));
        match counts[0..5] {
            [5, 0, 0, 0, 0] => HandType::Five,
            [4, 1, 0, 0, 0] => HandType::Four,
            [3, 2, 0, 0, 0] => HandType::FullHouse,
            [3, 1, 1, 0, 0] => HandType::Three,
            [2, 2, 1, 0, 0] => HandType::TwoPair,
            [2, 1, 1, 1, 0] => HandType::Pair,
            [1, 1, 1, 1, 1] => HandType::High,
            _ => panic!(),
        }
    }
}

#[derive(Debug,PartialEq,Eq,PartialOrd,Ord)]
enum HandType {
    Five = 7,
    Four = 6,
    FullHouse = 5,
    Three = 4,
    TwoPair = 3,
    Pair = 2,
    High = 1,
}

fn read_hand_bids(lines: Vec<String>) -> Vec<HandBid> {
    let mut hbids = Vec::new();
    for line in lines {
        let mut words = line.split_whitespace();
        let cards_txt = words.next().unwrap();
        let bid_txt = words.next().unwrap();
        let bid: i32 = bid_txt.parse().unwrap();
        assert!(words.next() == None);
        hbids.push(HandBid{hand: Hand::new(cards_txt), bid: bid});
    }
    hbids
}

pub fn calc07a(lines: Vec<String>) -> i64 {
    let mut hbids = read_hand_bids(lines);
    hbids.sort_by(|a, b| a.hand.cmp(&b.hand));
    let mut win: i64 = 0;
    for (rank, hbid) in hbids.iter().enumerate() {
        win += (rank + 1) as i64 * hbid.bid as i64;
    }
    win
}

