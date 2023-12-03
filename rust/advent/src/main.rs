use std::io;
use std::env;

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
    let mut tot = 0;
    for line in lines {
        let line = line.trim()
                       .replace("one", "one1one")
                       .replace("two", "two2two")
                       .replace("three", "three3three")
                       .replace("four", "four4four")
                       .replace("five", "five5five")
                       .replace("six", "six6six")
                       .replace("seven", "seven7seven")
                       .replace("eight", "eight8eight")
                       .replace("nine", "nine9nine");
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

