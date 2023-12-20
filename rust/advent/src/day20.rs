use regex::Regex;
use std::collections::HashMap;

enum Component {
    Broadcaster {
        name: String,
        outputs: Vec<String>,
    },
    FlipFlop {
        name: String,
        outputs: Vec<String>,
        is_on: bool,
    },
    Conjunction {
        name: String,
        outputs: Vec<String>,
        inputs: HashMap<String,bool>,
    },
    Output {
        name: String,
        outputs: Vec<String>,
    },
}

#[derive(Debug,Clone)]
struct Pulse {
    src: String,
    target: String,
    is_high: bool,
}

impl Component {
    fn pulses(src: &str, targets: &Vec<String>, send_high: bool) -> Vec<Pulse> {
        targets.iter()
               .map(|t| Pulse{
                            src: String::from(src),
                            target: t.clone(),
                            is_high: send_high,
                        })
               .collect()
    }
    fn receive(&mut self, src: &str, is_high: bool) -> Vec<Pulse> {
        match self {
            Component::Broadcaster{name, outputs} => {
                Self::pulses(&name[..], &outputs, is_high)
            },
            Component::FlipFlop{name, outputs, ref mut is_on} => {
                if !is_high {
                    *is_on = !*is_on;
                    let send_high = *is_on;
                    Self::pulses(&name[..], &outputs, send_high)
                }
                else {
                    vec!()
                }
            },
            Component::Conjunction{name, outputs, inputs} => {
                inputs.insert(String::from(src), is_high)
                      .expect("unknown input");
                let all_high = inputs.values().all(|v| *v);
                let send_high = !all_high;
                Self::pulses(&name[..], &outputs, send_high)
            },
            Component::Output{..} => {
                vec![]
            },
        }
    }
    fn outputs(&self) -> &Vec<String> {
        match self {
            Component::Broadcaster{outputs, ..} => outputs,
            Component::FlipFlop{outputs, ..} => outputs,
            Component::Conjunction{outputs, ..} => outputs,
            Component::Output{outputs, ..} => outputs,
        }
    }
    fn name(&self) -> &str {
        match self {
            Component::Broadcaster{name, ..} => &name[..],
            Component::FlipFlop{name, ..} => &name[..],
            Component::Conjunction{name, ..} => &name[..],
            Component::Output{name, ..} => &name[..],
        }
    }
}

fn propagate_pulses(comp_map: &mut HashMap<String,Component>,
                    pulses: Vec<Pulse>) -> Vec<Pulse> {
    let mut next_pulses = Vec::new();
    for pulse in pulses {
        if let Some(target_comp) = comp_map.get_mut(&pulse.target[..]) {
            for p in target_comp.receive(&pulse.src[..], pulse.is_high) {
                next_pulses.push(p);
            }
        }
    }
    next_pulses
}

fn button_pulse() -> Pulse {
    Pulse{
        src: String::from("button"),
        target: String::from("broadcaster"),
        is_high: false
    }
}

fn read_network(lines: Vec<String>) -> HashMap<String,Component> {
    let line_re = Regex::new("([%&]?)([a-z]+) -> ([a-z, ]+)").unwrap();
    let output_re = Regex::new(" *([a-z]+),? *").unwrap();
    let mut comp_map: HashMap<String,Component> = HashMap::new();
    let output = Component::Output{
        name: String::from("output"),
        outputs: vec![],
    };
    comp_map.insert(String::from("output"), output);
    for line in lines {
        let (_, [ctype, name, outputs_txt]) =
            line_re.captures(&line[..]).unwrap().extract();
        let name = String::from(name);
        let mut outputs: Vec<String> = Vec::new();
        for cap in output_re.captures_iter(outputs_txt) {
            let (_, [output]) = cap.extract();
            outputs.push(String::from(output));
        }
        comp_map.insert(name.clone(), match &ctype[..] {
            "%" => {
                Component::FlipFlop{name, outputs, is_on: false}
            },
            "&" => {
                Component::Conjunction{name, outputs, inputs: HashMap::new()}
            },
            "" => {
                if &name[..] == "broadcaster" {
                    Component::Broadcaster{name: name, outputs: outputs}
                }
                else {
                    panic!()
                }
            },
            _ => panic!(),
        });
    }
    let mut inputs_map: HashMap<String,Vec<String>> = HashMap::new();
    for c in comp_map.values() {
        if let Component::Conjunction{name, ..} = c {
            inputs_map.insert(name.clone(), Vec::new());
        }
    }
    for c in comp_map.values() {
        for output in c.outputs() {
            if let Some(outs_vec) = inputs_map.get_mut(output) {
                outs_vec.push(String::from(c.name()));
            }
        }
    }
    for c in comp_map.values_mut() {
        if let Component::Conjunction{name, ref mut inputs, ..} = c {
            for input in inputs_map.get(&name[..]).unwrap() {
                inputs.insert(String::from(input), false);
            }
        }
    }
    comp_map
}

pub fn calc20a(lines: Vec<String>) -> i64 {
    let mut comp_map = read_network(lines);
    let mut nlo: i64 = 0;
    let mut nhi: i64 = 0;
    for i in 0..1000 {
        let mut pulses: Vec<Pulse> = vec!(button_pulse());
        nlo += 1;
        while pulses.len() > 0 {
            pulses = propagate_pulses(&mut comp_map, pulses);
            for pulse in &pulses {
                if pulse.is_high {
                    nhi += 1;
                }
                else {
                    nlo += 1;
                }
            }
        }
    }
    nlo * nhi
}
