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

const Point = struct {
    x: f64,
    y: f64,
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
