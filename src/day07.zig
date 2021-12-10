const std = @import("std");

const input = @embedFile("day07.input");

pub fn main() anyerror!void {
    const timer = try std.time.Timer.start();
    var pos_iter = std.mem.split(u8, input, ",");
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    var allocator = arena.allocator();
    defer arena.deinit();
    var positions = std.ArrayList(i64).init(allocator);

    var current: i64 = std.math.maxInt(i64);
    var end: i64 = 0;
    while (pos_iter.next()) |pos| {
        const num = try std.fmt.parseInt(i64, pos, 10);
        try positions.append(num);
        if (num < current) {
            current = num;
        } else if (num > end) {
            end = num;
        }
    }

    var p_1: i64 = std.math.maxInt(i64);
    var p_2: i64 = std.math.maxInt(i64);
    while (current <= end) : (current += 1) {
        var fuel_p_1: i64 = 0;
        var fuel_p_2: i64 = 0;
        for (positions.items) |pos| {
            const delta = try std.math.absInt(std.math.max(pos, current) - std.math.min(pos, current));
            fuel_p_1 += delta;
            fuel_p_2 += @divFloor(delta * (delta + 1), 2);
        }

        if (p_1 > fuel_p_1) {
            p_1 = fuel_p_1;
        }
        if (p_2 > fuel_p_2) {
            p_2 = fuel_p_2;
        }
    }

    const time = timer.read();
    std.debug.print("Part1: {}\n", .{p_1});
    std.debug.print("Part2: {}\n", .{p_2});
    std.debug.print("Runtime (excluding output): {}us\n", .{time / std.time.ns_per_us});
}
