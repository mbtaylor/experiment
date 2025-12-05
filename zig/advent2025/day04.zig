const std = @import("std");
const Allocator = std.mem.Allocator;
const MAXBUF: usize = 100_000;
const neighbours: [8][2]isize = .{.{-1, -1}, .{ 0, -1}, .{ 1, -1},
                                  .{-1,  0},            .{ 1,  0},
                                  .{-1,  1}, .{ 0,  1}, .{ 1,  1}};

const filename = "data/input04.txt";

pub fn main() !void {
    var gpa = std.heap.DebugAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.detectLeaks();

    const data_lines = try readLines(allocator, filename);
    defer data_lines.deinit();
    const lines = data_lines.line_list;
    const grid = try Grid.init(allocator, lines);
    defer grid.deinit();

    const p1 = part1(grid);
    std.debug.print("Part 1: {d}\n", .{p1});
    const p2 = part2(grid);
    std.debug.print("Part 2: {d}\n", .{p2});
}

pub fn part1(grid: Grid) usize {
    var naccess: usize = 0;
    for (0..grid.ny) |iy| {
        const jy: isize = @intCast(iy);
        for (0..grid.nx) |ix| {
            const jx: isize = @intCast(ix);
            if (grid.getCell(jx, jy) == '@') {
                var nn: usize = 0;
                for (neighbours) |dd| {
                    const px = jx + dd[0];
                    const py = jy + dd[1];
                    const c = grid.getCell(px, py);
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

pub fn part2(grid: Grid) usize {
    var tot: usize = 0;
    while (true) {
        var nremove: usize = 0;
        for (0..grid.ny) |iy| {
            const jy: isize = @intCast(iy);
            for (0..grid.nx) |ix| {
                const jx: isize = @intCast(ix);
                if (grid.getCell(jx, jy) == '@') {
                    var nn: usize = 0;
                    for (neighbours) |dd| {
                        const px = jx + dd[0];
                        const py = jy + dd[1];
                        const c = grid.getCell(px, py);
                        if (c == '@') {
                            nn += 1;
                        }
                    }
                    if (nn < 4) {
                        nremove += 1;
                        grid.putCell(ix, iy, '.');
                    }
                }
            }
        }
        if (nremove == 0) {
            return tot;
        }
        tot += nremove;
    }
}

const Grid = struct {
    allocator: Allocator,
    lines: [][] u8,
    nx: usize,
    ny: usize,

    pub fn init(allocator: Allocator, lines: [][]const u8) !Grid {
        const ny = lines.len;
        const nx = lines[0].len;
        const copy_lines: [][]u8 = try allocator.alloc([]u8, lines.len);
        for (lines, 0..) |line, i| {
            const copy_line: []u8 = try allocator.alloc(u8, nx);
            std.mem.copyForwards(u8, copy_line, line);
            copy_lines[i] = copy_line;
        }
        return Grid{
            .allocator = allocator,
            .lines = copy_lines,
            .nx = nx,
            .ny = ny,
        };
    }

    pub fn deinit(self: Grid) void {
        for (self.lines) |line| {
            self.allocator.free(line);
        }
        self.allocator.free(self.lines);
    }

    pub fn getCell(self: Grid, ix: isize, iy: isize) u8 {
        if (ix >= 0 and ix < self.nx and iy >= 0 and iy < self.ny) {
            const jx: usize = @intCast(ix);
            const jy: usize = @intCast(iy);
            return self.lines[jy][jx];
        }
        else {
            return ' ';
        }
    }

    pub fn putCell(self: Grid, ix: usize, iy: usize, chr: u8) void {
        self.lines[iy][ix] = chr;
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
