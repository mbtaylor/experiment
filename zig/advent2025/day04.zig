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
                    const px: isize = jx + dd[0];
                    const py: isize = jy + dd[1];
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
                        grid.putCell(jx, jy, '.');
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
    pad: usize,
    buf: []u8,
    nx: usize,
    ny: usize,

    pub fn init(allocator: Allocator, lines: [][]const u8) !Grid {
        const pad = 1;
        const ny = lines.len;
        const nx = lines[0].len;
        const buf = try allocator.alloc(u8, (nx+2*pad)*(ny+2*pad));
        for (0..buf.len) |i| {
            buf[i] = ' ';
        }
        const grid = Grid{
            .allocator = allocator,
            .pad = pad,
            .buf = buf,
            .nx = nx,
            .ny = ny,
        };
        for (lines, 0..) |line, iy| {
            const jy: isize = @intCast(iy);
            const mx: isize = @intCast(nx);
            const dest = grid.buf[grid.offset(0, jy)..grid.offset(mx, jy)];
            std.mem.copyForwards(u8, dest, line);
        }
        return grid;
    }

    pub fn offset(self: Grid, ix: isize, iy: isize) usize {
        const pad: isize = @intCast(self.pad);
        const nx: isize = @intCast(self.nx);
        return @intCast((pad+iy)*(2*pad+nx) + pad+ix);
    }

    pub fn deinit(self: Grid) void {
        self.allocator.free(self.buf);
    }

    pub fn getCell(self: Grid, ix: isize, iy: isize) u8 {
        return self.buf[self.offset(ix, iy)];
    }

    pub fn putCell(self: Grid, ix: isize, iy: isize, chr: u8) void {
        self.buf[self.offset(ix, iy)] = chr;
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
