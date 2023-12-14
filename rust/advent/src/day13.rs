use std::fmt::Display;
use std::fmt::Formatter;
use std::fmt::Result;

struct Field {
    rows: Vec<String>,
    cols: Vec<String>,
}

#[derive(PartialEq)]
struct Mirror {
    pos: usize,
    is_vertical: bool,
}

impl Mirror {
    fn score(&self) -> i64 {
        if self.is_vertical {
            self.pos as i64
        }
        else {
            self.pos as i64 * 100
        }
    }
}

impl Display for Field {
    fn fmt(&self, f: &mut Formatter<'_>) -> Result {
        for row in &self.rows {
            _ = writeln!(f, "{}", row);
        }
        Ok(())
    }
}

impl Field {
    fn from(lines: &Vec<String>) -> Field {
        let xdim = lines[0].len();
        let ydim = lines.len();
        let rows = lines.iter().map(|s| String::from(s)).collect();
        let mut cols = Vec::with_capacity(xdim);
        for ix in 0..xdim {
            let mut col = String::with_capacity(ydim);
            for line in lines {
                col.push(line.as_bytes()[ix] as char);
            }
            cols.push(col);
        }
        Field{rows, cols}
    }
    fn flip(&mut self, ix: usize, iy: usize) {
        let row = unsafe { self.rows[iy].as_bytes_mut() };
        let col = unsafe { self.cols[ix].as_bytes_mut() };
        assert_eq!(row[ix], col[iy]);
        let cell = row[ix];
        let flipped = Self::other(cell);
        row[ix] = flipped;
        col[iy] = flipped;
    }
    fn other(cell: u8) -> u8 {
        match cell {
            b'#' => b'.',
            b'.' => b'#',
            _ => panic!(),
        }
    }
    fn mirror_exclude(arrs: &Vec<String>, exclusion: &Option<usize>)
           -> Option<usize> {
        for i in 1..arrs.len() {
            for j in 0..arrs.len() {
                if j + 1 > i || i + j >= arrs.len() {
                    let result = Some(i);
                    if &result != exclusion {
                        return Some(i);
                    }
                    else {
                        break;
                    }
                }
                if arrs[i - j - 1] != arrs[i + j] {
                    break;
                }
            }
        }
        None
    }
    fn xmirror_exclude(&self, exclusion: &Option<Mirror>) -> Option<Mirror> {
        let pos_exclusion: Option<usize> = match exclusion {
            None => None,
            Some(mirror) => if mirror.is_vertical { Some(mirror.pos) }
                                              else { None },
        };
        match Self::mirror_exclude(&self.cols, &pos_exclusion) {
            None => None,
            Some(pos) => Some(Mirror{pos: pos, is_vertical: true}),
        }
    }
    fn ymirror_exclude(&self, exclusion: &Option<Mirror>) -> Option<Mirror> {
        let pos_exclusion: Option<usize> = match exclusion {
            None => None,
            Some(mirror) => if mirror.is_vertical { None }
                                             else { Some(mirror.pos) },
        };
        match Self::mirror_exclude(&self.rows, &pos_exclusion) {
            None => None,
            Some(pos) => Some(Mirror{pos: pos, is_vertical: false}),
        }
    }
}

fn read_fields(lines: Vec<String>) -> Vec<Field> {
    let mut fields: Vec<Field> = Vec::new();
    let mut field_lines: Vec<String> = Vec::new();
    for line in lines {
        if line.len() > 0 {
            field_lines.push(line);
        }
        else {
            if field_lines.len() > 0 {
                fields.push(Field::from(&field_lines));
            }
            field_lines.clear();
        }
    }
    if field_lines.len() > 0 {
        fields.push(Field::from(&field_lines));
    }
    fields
}

fn mirror_exclude(field: &Field, exclusion: &Option<Mirror>) -> Option<Mirror> {
    if let Some(mirror) = field.xmirror_exclude(exclusion) {
        Some(mirror)
    }
    else if let Some(mirror) = field.ymirror_exclude(exclusion) {
        Some(mirror)
    }
    else {
        None
    }
}

fn mirror_with_flip(field: &mut Field) -> Option<Mirror> {
    let smudged_mirror = mirror_exclude(field, &None);
    for iy in 0..field.rows.len() {
        for ix in 0..field.cols.len() {
            field.flip(ix, iy);
            let result = mirror_exclude(field, &smudged_mirror);
            field.flip(ix, iy);
            if result != None {
                return result;
            }
        }
    }
    None
}

pub fn calc13a(lines: Vec<String>) -> i64 {
    let fields = read_fields(lines);
    let mut tot: i64 = 0;
    for field in fields {
        tot += mirror_exclude(&field, &None).unwrap().score();
    }
    tot
}

pub fn calc13b(lines: Vec<String>) -> i64 {
    let fields = read_fields(lines);
    let mut tot = 0;
    for mut field in fields {
        tot += mirror_with_flip(&mut field).unwrap().score();
    }
    tot
}
