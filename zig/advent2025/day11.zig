const std = @import("std");
const Allocator = std.mem.Allocator;
const MAXBUF: usize = 100_000;
var gpa = std.heap.DebugAllocator(.{}){};

const Node = [3]u8;
const DeviceMap = std.AutoHashMap(Node, Device);

const filename = "data/input11.txt";

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

    const p1 = try part1(allocator, devices);
    std.debug.print("Part 1: {d}\n", .{p1});
}

pub fn part1(allocator: Allocator, devices: []const Device) !usize {
    const out_node = [3]u8 {'o', 'u', 't'};
    const you_node = [3]u8 {'y', 'o', 'u'};
    return try countToTarget(allocator, devices, you_node, out_node);
}

pub fn countToTarget(allocator: Allocator, devices: []const Device,
                     from: Node, target: Node) !usize {
    var map: DeviceMap = DeviceMap.init(allocator);
    defer map.deinit();
    for (devices) |device| {
        try map.put(device.id, device);
    }
    return countToTargetMap(map, from, target);
}

pub fn countToTargetMap(map: DeviceMap, from: Node, target: Node) usize {
    var device = map.getPtr(from).?;
    if (device.count_to_target) |count| {
        return count;
    }
    else {
        var count: usize = 0;
        if (std.mem.eql(u8, &device.outputs[0], &target)) {
            count = 1;
        }
        else {
            var sum: usize = 0;
            for (device.outputs) |next| {
                sum += countToTargetMap(map, next, target);
            }
            count = sum;
        }
        device.count_to_target = count;
        return count;
    }
}

pub fn toNode(txt: []const u8) Node {
    return .{txt[0], txt[1], txt[2]};
}

const Device = struct {
    allocator: Allocator,
    id: Node,
    outputs: []Node,
    count_to_target: ?usize = null,

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
