const std = @import("std");

const input = @embedFile("day12.input");

fn containsSmallCaveTwice(visited: *std.StringArrayHashMap(u64)) bool {
    var iter = visited.iterator();
    while (iter.next()) |entry| {
        if (entry.key_ptr.*[0] > 'Z' and entry.value_ptr.* == 2) {
            return true;
        }
    }
    return false;
}

fn findPathsP1(connections: *const std.StringArrayHashMap(*std.ArrayList([]const u8)), current: []const u8, visited: *std.StringArrayHashMap(void)) anyerror!u64 {
    if (std.mem.eql(u8, current, "end")) {
        return 1;
    }

    if (!connections.contains(current)) {
        return 0;
    }

    try visited.put(current, {});
    var paths: usize = 0;
    for ((connections.get(current) orelse unreachable).items) |next| {
        const big_cave = next[0] <= 'Z';
        if (big_cave or !visited.contains(next)) {
            var visited_new = try visited.clone();
            paths += try findPathsP1(connections, next, &visited_new);
        }
    }

    return paths;
}

fn findPathsP2(connections: *const std.StringArrayHashMap(*std.ArrayList([]const u8)), current: []const u8, visited: *std.StringArrayHashMap(u64)) anyerror!u64 {
    if (std.mem.eql(u8, current, "end")) {
        return 1;
    }

    if (std.mem.eql(u8, current, "start") and visited.contains("start")) {
        return 0;
    }

    if (!connections.contains(current)) {
        return 0;
    }

    if (visited.contains(current)) {
        const big_cave = current[0] <= 'Z';
        if (big_cave) {
            try visited.put(current, (visited.get(current) orelse unreachable) + 1);
        } else {
            if (visited.get(current) orelse unreachable == 2 or containsSmallCaveTwice(visited)) {
                return 0;
            } else {
                try visited.put(current, (visited.get(current) orelse unreachable) + 1);
            }
        }
    } else {
        try visited.put(current, 1);
    }

    var paths: usize = 0;
    for ((connections.get(current) orelse unreachable).items) |next| {
        var visited_new = try visited.clone();
        paths += try findPathsP2(connections, next, &visited_new);
    }

    return paths;
}

pub fn main() anyerror!void {
    const timer = try std.time.Timer.start();
    var lines = std.mem.tokenize(u8, input, "\r\n");
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    var connections = std.StringArrayHashMap(*std.ArrayList([]const u8)).init(allocator);

    while (lines.next()) |line| {
        var caves = std.mem.split(u8, line, "-");
        const from = caves.next() orelse return error.ConnectionParseError;
        const to = caves.next() orelse return error.ConnectionParseError;
        if (connections.contains(from)) {
            try (connections.get(from) orelse unreachable).append(to);
        } else {
            var connected_caves = try allocator.create(std.ArrayList([]const u8));
            connected_caves.* = std.ArrayList([]const u8).init(allocator);
            try connections.put(from, connected_caves);
            try (connections.get(from) orelse unreachable).append(to);
        }

        if (connections.contains(to)) {
            try (connections.get(to) orelse unreachable).append(from);
        } else {
            var connected_caves = try allocator.create(std.ArrayList([]const u8));
            connected_caves.* = std.ArrayList([]const u8).init(allocator);
            try connections.put(to, connected_caves);
            try (connections.get(to) orelse unreachable).append(from);
        }
    }

    var p1 = try findPathsP1(&connections, "start", &std.StringArrayHashMap(void).init(allocator));
    var p2 = try findPathsP2(&connections, "start", &std.StringArrayHashMap(u64).init(allocator));

    const time = timer.read();
    std.debug.print("Part1: {}\n", .{p1});
    std.debug.print("Part2: {}\n", .{p2});
    std.debug.print("Runtime (excluding output): {}ms\n", .{time / std.time.ns_per_ms});
}
