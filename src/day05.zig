const std = @import("std");

const input = @embedFile("day05.input");

const LineSegment = struct {
    x1: usize,
    y1: usize,
    x2: usize,
    y2: usize,
};

const ParsedLineSegments = struct {
    lineSegments: []LineSegment,
    xMax: usize,
    yMax: usize,
};

const GridField = struct {
    p1: usize,
    p2: usize,
};

const Grid = struct {
    allocator: *std.mem.Allocator,
    fields: [][]GridField,
    p1: usize,
    p2: usize,

    pub fn init(allocator: *std.mem.Allocator, xMax: usize, yMax: usize) !Grid {
        var fields = try allocator.alloc([]GridField, yMax + 1);
        for (fields) |*row| {
            row.* = try allocator.alloc(GridField, xMax + 1);
            std.mem.set(GridField, row.*, .{ .p1 = 0, .p2 = 0 });
        }

        return Grid{
            .allocator = allocator,
            .fields = fields,
            .p1 = 0,
            .p2 = 0,
        };
    }

    pub fn deinit(self: *Grid) void {
        for (self.fields) |*row| {
            self.allocator.free(row.*);
        }
        self.allocator.free(self.fields);
    }

    pub fn mark(self: *Grid, x: usize, y: usize, p1: bool) void {
        self.fields[y][x].p2 += 1;
        if (self.fields[y][x].p2 == 2) {
            self.p2 += 1;
        }
        if (p1) {
            self.fields[y][x].p1 += 1;
            if (self.fields[y][x].p1 == 2) {
                self.p1 += 1;
            }
        }
    }
};

pub fn parseLineSegments(allocator: *std.mem.Allocator, inputBuf: []const u8) !ParsedLineSegments {
    var lines = std.mem.tokenize(u8, inputBuf, "\r\n");
    var lineSegments = std.ArrayList(LineSegment).init(allocator);
    errdefer lineSegments.deinit();
    var xMax: usize = 0;
    var yMax: usize = 0;
    while (lines.next()) |line| {
        var points = std.mem.split(u8, line, " -> ");
        var point1 = std.mem.tokenize(u8, points.next() orelse return error.ParseError, ",");
        var x1 = try std.fmt.parseInt(usize, point1.next() orelse return error.ParseError, 10);
        var y1 = try std.fmt.parseInt(usize, point1.next() orelse return error.ParseError, 10);
        var point2 = std.mem.tokenize(u8, points.next() orelse return error.ParseError, ",");
        var x2 = try std.fmt.parseInt(usize, point2.next() orelse return error.ParseError, 10);
        var y2 = try std.fmt.parseInt(usize, point2.next() orelse return error.ParseError, 10);
        xMax = std.math.max(xMax, std.math.max(x1, x2));
        yMax = std.math.max(yMax, std.math.max(y1, y2));
        try lineSegments.append(.{ .x1 = x1, .y1 = y1, .x2 = x2, .y2 = y2 });
    }

    return ParsedLineSegments{
        .lineSegments = lineSegments.toOwnedSlice(),
        .xMax = xMax,
        .yMax = yMax,
    };
}

pub fn main() anyerror!void {
    const timer = try std.time.Timer.start();
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    var parsedLineSegments = try parseLineSegments(&gpa.allocator, input);
    const lineSegments = parsedLineSegments.lineSegments;
    const xMax = parsedLineSegments.xMax;
    const yMax = parsedLineSegments.yMax;
    defer gpa.allocator.free(lineSegments);
    var grid = try Grid.init(&gpa.allocator, xMax, yMax);
    defer grid.deinit();

    for (lineSegments) |segment| {
        if (segment.x1 == segment.x2) {
            var current = std.math.min(segment.y1, segment.y2);
            const end = std.math.max(segment.y1, segment.y2);
            while (current <= end) : (current += 1) {
                grid.mark(segment.x1, current, true);
            }
        } else if (segment.y1 == segment.y2) {
            var current = std.math.min(segment.x1, segment.x2);
            const end = std.math.max(segment.x1, segment.x2);
            while (current <= end) : (current += 1) {
                grid.mark(current, segment.y1, true);
            }
        } else {
            var currentX: i64 = @intCast(i64, segment.x1);
            var currentY: i64 = @intCast(i64, segment.y1);
            var stepX: i64 = if (segment.x1 < segment.x2) 1 else -1;
            var stepY: i64 = if (segment.y1 < segment.y2) 1 else -1;
            while (currentX != (@intCast(i64, segment.x2) + stepX) and currentY != (@intCast(i64, segment.y2) + stepY)) : ({
                currentX += stepX;
                currentY += stepY;
            }) {
                grid.mark(@intCast(usize, currentX), @intCast(usize, currentY), false);
            }
        }
    }

    const time = timer.read();
    std.debug.print("Part1: {}\n", .{grid.p1});
    std.debug.print("Part2: {}\n", .{grid.p2});
    std.debug.print("Runtime (excluding output): {}us\n", .{time / std.time.ns_per_us});
}
