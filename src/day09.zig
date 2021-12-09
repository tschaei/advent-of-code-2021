const std = @import("std");

const input = @embedFile("day09.input");

const Point = struct {
    x: usize,
    y: usize,
};

const LowPoint = struct {
    p: Point,
    value: u8,
};

const Basin = struct {
    fields: std.ArrayList(Point),

    pub fn contains(self: *Basin, p: Point) bool {
        for (self.fields.items) |field| {
            if (p.x == field.x and p.y == field.y) {
                return true;
            }
        }
        return false;
    }
};

pub fn exploreBasin(at: Point, basin: *Basin, map: [][]u8) anyerror!usize {
    if (basin.contains(at)) {
        return 0;
    }
    if (map[at.y][at.x] == 9) {
        return 0;
    }

    try basin.fields.append(at);
    var result: usize = 1;

    // Check where we are so we now which neighbours to look at
    if (at.x < map[0].len - 1) {
        result += try exploreBasin(.{ .x = at.x + 1, .y = at.y }, basin, map);
    }

    if (at.x > 0) {
        result += try exploreBasin(.{ .x = at.x - 1, .y = at.y }, basin, map);
    }

    if (at.y < map.len - 1) {
        result += try exploreBasin(.{ .x = at.x, .y = at.y + 1 }, basin, map);
    }

    if (at.y > 0) {
        result += try exploreBasin(.{ .x = at.x, .y = at.y - 1 }, basin, map);
    }

    return result;
}

pub fn main() anyerror!void {
    const timer = try std.time.Timer.start();
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    var map = std.ArrayList([]u8).init(allocator);
    var lines = std.mem.tokenize(u8, input, "\r\n");
    while (lines.next()) |line| {
        var row = std.ArrayList(u8).init(allocator);
        for (line) |char| {
            try row.append(try std.fmt.parseInt(u8, &.{char}, 10));
        }
        try map.append(row.toOwnedSlice());
    }
    var lowPoints = std.ArrayList(LowPoint).init(allocator);
    var p1: usize = 0;

    for (map.items) |row, rowIdx| {
        for (row) |field, colIdx| {
            // Top row
            if (rowIdx == 0) {
                if (colIdx == 0) {
                    if (field < row[colIdx + 1] and field < map.items[rowIdx + 1][colIdx]) {
                        try lowPoints.append(.{ .p = .{ .x = colIdx, .y = rowIdx }, .value = field });
                    }
                } else if (colIdx == row.len - 1) {
                    if (field < row[colIdx - 1] and field < map.items[rowIdx + 1][colIdx]) {
                        try lowPoints.append(.{ .p = .{ .x = colIdx, .y = rowIdx }, .value = field });
                    }
                } else {
                    if (field < row[colIdx - 1] and field < row[colIdx + 1] and field < map.items[rowIdx + 1][colIdx]) {
                        try lowPoints.append(.{ .p = .{ .x = colIdx, .y = rowIdx }, .value = field });
                    }
                }

                // Bottom row
            } else if (rowIdx == map.items.len - 1) {
                if (colIdx == 0) {
                    if (field < row[colIdx + 1] and field < map.items[rowIdx - 1][colIdx]) {
                        try lowPoints.append(.{ .p = .{ .x = colIdx, .y = rowIdx }, .value = field });
                    }
                } else if (colIdx == row.len - 1) {
                    if (field < row[colIdx - 1] and field < map.items[rowIdx - 1][colIdx]) {
                        try lowPoints.append(.{ .p = .{ .x = colIdx, .y = rowIdx }, .value = field });
                    }
                } else {
                    if (field < row[colIdx - 1] and field < row[colIdx + 1] and field < map.items[rowIdx - 1][colIdx]) {
                        try lowPoints.append(.{ .p = .{ .x = colIdx, .y = rowIdx }, .value = field });
                    }
                }
                // Left column
            } else if (colIdx == 0) {
                if (field < row[colIdx + 1] and field < map.items[rowIdx - 1][colIdx] and field < map.items[rowIdx + 1][colIdx]) {
                    try lowPoints.append(.{ .p = .{ .x = colIdx, .y = rowIdx }, .value = field });
                }
                // Right column
            } else if (colIdx == map.items.len - 1) {
                if (field < row[colIdx - 1] and field < map.items[rowIdx - 1][colIdx] and field < map.items[rowIdx + 1][colIdx]) {
                    try lowPoints.append(.{ .p = .{ .x = colIdx, .y = rowIdx }, .value = field });
                }
            } else {
                if (field < row[colIdx - 1] and field < row[colIdx + 1] and field < map.items[rowIdx - 1][colIdx] and field < map.items[rowIdx + 1][colIdx]) {
                    try lowPoints.append(.{ .p = .{ .x = colIdx, .y = rowIdx }, .value = field });
                }
            }
        }
    }

    var basinSizes = std.ArrayList(usize).init(allocator);
    for (lowPoints.items) |lowPoint| {
        p1 += lowPoint.value + 1;
        var basin = .{ .fields = std.ArrayList(Point).init(allocator) };
        try basinSizes.append(try exploreBasin(lowPoint.p, &basin, map.items));
    }

    std.sort.sort(usize, basinSizes.items, {}, comptime std.sort.desc(usize));

    const time = timer.read();
    std.debug.print("Part1: {}\n", .{p1});
    std.debug.print("Part2: {}\n", .{basinSizes.items[0] * basinSizes.items[1] * basinSizes.items[2]});
    std.debug.print("Runtime (excluding output): {}us\n", .{time / std.time.ns_per_us});
}
