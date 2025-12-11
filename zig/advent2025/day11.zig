const std = @import("std");
const Allocator = std.mem.Allocator;
const MAXBUF: usize = 100_000;
var gpa = std.heap.DebugAllocator(.{}){};

const Node = [3]u8;

// const filename = "data/input11.txt";
const filename = "test11.txt";

pub fn main() !void {
    const allocator = gpa.allocator();
    defer _ = gpa.detectLeaks();

    const data_lines = try readLines(allocator, filename);
    defer data_lines.deinit();
    const lines = data_lines.line_list;

    const devices = try readDevices(allocator, lines);
    defer {
        for (devices) |device| {
            device.deinit();
        }
        allocator.free(devices);
    }
}

pub fn toNode(txt: []const u8) Node {
    return .{txt[0], txt[1], txt[2]};
}

const Device = struct {
    allocator: Allocator,
    id: Node,
    outputs: []Node,

    pub fn deinit(self: Device) void {
        self.allocator.free(self.outputs);
    }
};

pub fn readDevices(allocator: Allocator, lines: [][]const u8) ![]const Device {
    var device_list: std.ArrayList(Device) = .empty;
    for (lines) |line| {
        const icolon = std.mem.indexOfScalar(u8, line, ':').?;
        const id = toNode(line[0..icolon]);
        var split_it = std.mem.splitScalar(u8, line[icolon+2..line.len], ' ');
        var node_list: std.ArrayList(Node) = .empty;
        while (split_it.next()) |word| {
            try node_list.append(allocator, toNode(word));
        }
        const outputs = try node_list.toOwnedSlice(allocator);
        const device = Device {
            .allocator = allocator,
            .id = id,
            .outputs = outputs,
        };
        try device_list.append(allocator, device);
    }
    const devices = try device_list.toOwnedSlice(allocator);
    return devices;
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

