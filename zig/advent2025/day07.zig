const std = @import("std");
const Allocator = std.mem.Allocator;
const MAXBUF: usize = 100_000;

const filename = "data/input07.txt";

pub fn main() !void {
    var gpa = std.heap.DebugAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.detectLeaks();

    const data_lines = try readLines(allocator, filename);
    defer data_lines.deinit();
    const lines = data_lines.line_list;

    const grid = try Grid.init(allocator, lines);
    defer grid.deinit();

    const answer = calculate(grid);
    const p1 = answer[0];
    std.debug.print("Part 1: {d}\n", .{p1});
    const p2 = answer[1];
    std.debug.print("Part 2: {d}\n", .{p2});
}

// This is a little bit of a mess, the calculations could be streamlined
// and one of the arrays doesn't need to be allocated.
pub fn calculate(grid: Grid) [2]u64 {
    const nx = grid.nx;
    const ny = grid.ny;
    const spos = std.mem.indexOfScalar(u8, grid.buf[0..nx], 'S').?;
    grid.setChar(spos, 1, '|');
    grid.addCount(spos, 1, @as(u64, 1));
    var nsplit: usize = 0;
    for (1..ny-1) |iy| {
        for (0..nx) |ix| {
            if (grid.getChar(ix, iy) == '|') {
                const count0 = grid.getCount(ix, iy);
                switch (grid.getChar(ix, iy+1)) {
                    '^' => {
                        grid.setChar(ix-1, iy+1, '|');
                        grid.setChar(ix+1, iy+1, '|');
                        grid.addCount(ix-1, iy+1, count0);
                        grid.addCount(ix+1, iy+1, count0);
                        nsplit += 1;
                    },
                    '.', '|' => {
                        grid.setChar(ix, iy+1, '|');
                        grid.addCount(ix, iy+1, count0);
                    },
                    else => {
                        unreachable;
                    }
                }
            }
        }
    }
    var npath: u64 = 0;
    for (0..nx) |ix| {
        npath += grid.getCount(ix, ny-1);
    }
    return [2]u64 {nsplit, npath};
}

const Grid = struct {
    allocator: Allocator,
    nx: usize,
    ny: usize,
    buf: []u8,
    counts: []u64,

    pub fn init(allocator: Allocator, lines: [][]const u8) !Grid {
        const nx = lines[0].len;
        const ny = lines.len;
        const buf = try allocator.alloc(u8, nx*ny);
        for (lines, 0..) |line, iy| {
            std.mem.copyForwards(u8, buf[iy*nx..(iy+1)*nx], line);
        }
        const counts = try allocator.alloc(u64, nx*ny);
        for (0..nx*ny) |i| {
            counts[i] = 0;
        }
        return Grid {
            .allocator = allocator,
            .nx = nx,
            .ny = ny,
            .buf = buf,
            .counts = counts,
        };
    }

    pub fn getChar(self: Grid, ix: usize, iy: usize) u8 {
        return self.buf[iy*self.nx + ix];
    }

    pub fn setChar(self:Grid, ix: usize, iy: usize, c: u8) void {
        self.buf[iy*self.nx + ix] = c;
    }

    pub fn getCount(self: Grid, ix: usize, iy: usize) u64 {
        return self.counts[iy*self.nx + ix];
    }

    pub fn addCount(self: Grid, ix: usize, iy: usize, inc: u64) void {
        self.counts[iy*self.nx + ix] += inc;
    }

    pub fn deinit(self: Grid) void {
        self.allocator.free(self.buf);
        self.allocator.free(self.counts);
    }

    pub fn print(self: Grid) void {
        for (0..self.ny) |iy| {
            std.debug.print("{s}\n", .{self.buf[iy*self.nx..(iy+1)*self.nx]});
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
