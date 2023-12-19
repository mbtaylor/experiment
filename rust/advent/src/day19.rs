use regex::Regex;
use std::collections::HashMap;
use std::fmt::Display;
use std::fmt::Formatter;
use std::fmt::Result;

#[derive(Debug)]
struct Flow {
    label: String,
    rules: Vec<Rule>,
}

#[derive(Clone,Debug)]
struct Rule {
    stat: char,
    cmp: char,
    num: i32,
    dest: String,
}

#[derive(Debug)]
struct Part {
    x: i32,
    m: i32,
    a: i32,
    s: i32,
}

#[derive(Copy,Clone,Debug)]
struct Range {
    lo: i32,
    hi: i32,
}

#[derive(Clone,Copy,Debug)]
struct Class {
    ranges: [Range; 4],
}

struct SplitClass {
    pass: Option<Class>,
    fail: Option<Class>,
}

impl Rule {
    fn pass(&self, part: &Part) -> bool {
        let stat = match self.stat {
            'x' => part.x,
            'm' => part.m,
            'a' => part.a,
            's' => part.s,
            '.' => return true,
            _ => panic!(),
        };
        match self.cmp {
            '>' => stat > self.num,
            '<' => stat < self.num,
            _ => panic!(),
        }
    }
    fn split(&self, class: &Class) -> SplitClass {
        let class = class.clone();
        let irange = match self.stat {
            'x' => 0,
            'm' => 1,
            'a' => 2,
            's' => 3,
            '.' => {
                return SplitClass{pass: Some(class), fail: None};
            },
            _ => panic!(),
        };
        let range = class.ranges[irange];
        let num = self.num;
        match self.cmp {
            '.' => {
                SplitClass{pass: Some(class), fail: None}
            },
            '<' => {
                if num < range.lo {
                    SplitClass{pass: None, fail: Some(class)}
                }
                else if num > range.hi {
                    SplitClass{pass: Some(class), fail: None}
                }
                else {
                    let pc = class.adjust_range(irange, range.lo, num-1);
                    let fc = class.adjust_range(irange, num, range.hi);
                    SplitClass{pass: Some(pc), fail: Some(fc)}
                }
            },
            '>' => {
                if num > range.hi {
                    SplitClass{pass: None, fail: Some(class)}
                }
                else if num < range.lo {
                    SplitClass{pass: Some(class), fail: None}
                }
                else {
                    let pc = class.adjust_range(irange, num+1, range.hi);
                    let fc = class.adjust_range(irange, range.lo, num);
                    SplitClass{pass: Some(pc), fail: Some(fc)}
                }
            },
            _ => panic!(),
        }
    }
}

impl Flow {
    fn next_dest(&self, part: &Part) -> &str {
        &self.rules.iter().find(|p| p.pass(part)).unwrap().dest[..]
    }
}

impl Range {
    fn new() -> Range {
        Range{lo: 1, hi: 4000}
    }
}

impl Class {
    fn new() -> Class {
        Class{
            ranges: [Range::new(), Range::new(), Range::new(), Range::new()],
        }
    }
    fn adjust_range(&self, irange: usize, lo: i32, hi: i32) -> Class {
        let mut class = self.clone();
        class.ranges[irange] = Range{lo: lo, hi: hi};
        class
    }
    fn count_possibilities(&self) -> i64 {
        let mut n: i64 = 1;
        for range in self.ranges {
            n *= (range.hi - range.lo + 1) as i64;
        }
        n
    }
}

impl Display for Class {
    fn fmt(&self, f: &mut Formatter<'_>) -> Result {
        write!(f, "{}: {}-{}, {}: {}-{}, {}: {}-{}, {}: {}-{}",
                  "x", self.ranges[0].lo, self.ranges[0].hi,
                  "m", self.ranges[1].lo, self.ranges[1].hi,
                  "a", self.ranges[2].lo, self.ranges[2].hi,
                  "s", self.ranges[3].lo, self.ranges[3].hi)
    }
}

