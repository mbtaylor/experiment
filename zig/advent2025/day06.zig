const std = @import("std");
const Allocator = std.mem.Allocator;
const MAXBUF: usize = 100_000;
var gpa = std.heap.DebugAllocator(.{}){};

// const filename = "data/input06.txt";
const filename = "test06.txt";

pub fn main() !void {
    const allocator = gpa.allocator();
    defer _ = gpa.detectLeaks();

    const data_lines = try readLines(allocator, filename);
    defer data_lines.deinit();
    const lines = data_lines.line_list;
    const input = try Input.init(allocator, lines);
    defer input.deinit();
}

fn readWords(allocator: Allocator, line: []const u8) ![][]const u8 {
    var words: std.ArrayList([]const u8) = .empty;
    var splitit = std.mem.splitScalar(u8, line, ' ');
    while (splitit.next()) |word| {
        if (word.len > 0) {
            try words.append(allocator, word);
        }
    }
    return try words.toOwnedSlice(allocator);
}

const Input = struct {
    allocator: Allocator,
    nx: usize,
    ny: usize,
    grid: []const u32,
    ops: []const u8,

    pub fn init(allocator: Allocator, lines: [][]const u8) !Input {
        const ny = lines.len - 1;
        const words0 = try readWords(allocator, lines[0]);
        const nx = words0.len;
        allocator.free(words0);
        const grid = try allocator.alloc(u32, nx * ny);
        const ops = try allocator.alloc(u8, nx);
        for (lines[0..ny], 0..) |line, iy| {
            const num_words = try readWords(allocator, line);
            for (num_words, 0..) |word, ix| {
                grid[iy * nx + ix] = try std.fmt.parseInt(u32, word, 10);
            }
            allocator.free(num_words);
        }
        const op_words = try readWords(allocator, lines[ny-1]);
        for (op_words, 0..) |word, ix| {
            ops[ix] = word[0];
        }
        allocator.free(op_words);
        return Input{
            .allocator = allocator,
            .nx = nx,
            .ny = ny,
            .grid = grid,
            .ops = ops,
        };
    }

    pub fn deinit(self: Input) void {
        self.allocator.free(self.grid);
        self.allocator.free(self.ops);
    }

    pub fn num(self: Input, ix: usize, iy: usize) u32 {
        return self.grid[iy * self.nx + ix];
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
