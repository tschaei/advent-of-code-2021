const std = @import("std");

const input = @embedFile("day03.input");

pub fn main() anyerror!void {
    const timer = try std.time.Timer.start();
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    var lines = std.mem.tokenize(u8, input, "\r\n");
    var bits = (lines.next() orelse return).len;
    lines.reset();
    var lineCount: usize = 0;
    var oneCounts = try gpa.allocator.alloc(usize, bits);
    defer gpa.allocator.free(oneCounts);
    std.mem.set(usize, oneCounts, 0);
    var numbers = std.ArrayList(usize).init(&gpa.allocator);
    defer numbers.deinit();

    while (lines.next()) |line| {
        lineCount += 1;
        try numbers.append(try std.fmt.parseInt(usize, line, 2));
        for (line) |bit, idx| {
            // TODO: make branchless (add binary & of shifted bit)
            if (bit == '1') {
                oneCounts[idx] += 1;
            }
        }
    }

    var gammaRate = try gpa.allocator.alloc(u8, bits);
    defer gpa.allocator.free(gammaRate);
    std.mem.set(u8, gammaRate, '0');
    for (oneCounts) |oneCount, idx| {
        if (oneCount > @divFloor(lineCount, 2)) {
            gammaRate[idx] = '1';
        }
    }

    var epsilonRate = try gpa.allocator.dupe(u8, gammaRate);
    defer gpa.allocator.free(epsilonRate);
    for (epsilonRate) |bit, idx| {
        epsilonRate[idx] = if (bit == '1') '0' else '1';
    }
    const p1 = (try std.fmt.parseInt(usize, gammaRate, 2)) * (try std.fmt.parseInt(usize, epsilonRate, 2));

    var oxygenGeneratorRatingCandidates1 = std.ArrayList(usize).init(&gpa.allocator);
    defer oxygenGeneratorRatingCandidates1.deinit();
    var oxygenGeneratorRatingCandidates2 = std.ArrayList(usize).init(&gpa.allocator);
    defer oxygenGeneratorRatingCandidates2.deinit();
    try oxygenGeneratorRatingCandidates1.insertSlice(0, numbers.items);

    var co2ScrubberRatingCandidates1 = std.ArrayList(usize).init(&gpa.allocator);
    defer co2ScrubberRatingCandidates1.deinit();
    var co2ScrubberRatingCandidates2 = std.ArrayList(usize).init(&gpa.allocator);
    defer co2ScrubberRatingCandidates2.deinit();
    try co2ScrubberRatingCandidates1.insertSlice(0, numbers.items);
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
            oxygenGeneratorRatingCandidates1.clearAndFree();
            try oxygenGeneratorRatingCandidates1.insertSlice(0, oxygenGeneratorRatingCandidates2.items);
            oxygenGeneratorRatingCandidates2.clearAndFree();
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
            co2ScrubberRatingCandidates1.clearAndFree();
            try co2ScrubberRatingCandidates1.insertSlice(0, co2ScrubberRatingCandidates2.items);
            co2ScrubberRatingCandidates2.clearAndFree();
        }
        i += 1;
    }

    const p2 = oxygenGeneratorRatingCandidates1.items[0] * co2ScrubberRatingCandidates1.items[0];

    const end = timer.read();
    std.debug.print("Part 1: {}\n", .{p1});
    std.debug.print("Part 2: {}\n", .{p2});
    std.debug.print("Runtime (excluding output): {}us\n", .{end / std.time.ns_per_us});
}
