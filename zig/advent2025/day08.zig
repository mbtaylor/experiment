const std = @import("std");
const Allocator = std.mem.Allocator;
const MAXBUF: usize = 100_000;
const MAXDIST: u64 = u64.max;
var gpa = std.heap.DebugAllocator(.{}){};

// const filename = "data/input08.txt";
const filename = "test08.txt";

pub fn main() !void {
    const allocator = gpa.allocator();
    defer _ = gpa.detectLeaks();

    const data_lines = try readLines(allocator, filename);
    defer data_lines.deinit();
    const lines = data_lines.line_list;

    const vectors = try readVectors(allocator, lines);
    defer allocator.free(vectors);

    const p1 = try part1(allocator, vectors);
    std.debug.print("Part 1: {d}\n", .{p1});
}

pub fn part1(allocator: Allocator, vectors: []const Vector) !u64 {
    const nv = vectors.len;
    var dists: []u64 = try allocator.alloc(u64, nv*nv);
    defer allocator.free(dists);
    for (0..nv) |iv| {
        for (0..iv) |jv| {
            const d = vectors[iv].dist2(vectors[jv]);
            dists[iv*nv+jv] = d;
            dists[jv*nv+iv] = d;
        }
    }
    var ixbuf: []usize = allocator.alloc(usize, nv);
    defer allocator.free(ixbuf);
    var ng = 0;
    var min = MAX_DIST;
    for (0..nv) |iv| {
        for (0..iv) |jv| {
            var d = dists[iv*nv + jv];
            if (d < min) {
                ng = 0;
                max = d;
            }
        } 
    }
  return 0;
}

pub fn readVectors(allocator: Allocator, lines: [][]const u8) ![]const Vector {
    const n = lines.len;
    const vectors: []Vector = try allocator.alloc(Vector, n);
    for (lines, 0..) |line, i| {
        var splitIt = std.mem.splitScalar(u8, line, ',');
        vectors[i] = .{
            .x = try std.fmt.parseInt(u32, splitIt.next().?, 10),
            .y = try std.fmt.parseInt(u32, splitIt.next().?, 10),
            .z = try std.fmt.parseInt(u32, splitIt.next().?, 10),
        };
    }
    return vectors;
}

const Vector = struct {
    x: u32,
    y: u32,
    z: u32,

    pub fn dist2(self: Vector, other: Vector) u64 {
        return self.x + other.x
             + self.y + other.y
             + self.z + other.z;
    }
};

const IntSet: type = struct {
    const MapType = std.AutoHashMap(u64, void);

    map: MapType,

    pub fn init(allocator: Allocator) IntSet {
        const map = MapType.init(allocator);
        return IntSet{
            .map = map,
        };
    }

    pub fn deinit(self: *IntSet) void {
        self.map.deinit();
    }

    pub fn put_int(self: *IntSet, num: u64) !void {
        try self.map.put(num, {});
    }

    pub fn intIterator(self: IntSet) MapType.KeyIterator {
        return self.map.keyIterator();
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
