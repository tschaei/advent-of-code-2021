const std = @import("std");

const input = @embedFile("day06.input");

pub fn main() anyerror!void {
    const timer = try std.time.Timer.start();
    var initialFish = std.mem.split(u8, input, ",");
    var fishOnDay = [_]usize{0} ** 9;
    while (initialFish.next()) |fish| {
        fishOnDay[try std.fmt.parseInt(u8, fish, 10)] += 1;
    }

    var p1: usize = 0;
    var p2: usize = 0;
    var day: usize = 1;
    while (day <= 256) : (day += 1) {
        const newFish = fishOnDay[0];
        fishOnDay[0] = fishOnDay[1];
        fishOnDay[1] = fishOnDay[2];
        fishOnDay[2] = fishOnDay[3];
        fishOnDay[3] = fishOnDay[4];
        fishOnDay[4] = fishOnDay[5];
        fishOnDay[5] = fishOnDay[6];
        fishOnDay[6] = fishOnDay[7] + newFish;
        fishOnDay[7] = fishOnDay[8];
        fishOnDay[8] = newFish;

        if (day == 80) {
            for (fishOnDay) |fish| {
                p1 += fish;
            }
        }
    }

    for (fishOnDay) |fish| {
        p2 += fish;
    }

    const time = timer.read();
    std.debug.print("Part1: {}\n", .{p1});
    std.debug.print("Part2: {}\n", .{p2});
    std.debug.print("Runtime (excluding output): {}us\n", .{time / std.time.ns_per_us});
}
