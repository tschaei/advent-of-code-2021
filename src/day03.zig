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
    var lineCount: usize = 0;
    var oneCounts = try allocator.alloc(usize, bits);
    std.mem.set(usize, oneCounts, 0);
    var numbers = std.ArrayList(usize).init(allocator);

    while (lines.next()) |line| {
        lineCount += 1;
        try numbers.append(try std.fmt.parseInt(usize, line, 2));
        for (line) |_, idx| {
            oneCounts[idx] += (numbers.items[numbers.items.len - 1] >> @truncate(u6, bits - 1 - idx)) & 1;
        }
    }

    var gammaRate = try allocator.alloc(u8, bits);
    std.mem.set(u8, gammaRate, '0');
    for (oneCounts) |oneCount, idx| {
        if (oneCount > @divFloor(lineCount, 2)) {
            gammaRate[idx] = '1';
        }
    }

    var epsilonRate = try allocator.dupe(u8, gammaRate);
    for (epsilonRate) |bit, idx| {
        epsilonRate[idx] = if (bit == '1') '0' else '1';
    }
    const p1 = (try std.fmt.parseInt(usize, gammaRate, 2)) * (try std.fmt.parseInt(usize, epsilonRate, 2));

    var oxygenGeneratorRatingCandidates1 = std.ArrayList(usize).init(allocator);
    try oxygenGeneratorRatingCandidates1.insertSlice(0, numbers.items);
    var oxygenGeneratorRatingCandidates2 = try std.ArrayList(usize).initCapacity(allocator, oxygenGeneratorRatingCandidates1.items.len);

    var co2ScrubberRatingCandidates1 = std.ArrayList(usize).init(allocator);
    try co2ScrubberRatingCandidates1.insertSlice(0, numbers.items);
    var co2ScrubberRatingCandidates2 = try std.ArrayList(usize).initCapacity(allocator, co2ScrubberRatingCandidates1.items.len);

    lines.reset();

    var i: usize = 1;
    while (i <= bits) {
        if (oxygenGeneratorRatingCandidates1.items.len == 1 and co2ScrubberRatingCandidates1.items.len == 1) {
            break;
        }
        if (oxygenGeneratorRatingCandidates1.items.len > 1) {
            var mostCommon: usize = 0;
            var zeroes: usize = 0;
            var ones: usize = 0;
            for (oxygenGeneratorRatingCandidates1.items) |candidate| {
                if ((candidate >> @truncate(u6, (bits - i))) & 1 == 0) {
                    zeroes += 1;
                } else {
                    ones += 1;
                }
            }
            mostCommon = if (ones >= zeroes) 1 else 0;
            for (oxygenGeneratorRatingCandidates1.items) |candidate| {
                if ((candidate >> @truncate(u6, (bits - i)) & 1) == mostCommon) {
                    try oxygenGeneratorRatingCandidates2.append(candidate);
                }
            }
            std.mem.swap(std.ArrayList(usize), &oxygenGeneratorRatingCandidates1, &oxygenGeneratorRatingCandidates2);
            oxygenGeneratorRatingCandidates2.clearRetainingCapacity();
        }

        if (co2ScrubberRatingCandidates1.items.len > 1) {
            var leastCommon: usize = 0;
            var ones: usize = 0;
            var zeroes: usize = 0;
            for (co2ScrubberRatingCandidates1.items) |candidate| {
                if ((candidate >> @truncate(u6, (bits - i))) & 1 == 0) {
                    zeroes += 1;
                } else {
                    ones += 1;
                }
            }
            leastCommon = if (ones >= zeroes) 0 else 1;
            for (co2ScrubberRatingCandidates1.items) |candidate| {
                if ((candidate >> @truncate(u6, (bits - i)) & 1) == leastCommon) {
                    try co2ScrubberRatingCandidates2.append(candidate);
                }
            }
            std.mem.swap(std.ArrayList(usize), &co2ScrubberRatingCandidates1, &co2ScrubberRatingCandidates2);
            co2ScrubberRatingCandidates2.clearRetainingCapacity();
        }
        i += 1;
    }

    const p2 = oxygenGeneratorRatingCandidates1.items[0] * co2ScrubberRatingCandidates1.items[0];

    const end = timer.read();
    std.debug.print("Part 1: {}\n", .{p1});
    std.debug.print("Part 2: {}\n", .{p2});
    std.debug.print("Runtime (excluding output): {}us\n", .{end / std.time.ns_per_us});
}
