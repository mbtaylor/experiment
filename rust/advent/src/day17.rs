
struct Field {
    rows: Vec<Vec<u8>>,
    xdim: usize,
    ydim: usize,
}

#[derive(Debug,Copy,Clone,Hash,PartialEq,Eq)]
enum Direction {
    N, W, S, E,
}

struct Point {
    x: usize,
    y: usize,
}

struct Path {
    dirs: Vec<Direction>,
    end: Point,
    score: i64,
}

struct PathSet {
    paths: Vec<Path>,
}

impl Field {
    fn from(lines: Vec<String>) -> Field {
        let mut rows: Vec<Vec<u8>> = Vec::new();
        for line in lines {
            let row = line.bytes().collect();
            rows.push(row)
        }
        let xdim = rows[0].len();
        let ydim = rows.len();
        Field{rows, xdim, ydim}
    }
    fn get(&self, ix: usize, iy: usize) -> u8 {
        self.rows[iy][ix]
    }
    fn next_point(&self, point: Point, dir: Direction) -> Option<Point> {
        match dir {
            Direction::N => {
               if y > 0 { Some(Point{x: self.x, y: self.y-1}) }
                   else { None }
            },
            Direction::W => {
                if x > 0 { Some(Point{x: self.x-1, y: self.y}) }
                   else { None }
            },
            Direction::S => {
                if y < self.ydim-1 { Some(Point{x: x, y: self.y+1}) }
                              else { None }
            },
            Direction::E => {
                if s < self.xdim-1 { Some(Point{x: self.x+1, self.y}) }
                              else { None }
            },
        }
    }
}

impl Path {
    fn init() -> Path {
        Path{dirs: Vec::new(), end: Point{x: 0, y:0}, score: 0}
    }
    fn add_dir(&self, dir: Direction) -> Option<Path> {
        let nd = self.dirs.len();
        if nd > 0 {
            let dir1 = self.dirs[nd-1];
            if dir==Direction::N && dir1==Direction::S or
               dir==Direction::W && dir1==Direction::E or
               dir==Direction::S && dir1==Direction::N or
               dir==Direction::E && dir1==Direction::W {
                return None;
            }
            if nd > 1 {
                let dir2 = self.dirs[nd-2];
                if dir1==dir && dir2==dir {
                    return None;
                }
            }
        }
        match field.next_point(self.end, dir) {
            None => None,
            Some(end) => {
                let dirs = self.dirs.clone();
                dirs.push(dir);
                let score = self.score + field.get(end);
                Path{dirs, end, score}
            }
        }
    }
}

fn find_paths(field: &Field, pathMap: HashMap<Point,PathSet>, point: Point)
        -> PathSet {
    let path0 = Path{dirs: Vec::new(), end: point, score: 0};
    if (point.x == 0 && point.y == 0) {
        PathSet{paths: vec!(path0)};
    }
    else {
        let paths: Vec<Path> = Vec::new();
        let all_dirs = [Direction::N, Direction::W, Direction::S, Direction::E];
        for dir in all_dirs {
            if let Some(path) = path0.add_dir(dir) {
            }


            if let Some(point1) = field.next_point(point, dir) {
                if let Some(path_set1) = pathMap.get(point1) {
                    for path1 in path_set1.paths {
                        let path2 = path1.clone();
                        path2.push(dir);
                        if path2.is_legal() {
                            paths.push(path2);
                        }
                    }
                }
            }
        }
    }
}

pub fn calc17a(lines: Vec<String>) -> i64 {
    let field = Field::from(lines);
    let path_map: HashMap<Point,PathSet> = HashMap::new();
}
