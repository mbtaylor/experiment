const std = @import("std");
const Allocator = std.mem.Allocator;
const MAXBUF: usize = 100_000;
const MAXDIST: u64 = u64.max;
var gpa = std.heap.DebugAllocator(.{}){};

// const filename: []const u8 = "data/input08.txt;
// const np: usize = 1000;
const filename = "test08.txt";
const np: usize = 10;

// Not working.  There's clearly something that I don't understand
// about HashMaps.
// Try reading this good reference:
//   https://www.openmymind.net/Zigs-HashMap-Part-1/
// and have another go later.

pub fn main() !void {
    const allocator = gpa.allocator();
//  defer _ = gpa.detectLeaks();

    const data_lines = try readLines(allocator, filename);
    defer data_lines.deinit();
    const lines = data_lines.line_list;

    const vectors = try readVectors(allocator, lines);
    defer allocator.free(vectors);

    const p1 = try part1(allocator, vectors, np);
    std.debug.print("Part 1: {d}\n", .{p1});
}

pub fn part1(allocator: Allocator, vectors: []const Vector, npair: usize) !u64 {
    const nv = vectors.len;
    var pairs: []Pair = try allocator.alloc(Pair, nv * (nv-1));
    defer allocator.free(pairs);
    var ip: usize = 0;
    for (0..nv) |iv| {
        const v1 = vectors[iv];
        for (0..iv) |jv| {
            const v2 = vectors[jv];
            pairs[ip] = .{
                .iv1 = jv,
                .iv2 = iv,
                .dist2 = v1.dist2(v2),
            };
            ip += 1;
        }
    }
    std.mem.sort(Pair, pairs, {}, Pair.cmpByDistance);

    var group_list: std.ArrayList(*IntSet) = .empty;
    for (pairs[0..npair]) |pair| {
        var added = false;
        for (group_list.items) |grp| {
            if (grp.map.contains(pair.iv1)) {
                try grp.putInt(pair.iv2);
                added = true;
            }
            if (grp.map.contains(pair.iv2)) {
                try grp.putInt(pair.iv1);
                added = true;
            }
        }
        if (!added) {
            var group = IntSet.init(allocator);
            try group.putInt(pair.iv1);
            try group.putInt(pair.iv2);
            try group_list.append(allocator, &group);
        }
    }
    const groups = try group_list.toOwnedSlice(allocator);
    defer {
//      for (groups) |group| {
//          group.deinit();
//      }
        allocator.free(groups);
    }
    std.mem.sort(*IntSet, groups, {}, IntSet.cmpBySize);
  for (groups) |group| {
    std.debug.print("    {d}\n", .{group.map.count()});
    group.print();
  }
    return groups[0].map.count()
         * groups[1].map.count()
         * groups[2].map.count();
}

pub fn readVectors(allocator: Allocator, lines: [][]const u8) ![]const Vector {
    const n = lines.len;
    const vectors: []Vector = try allocator.alloc(Vector, n);
    for (lines, 0..) |line, i| {
        var splitIt = std.mem.splitScalar(u8, line, ',');
        vectors[i] = .{
            .x = try std.fmt.parseInt(i32, splitIt.next().?, 10),
            .y = try std.fmt.parseInt(i32, splitIt.next().?, 10),
            .z = try std.fmt.parseInt(i32, splitIt.next().?, 10),
        };
    }
    return vectors;
}

const Vector = struct {
    x: i32,
    y: i32,
    z: i32,

    pub fn dist2(self: Vector, other: Vector) u64 {
        const dx = self.x - other.x;
        const dy = self.y - other.y;
        const dz = self.z - other.z;
        return @intCast(dx*dx + dy*dy + dz*dz);
    }
};

const Pair = struct {
    iv1: usize,
    iv2: usize,
    dist2: u64,

    fn cmpByDistance(context: void, p1: Pair, p2: Pair) bool {
        return std.sort.asc(u64)(context, p1.dist2, p2.dist2);
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

    pub fn putInt(self: *IntSet, num: usize) !void {
        try self.map.put(@intCast(num), {});
    }

    pub fn intIterator(self: IntSet) MapType.KeyIterator {
        return self.map.keyIterator();
    }

    fn cmpBySize(context: void, s1: *IntSet, s2: *IntSet) bool {
        return std.sort.desc(usize)(context, s1.map.count(), s2.map.count());
    }

    pub fn print(self: IntSet) void {
        var it = self.map.keyIterator();
        while (it.next()) |key| {
            std.debug.print(" {}", .{key});
        }
        std.debug.print("\n", .{});
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