fn parse_flow(line: &str) -> Flow {
    let line_re = Regex::new("([a-z]+)[{](.*?)([a-zAR]+)[}]").unwrap();
    let rule_re = Regex::new("([xmas])([<>])([0-9]+):([a-zAR]+),").unwrap();
    let (_, [label, rules_txt, final_dest]) =
        line_re.captures(line).unwrap().extract();
    let mut rules: Vec<Rule> = Vec::new();
    for (x, [stat, cmp, num, dest]) in rule_re.captures_iter(rules_txt)
                                              .map(|c| c.extract()) {
        let stat: char = stat.chars().next().unwrap();
        let cmp: char = cmp.chars().next().unwrap();
        let num: i32 = num.parse().unwrap();
        let dest: String = String::from(dest);
        rules.push(Rule{stat, cmp, num, dest});
    }
    rules.push(Rule{stat: '.', cmp: '.', num: 0,
                    dest: String::from(final_dest)});
    let label = String::from(label);
    Flow{label, rules}
}

fn parse_part(line: &str) -> Part {
    let asn_re = Regex::new("([xmas])=([0-9]+)").unwrap();
    let mut x: Option<i32> = None;
    let mut m: Option<i32> = None;
    let mut a: Option<i32> = None;
    let mut s: Option<i32> = None;
    for (_, [stat, num]) in asn_re.captures_iter(line).map(|c| c.extract()) {
        let num: Option<i32> = Some(num.parse().unwrap());
        match stat {
            "x" => x = num,
            "m" => m = num,
            "a" => a = num,
            "s" => s = num,
            _ => panic!(),
        }
    }
    Part{x: x.unwrap(), m: m.unwrap(), a: a.unwrap(), s: s.unwrap()}
}

fn is_accept(flow: &Flow, map: &HashMap<String,Flow>, part: &Part) -> bool {
    let dest = flow.next_dest(part);
    match dest {
        "A" => true,
        "R" => false,
        _ => is_accept(map.get(dest).unwrap(), map, part),
    }
}

fn accept_classes(rules: &Vec<Rule>, map: &HashMap<String,Flow>, class: &Class)
        -> Vec<Class> {
    let mut accepts: Vec<Class> = Vec::new();
    let mut class = class.clone();
    for rule in rules {
        let split_class = rule.split(&class);
        if let Some(pass) = &split_class.pass {
            match &rule.dest[..] {
                "A" => {
                    accepts.push(*pass);
                },
                "R" => {
                },
                _ => {
                    let subflow = map.get(&rule.dest[..]).unwrap();
                    for c in accept_classes(&subflow.rules, map, &pass) {
                        accepts.push(c);
                    }
                }
            }
        }
        if let Some(fail) = split_class.fail {
            class = fail.clone();
        }
    }
    accepts
}

pub fn calc19a(lines: Vec<String>) -> i64 {
    let mut map: HashMap<String,Flow> = HashMap::new();
    let mut parts: Vec<Part> = Vec::new();
    let mut state = 0;
    for line in lines {
        if state == 0 {
            if line.len() > 0 {
                let flow = parse_flow(&line[..]);
                map.insert(flow.label.clone(), flow);
            }
            else {
                state = 1;
            }
        }
        else if state == 1 {
            parts.push(parse_part(&line[..]));
        }
    }

    let flow0 = map.get("in").unwrap();
    let mut tot = 0;
    for part in parts {
        if is_accept(&flow0, &map, &part) {
            tot += (part.x + part.m + part.a + part.s) as i64;
        }
    }
    tot
}

pub fn calc19b(lines: Vec<String>) -> i64 {
    let mut map: HashMap<String,Flow> = HashMap::new();
    for line in lines {
        if line.len() > 0 {
            let flow = parse_flow(&line[..]);
            map.insert(flow.label.clone(), flow);
        }
        else {
            break;
        }
    }

    let flow0 = map.get("in").unwrap();
    let class0 = Class::new();
    let mut tot: i64 = 0;
    for class in accept_classes(&flow0.rules, &map, &class0) {
        tot += class.count_possibilities();
    }
    tot
}
