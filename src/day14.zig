const std = @import("std");

const input = @embedFile("day14.input");

pub fn main() anyerror!void {
    const timer = try std.time.Timer.start();
    var blocks = std.mem.split(u8, input, "\n\n");
    const template = blocks.next().?;
    var lines = std.mem.tokenize(u8, blocks.next().?, "\r\n");
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    var rules = std.StringArrayHashMap(u8).init(allocator);
    var element_counts = std.AutoHashMap(u8, u128).init(allocator);
    var pair_counts = std.StringArrayHashMap(u128).init(allocator);
    var p1: u128 = 0;

    while (lines.next()) |line| {
        var parts = std.mem.split(u8, line, " -> ");
        const pair = parts.next().?;
        const new_element = (parts.next().?)[0];
        try rules.put(pair, new_element);
        try pair_counts.put(pair, 0);
    }
    var new_counts = try pair_counts.clone();

    for (template) |element, idx| {
        try element_counts.put(element, (element_counts.get(element) orelse 0) + 1);
        if (idx == template.len - 1) {
            break;
        }
        const pair = template[idx .. idx + 2];
        try pair_counts.put(pair, (pair_counts.get(pair) orelse 0) + 1);
    }

    var step: usize = 0;
    while (step < 40) : (step += 1) {
        var iter = pair_counts.iterator();
        while (iter.next()) |entry| {
            const new_element = rules.get(entry.key_ptr.*).?;
            try element_counts.put(new_element, (element_counts.get(new_element) orelse 0) + entry.value_ptr.*);
            const new_pair_left = [_]u8{ entry.key_ptr.*[0], new_element };
            const new_pair_right = [_]u8{ new_element, entry.key_ptr.*[1] };
            try new_counts.put(&new_pair_left, new_counts.get(&new_pair_left).? + entry.value_ptr.*);
            try new_counts.put(&new_pair_right, new_counts.get(&new_pair_right).? + entry.value_ptr.*);
        }

        iter.reset();
        while (iter.next()) |entry| {
            try pair_counts.put(entry.key_ptr.*, new_counts.get(entry.key_ptr.*).?);
            try new_counts.put(entry.key_ptr.*, 0);
        }

        if (step == 9) {
            var p1_most_common: u128 = 0;
            var p1_least_common: u128 = std.math.maxInt(u128);
            var counts_iter = element_counts.iterator();
            while (counts_iter.next()) |entry| {
                if (entry.value_ptr.* > p1_most_common) {
                    p1_most_common = entry.value_ptr.*;
                }
                if (entry.value_ptr.* < p1_least_common) {
                    p1_least_common = entry.value_ptr.*;
                }
            }
            p1 = p1_most_common - p1_least_common;
        }
    }

    var p2_most_common: u128 = 0;
    var p2_least_common: u128 = std.math.maxInt(u128);
    var iter = element_counts.iterator();
    while (iter.next()) |entry| {
        if (entry.value_ptr.* > p2_most_common) {
            p2_most_common = entry.value_ptr.*;
        }
        if (entry.value_ptr.* < p2_least_common) {
            p2_least_common = entry.value_ptr.*;
        }
    }

    const time = timer.read();
    std.debug.print("Part1: {}\n", .{p1});
    std.debug.print("Part2: {}\n", .{p2_most_common - p2_least_common});
    std.debug.print("Runtime (excluding output): {}us\n", .{time / std.time.ns_per_us});
}
