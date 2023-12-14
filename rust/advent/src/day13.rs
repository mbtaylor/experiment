
struct Field {
    rows: Vec<String>,
    cols: Vec<String>,
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
    fn mirror(arrs: &Vec<String>) -> Option<usize> {
        for i in 1..arrs.len() {
            for j in 0..arrs.len() {
                if j + 1 > i || i + j >= arrs.len() {
                    return Some(i);
                }
                if arrs[i - j - 1] != arrs[i + j] {
                    break;
                }
            }
        }
        None
    }
    fn xmirror(&self) -> Option<usize> {
        Self::mirror(&self.cols)
    }
    fn ymirror(&self) -> Option<usize> {
        Self::mirror(&self.rows)
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

pub fn calc13a(lines: Vec<String>) -> i64 {
    let fields = read_fields(lines);
    let mut tot: i64 = 0;
    for field in fields {
        if let Some(jx) = field.xmirror() {
            tot += jx as i64
        }
        else if let Some(jy) = field.ymirror() {
            tot += 100 * jy as i64;
        }
    }
    tot
}
