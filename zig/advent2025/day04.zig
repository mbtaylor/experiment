const std = @import("std");
const Allocator = std.mem.Allocator;
const MAXBUF: usize = 100_000;
const neighbours: [8][2]isize = .{.{-1, -1}, .{ 0, -1}, .{ 1, -1},
                                  .{-1,  0},            .{ 1,  0},
                                  .{-1,  1}, .{ 0,  1}, .{ 1,  1}};

const filename = "data/input04.txt";
// const filename = "test04.txt";

pub fn main() !void {
    var gpa = std.heap.DebugAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.detectLeaks();

    const data_lines = try readLines(allocator, filename);
    defer data_lines.deinit();
    const lines = data_lines.line_list;
    const grid = Grid.init(lines);

    const p1 = part1(grid);
    std.debug.print("Part 1: {d}\n", .{p1});
}

pub fn part1(grid: Grid) usize {
    var naccess: usize = 0;
    for (0..grid.ny) |iy| {
        const jy: isize = @intCast(iy);
        for (0..grid.nx) |ix| {
            const jx: isize = @intCast(ix);
            if (grid.cell(jx, jy) == '@') {
                var nn: usize = 0;
                for (neighbours) |dd| {
                    const px = jx + dd[0];
                    const py = jy + dd[1];
                    const c = grid.cell(px, py);
                    if (c == '@') {
                        nn += 1;
                    }
                }
                if (nn < 4) {
                    naccess += 1;
                }
            }
        }
    }
    return naccess;
}

const Grid = struct {
    lines: [][]const u8,
    nx: usize,
    ny: usize,

    pub fn init(lines: [][]const u8) Grid {
        return Grid{
            .lines = lines,
            .nx = lines.len,
            .ny = lines[0].len,
        };
    }

    pub fn cell(self: Grid, ix: isize, iy: isize) u8 {
        if (ix >= 0 and ix < self.nx and iy >= 0 and iy < self.ny) {
            const jx: usize = @intCast(ix);
            const jy: usize = @intCast(iy);
            return self.lines[jy][jx];
        }
        else {
            return ' ';
        }
    }
};

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
