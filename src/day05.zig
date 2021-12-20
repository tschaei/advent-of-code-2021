const std = @import("std");

const input = @embedFile("day05.input");

const LineSegment = struct {
    x_1: usize,
    y_1: usize,
    x_2: usize,
    y_2: usize,
};

const ParsedLineSegments = struct {
    segments: []LineSegment,
    x_max: usize,
    y_max: usize,
};

const GridField = struct {
    p_1: usize,
    p_2: usize,
};

const Grid = struct {
    allocator: std.mem.Allocator,
    fields: [][]GridField,
    p_1: usize,
    p_2: usize,

    pub fn init(allocator: std.mem.Allocator, x_max: usize, y_max: usize) !Grid {
        var fields = try allocator.alloc([]GridField, y_max + 1);
        for (fields) |*row| {
            row.* = try allocator.alloc(GridField, x_max + 1);
            std.mem.set(GridField, row.*, .{ .p_1 = 0, .p_2 = 0 });
        }

        return Grid{
            .allocator = allocator,
            .fields = fields,
            .p_1 = 0,
            .p_2 = 0,
        };
    }

    pub fn mark(self: *Grid, x: usize, y: usize, p_1: bool) void {
        self.fields[y][x].p_2 += 1;
        if (self.fields[y][x].p_2 == 2) {
            self.p_2 += 1;
        }
        if (p_1) {
            self.fields[y][x].p_1 += 1;
            if (self.fields[y][x].p_1 == 2) {
                self.p_1 += 1;
            }
        }
    }
};

pub fn parseLineSegments(allocator: std.mem.Allocator, buf: []const u8) !ParsedLineSegments {
    var lines = std.mem.tokenize(u8, buf, "\r\n");
    var segments = std.ArrayList(LineSegment).init(allocator);
    var x_max: usize = 0;
    var y_max: usize = 0;
    while (lines.next()) |line| {
        var points = std.mem.split(u8, line, " -> ");
        var point1 = std.mem.tokenize(u8, points.next().?, ",");
        var point2 = std.mem.tokenize(u8, points.next().?, ",");
        const segment = .{
            .x_1 = try std.fmt.parseInt(usize, point1.next().?, 10),
            .y_1 = try std.fmt.parseInt(usize, point1.next().?, 10),
            .x_2 = try std.fmt.parseInt(usize, point2.next().?, 10),
            .y_2 = try std.fmt.parseInt(usize, point2.next().?, 10),
        };
        try segments.append(segment);
        x_max = std.math.max(x_max, std.math.max(segment.x_1, segment.x_2));
        y_max = std.math.max(y_max, std.math.max(segment.y_1, segment.y_2));
    }

    return ParsedLineSegments{
        .segments = segments.toOwnedSlice(),
        .x_max = x_max,
        .y_max = y_max,
    };
}

pub fn main() anyerror!void {
    const timer = try std.time.Timer.start();
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    var parsed_segments = try parseLineSegments(allocator, input);
    const segments = parsed_segments.segments;
    const x_max = parsed_segments.x_max;
    const y_max = parsed_segments.y_max;
    var grid = try Grid.init(allocator, x_max, y_max);

    for (segments) |segment| {
        if (segment.x_1 == segment.x_2) {
            var current = std.math.min(segment.y_1, segment.y_2);
            const end = std.math.max(segment.y_1, segment.y_2);
            while (current <= end) : (current += 1) {
                grid.mark(segment.x_1, current, true);
            }
        } else if (segment.y_1 == segment.y_2) {
            var current = std.math.min(segment.x_1, segment.x_2);
            const end = std.math.max(segment.x_1, segment.x_2);
            while (current <= end) : (current += 1) {
                grid.mark(current, segment.y_1, true);
            }
        } else {
            var x_curr: i64 = @intCast(i64, segment.x_1);
            var y_curr: i64 = @intCast(i64, segment.y_1);
            var x_step: i64 = if (segment.x_1 < segment.x_2) 1 else -1;
            var y_step: i64 = if (segment.y_1 < segment.y_2) 1 else -1;
            while (x_curr != (@intCast(i64, segment.x_2) + x_step) and y_curr != (@intCast(i64, segment.y_2) + y_step)) : ({
                x_curr += x_step;
                y_curr += y_step;
            }) {
                grid.mark(@intCast(usize, x_curr), @intCast(usize, y_curr), false);
            }
        }
    }

    const time = timer.read();
    std.debug.print("Part1: {}\n", .{grid.p_1});
    std.debug.print("Part2: {}\n", .{grid.p_2});
    std.debug.print("Runtime (excluding output): {}us\n", .{time / std.time.ns_per_us});
}
