const std = @import("std");
const Allocator = std.mem.Allocator;
const MAXBUF: usize = 100_000;
var gpa = std.heap.DebugAllocator(.{}){};

const filename = "data/input12.txt";
// const filename = "test12.txt";

const L: usize = 3;   // linear extent of square present grid

pub fn main() !void {
    const allocator = gpa.allocator();
    defer _ = gpa.detectLeaks();

    const data_lines = try readLines(allocator, filename);
    defer data_lines.deinit();
    const lines = data_lines.line_list;

    const problem = try Problem.init(allocator, lines);
    defer problem.deinit();

    report(problem);
}

pub fn report(prob: Problem) void {
    std.debug.print("ntree: {d}\n", .{prob.trees.len});
    std.debug.print("npres: {d}\n", .{prob.presents.len});

    var npossible: usize = 0;
    var maxpack: f32 = 0;
    for (prob.trees, 0..) |tree, i| {
        var nblock: usize = 0;
        for (tree.counts, prob.presents) |count, present| {
            nblock += count * present.size();
        }
        const tree_size = tree.size();
        const possible = nblock <= tree_size;
        const possible_flag: u8 = if (possible) '@' else ':';
        var packing: f32 = @floatFromInt(nblock);
        packing /= @floatFromInt(tree_size);
        if (possible) {
            npossible += 1;
            maxpack = @max(packing, maxpack);
        }
        std.debug.print("{d}:\t{d}\t{d}\t{c}\t{d:4.3}\n",
                        .{i, tree_size, nblock, possible_flag, packing});
    }
    std.debug.print("npossible: {d}\n", .{npossible});
    std.debug.print("max packing fraction for possibles: {d:4.3}\n",
                    .{maxpack});
}

const Problem = struct {
    allocator: Allocator,
    presents: []const Present,
    trees: []const Tree,

    pub fn init(allocator: Allocator, lines: [][]const u8) !Problem {
        var presents: std.ArrayList(Present) = .empty;
        var trees: std.ArrayList(Tree) = .empty;
        var il: usize = 0;
        while (il < lines.len) {
            const line = lines[il];
            if (line[1] == ':') {
                var grid: [L*L]u8 = undefined;
                for (0..L) |i| {
                    std.mem.copyForwards(u8, grid[i*L..(i+1)*L], lines[il+1+i]);
                }
                il += L + 2;
                try presents.append(allocator, Present{.grid = grid});
            }
            else if (std.mem.indexOfScalar(u8, line, 'x')) |ix| {
                const ic = std.mem.indexOfScalar(u8, line, ':').?;
                const shape: [2]u8 = .{
                    try std.fmt.parseInt(u8, line[0..ix], 10),
                    try std.fmt.parseInt(u8, line[ix+1..ic], 10),
                };
                var count_list: std.ArrayList(u8) = .empty;
                var it = std.mem.splitScalar(u8, line[ic+2..line.len], ' ');
                while (it.next()) |word| {
                    try count_list.append(allocator,
                                          try std.fmt.parseInt(u8, word, 10));
                }
                const counts = try count_list.toOwnedSlice(allocator);
                try trees.append(allocator,
                                 Tree{.shape = shape, .counts = counts});
                il = il + 1;
            }
            else {
                unreachable;
            }
        }
        return .{
            .allocator = allocator,
            .presents = try presents.toOwnedSlice(allocator),
            .trees = try trees.toOwnedSlice(allocator),
        };
    }

    pub fn deinit(self: Problem) void {
        for (self.trees) |tree| {
            self.allocator.free(tree.counts);
        }
        self.allocator.free(self.presents);
        self.allocator.free(self.trees);
    }
};

const Present = struct {
    grid: [L*L]u8,

    pub fn size(self: Present) usize {
        return std.mem.count(u8, &self.grid, "#");
    }
};

const Tree = struct {
    shape: [2] u8,
    counts: []const u8,

    pub fn size(self: Tree) usize {
        return @as(usize,self.shape[0]) * @as(usize,self.shape[1]);
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
