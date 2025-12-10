const std = @import("std");
const Allocator = std.mem.Allocator;
const MAXBUF: usize = 100_000;
var gpa = std.heap.DebugAllocator(.{}){};

const filename = "data/input09.txt";

pub fn main() !void {
    const allocator = gpa.allocator();
    defer _ = gpa.detectLeaks();

    const data_lines = try readLines(allocator, filename);
    defer data_lines.deinit();
    const lines = data_lines.line_list;
    const points = try readPoints(allocator, lines);
    defer allocator.free(points);

    const fp1 = part1(points);
    const p1: u64 = @intFromFloat(fp1);    
    std.debug.print("Part 1: {d}\n", .{p1});
    const fp2 = part2(points);
    const p2: u64 = @intFromFloat(fp2);
    std.debug.print("Part 2: {d}\n", .{p2});
}

pub fn part1(points: []const Point) f64 {
    var max: f64 = 0;
    for (points) |p1| {
        for (points) |p2| {
            var m = (p1.x-p2.x+1)*(p1.y-p2.y+1);
            // where is abs??
            if (m < 0) {
                m = -m;
            }
            max = @max(m, max);
        }
    }
    return max;
}

pub fn part2(points: []const Point) f64 {
    var maxarea: f64 = 0;
    const np = points.len;
    for (0..np) |ip| {
        const p1 = points[ip];
        for (0..ip) |jp| {
            const p2 = points[jp];
            const rect = Rect.init(p1, p2);
            const v1 = Point.init(rect.xlo, rect.ylo);
            const v2 = Point.init(rect.xlo, rect.yhi);
            const v3 = Point.init(rect.xhi, rect.yhi);
            const v4 = Point.init(rect.xhi, rect.ylo);
            const sides: [4]Line = .{
                Line.init(v1, v2),
                Line.init(v2, v3),
                Line.init(v3, v4),
                Line.init(v4, v1),
            };
            const w1 = Point.init(rect.xlo + 0.5, rect.ylo + 0.5);
            const w2 = Point.init(rect.xlo + 0.5, rect.yhi - 0.5);
            const w3 = Point.init(rect.xhi - 0.5, rect.yhi - 0.5);
            const w4 = Point.init(rect.xhi - 0.5, rect.ylo + 0.5);
            const in_points: [4]Point = .{w1, w2, w3, w4};
            var is_inside = true;
            for (in_points) |w| {
                const l0 = Line.init(w, Point.init(w.x, -1));
                if (l0.crossCount(points) % 2 == 0) {
                    is_inside = false;
                    break;
                }
            }
            if (is_inside) {
                for (sides) |side| {
                    if (side.crossCount(points) > 0) {
                        is_inside = false;
                        break;
                    }
                }
            }
            if (is_inside) {
                const area = rect.area();
                maxarea = @max(maxarea, area);
            }
        }
    }
    return maxarea;
}

const Point = struct {
    x: f64,
    y: f64,

    pub fn init(x: f64, y: f64) Point {
        return Point{.x = x, .y = y,};
    }
};

const Line = struct {
    is_horiz: bool,
    a: f64,
    blo: f64,
    bhi: f64,

    pub fn init(p1: Point, p2: Point) Line {
        var is_horiz: bool = undefined;
        var a: f64 = undefined;
        var blo: f64 = undefined;
        var bhi: f64 = undefined;
        if (p1.y == p2.y) {
            is_horiz = true;
            a = p1.y;
            blo = if (p1.x < p2.x) p1.x else p2.x;
            bhi = if (p1.x < p2.x) p2.x else p1.x;
        }
        else if (p1.x == p2.x) {
            is_horiz = false;
            a = p1.x;
            blo = if (p1.y < p2.y) p1.y else p2.y;
            bhi = if (p1.y < p2.y) p2.y else p1.y;
        }
        else {
            unreachable;
        }
        return .{
            .is_horiz = is_horiz,
            .a = a,
            .blo = blo,
            .bhi = bhi,
        };
    }

    pub fn crossesLine(l1: Line, l2: Line) bool {
        var lh: Line = undefined;
        var lv: Line = undefined;
        if (l1.is_horiz and !l2.is_horiz) {
            lh = l1;
            lv = l2;
        }
        else if (!l1.is_horiz and l2.is_horiz) {
            lh = l2;
            lv = l1;
        }
        else {
            return false;
        }
        return lh.a > lv.blo and lh.a < lv.bhi and
               lh.blo < lv.a and lh.bhi > lv.a;
    }

    pub fn crossCount(self: Line, points: []const Point) u32 {
        const np = points.len;
        var ncross: u32 = 0;
        for (0..np) |ip| {
            const jp = (ip + 1) % np;
            if (self.crossesLine(Line.init(points[ip], points[jp]))) {
                ncross += 1;
            }
        }
        return ncross;
    }
};

const Rect = struct {
    xlo: f64,
    xhi: f64,
    ylo: f64,
    yhi: f64,

    pub fn init(p1: Point, p2: Point) Rect {
        const xlo = if (p1.x < p2.x) p1.x else p2.x;
        const xhi = if (p1.x < p2.x) p2.x else p1.x;
        const ylo = if (p1.y < p2.y) p1.y else p2.y;
        const yhi = if (p1.y < p2.y) p2.y else p1.y;
        return .{
            .xlo = xlo,
            .xhi = xhi,
            .ylo = ylo,
            .yhi = yhi,
        };
    }

    pub fn area(self: Rect) f64 {
        return (self.xhi - self.xlo + 1) * (self.yhi - self.ylo + 1);
    }
};

pub fn readPoints(allocator: Allocator, lines: [][]const u8) ![]const Point {
    const np = lines.len;
    var points: []Point = try allocator.alloc(Point, np);
    for (lines, 0..) |line, ip| {
        const ic = std.mem.indexOfScalar(u8, line, ',').?;
        const x = try std.fmt.parseFloat(f64, line[0..ic]);
        const y = try std.fmt.parseFloat(f64, line[ic+1..line.len]);
        points[ip] = Point{.x=x, .y=y};
    }
    return points;
}


fn readLines(allocator: Allocator, fname: []const u8) !DataLines {
    const content = try std.fs.cwd().readFileAlloc(allocator, fname, MAXBUF);
    var line_list: std.ArrayList([]const u8) = .empty;
    var splitIt = std.mem.splitScalar(u8, content, '\n');
    while (splitIt.next()) |line| {
        try line_list.append(allocator, line);
    }
    if (line_list.getLast().len == 0) {
        _ = line_list.pop();
    }
    return DataLines {
        .allocator = allocator,
        .line_list = try line_list.toOwnedSlice(allocator),
        .buf = content,
    };
}

const DataLines = struct {
    allocator: Allocator,
    line_list: [][]const u8,
    buf: []const u8,

    pub fn deinit(self: DataLines) void {
        self.allocator.free(self.line_list);
        self.allocator.free(self.buf);
    }
};
