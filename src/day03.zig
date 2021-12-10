const std = @import("std");

const input = @embedFile("day03.input");

pub fn main() anyerror!void {
    const timer = try std.time.Timer.start();
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const allocator = arena.allocator();
    defer arena.deinit();
    var lines = std.mem.tokenize(u8, input, "\r\n");
    var bits = (lines.next() orelse return).len;
    lines.reset();
    var line_count: u64 = 0;
    var one_counts = try allocator.alloc(u64, bits);
    std.mem.set(u64, one_counts, 0);
    var numbers = std.ArrayList(u64).init(allocator);

    while (lines.next()) |line| {
        line_count += 1;
        try numbers.append(try std.fmt.parseInt(u64, line, 2));
        for (line) |_, idx| {
            one_counts[idx] += (numbers.items[numbers.items.len - 1] >> @truncate(u6, bits - 1 - idx)) & 1;
        }
    }

    var gamma_rate = try allocator.alloc(u8, bits);
    std.mem.set(u8, gamma_rate, '0');
    for (one_counts) |one_count, idx| {
        if (one_count > @divFloor(line_count, 2)) {
            gamma_rate[idx] = '1';
        }
    }

    var epsilon_rate = try allocator.dupe(u8, gamma_rate);
    for (epsilon_rate) |bit, idx| {
        epsilon_rate[idx] = if (bit == '1') '0' else '1';
    }
    const p_1 = (try std.fmt.parseInt(u64, gamma_rate, 2)) * (try std.fmt.parseInt(u64, epsilon_rate, 2));

    var oxygen_candidates_1 = std.ArrayList(u64).init(allocator);
    try oxygen_candidates_1.insertSlice(0, numbers.items);
    var oxygen_candidates_2 = try std.ArrayList(u64).initCapacity(allocator, oxygen_candidates_1.items.len);

    var co2_candidates_1 = std.ArrayList(u64).init(allocator);
    try co2_candidates_1.insertSlice(0, numbers.items);
    var co2_candidates_2 = try std.ArrayList(u64).initCapacity(allocator, co2_candidates_1.items.len);

    lines.reset();

    var i: usize = 1;
    while (i <= bits) {
        if (oxygen_candidates_1.items.len == 1 and co2_candidates_1.items.len == 1) {
            break;
        }
        if (oxygen_candidates_1.items.len > 1) {
            var mostCommon: u64 = 0;
            var zeroes: u64 = 0;
            var ones: u64 = 0;
            for (oxygen_candidates_1.items) |candidate| {
                if ((candidate >> @truncate(u6, (bits - i))) & 1 == 0) {
                    zeroes += 1;
                } else {
                    ones += 1;
                }
            }
            mostCommon = if (ones >= zeroes) 1 else 0;
            for (oxygen_candidates_1.items) |candidate| {
                if ((candidate >> @truncate(u6, (bits - i)) & 1) == mostCommon) {
                    try oxygen_candidates_2.append(candidate);
                }
            }
            std.mem.swap(std.ArrayList(u64), &oxygen_candidates_1, &oxygen_candidates_2);
            oxygen_candidates_2.clearRetainingCapacity();
        }

        if (co2_candidates_1.items.len > 1) {
            var least_common: u64 = 0;
            var ones: u64 = 0;
            var zeroes: u64 = 0;
            for (co2_candidates_1.items) |candidate| {
                if ((candidate >> @truncate(u6, (bits - i))) & 1 == 0) {
                    zeroes += 1;
                } else {
                    ones += 1;
                }
            }
            least_common = if (ones >= zeroes) 0 else 1;
            for (co2_candidates_1.items) |candidate| {
                if ((candidate >> @truncate(u6, (bits - i)) & 1) == least_common) {
                    try co2_candidates_2.append(candidate);
                }
            }
            std.mem.swap(std.ArrayList(u64), &co2_candidates_1, &co2_candidates_2);
            co2_candidates_2.clearRetainingCapacity();
        }
        i += 1;
    }

    const p_2 = oxygen_candidates_1.items[0] * co2_candidates_1.items[0];

    const end = timer.read();
    std.debug.print("Part 1: {}\n", .{p_1});
    std.debug.print("Part 2: {}\n", .{p_2});
    std.debug.print("Runtime (excluding output): {}us\n", .{end / std.time.ns_per_us});
}
