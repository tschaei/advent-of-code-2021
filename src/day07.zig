const std = @import("std");

const input = @embedFile("day07.input");

pub fn main() anyerror!void {
    const timer = try std.time.Timer.start();
    var positionsIter = std.mem.split(u8, input, ",");
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    var positions = std.ArrayList(i64).init(&gpa.allocator);
    defer positions.deinit();
    while (positionsIter.next()) |pos| {
        try positions.append(try std.fmt.parseInt(i64, pos, 10));
    }

    var i: i64 = 0;
    var p1: i64 = std.math.maxInt(i64);
    var p2: i64 = std.math.maxInt(i64);
    while (i < positions.items.len) : (i += 1) {
        var fuelP1: i64 = 0;
        var fuelP2: i64 = 0;
        for (positions.items) |pos| {
            const delta = try std.math.absInt(std.math.max(pos, i) - std.math.min(pos, i));
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
