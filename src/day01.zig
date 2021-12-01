const std = @import("std");

const input = @embedFile("day01.input");

pub fn main() anyerror!void {
    const timer = std.time.Timer.start() catch unreachable;
    var p1: u64 = 0;
    var p2: u64 = 0;

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const inputNums = toNumbers(&gpa.allocator, input);
    defer inputNums.deinit();

    var prev: ?i64 = null;
    for (inputNums.items) |num| {
        if (prev) |p| {
            if (num > p) {
                p1 += 1;
            }
        }
        prev = num;
    }

    var iter = ThreeMeasurementIterator.init(&inputNums);
    prev = null;
    while (iter.next()) |measurement| {
        if (prev) |p| {
            if (measurement > p) {
                p2 += 1;
            }
        }
        prev = measurement;
    }

    const time = timer.read();
    std.debug.warn("Part 1: {} increases\n", .{p1});
    std.debug.warn("Part 2: {} increases\n", .{p2});
    std.debug.warn("Total runtime (without output): {}us", .{@divFloor(time, std.time.ns_per_us)});
}

fn toNumbers(allocator: *std.mem.Allocator, stringInput: []const u8) std.ArrayList(i64) {
    var fbs = std.io.fixedBufferStream(stringInput);
    var nums = std.ArrayList(i64).init(allocator);

    while (fbs.reader().readUntilDelimiterOrEofAlloc(allocator, '\n', 1024) catch unreachable) |line| {
        nums.append(std.fmt.parseInt(i64, line, 10) catch unreachable) catch unreachable;
        allocator.free(line);
    }

    return nums;
}

const ThreeMeasurementIterator = struct {
    nums: *const std.ArrayList(i64),
    current: u64,

    pub fn next(self: *ThreeMeasurementIterator) ?i64 {
        if (self.nums.items.len - self.current >= 3) {
            const result = self.nums.items[self.current] + self.nums.items[self.current + 1] + self.nums.items[self.current + 2];
            self.current += 1;
            return result;
        }

        return null;
    }

    pub fn init(nums: *const std.ArrayList(i64)) ThreeMeasurementIterator {
        return .{
            .nums = nums,
            .current = 0,
        };
    }
};
