use regex::Regex;
use std::collections::HashMap;

#[derive(Debug)]
struct Flow {
    label: String,
    rules: Vec<Rule>,
}

#[derive(Debug)]
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
}

impl Flow {
    fn next_dest(&self, part: &Part) -> &str {
        &self.rules.iter().find(|p| p.pass(part)).unwrap().dest[..]
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
