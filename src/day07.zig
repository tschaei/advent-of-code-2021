const std = @import("std");

const input = @embedFile("day07.input");

pub fn main() anyerror!void {
    const timer = try std.time.Timer.start();
    var positionsIter = std.mem.split(u8, input, ",");
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    var positions = std.ArrayList(i64).init(&gpa.allocator);
    defer positions.deinit();

    var current: i64 = std.math.maxInt(i64);
    var end: i64 = 0;
    while (positionsIter.next()) |pos| {
        const num = try std.fmt.parseInt(i64, pos, 10);
        try positions.append(num);
        if (num < current) {
            current = num;
        } else if (num > end) {
            end = num;
        }
    }

    var p1: i64 = std.math.maxInt(i64);
    var p2: i64 = std.math.maxInt(i64);
    while (current <= end) : (current += 1) {
        var fuelP1: i64 = 0;
        var fuelP2: i64 = 0;
        for (positions.items) |pos| {
            const delta = try std.math.absInt(std.math.max(pos, current) - std.math.min(pos, current));
            fuelP1 += delta;
            fuelP2 += @divFloor(delta * (delta + 1), 2);
        }

        if (p1 > fuelP1) {
            p1 = fuelP1;
        }
        if (p2 > fuelP2) {
            p2 = fuelP2;
        }
    }

    const time = timer.read();
    std.debug.print("Part1: {}\n", .{p1});
    std.debug.print("Part2: {}\n", .{p2});
    std.debug.print("Runtime (excluding output): {}us\n", .{time / std.time.ns_per_us});
}
