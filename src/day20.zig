const std = @import("std");

const input = @embedFile("day20.input");

const Point = struct {
    x: i64,
    y: i64,
};

const ImageExtents = struct {
    x_left: i64,
    x_right: i64,
    y_top: i64,
    y_bottom: i64,
};

fn getImageExtents(active_pixels: *const std.AutoHashMap(Point, void)) ImageExtents {
    var x_min: i64 = std.math.maxInt(i64);
    var x_max: i64 = 0;
    var y_min: i64 = std.math.maxInt(i64);
    var y_max: i64 = 0;

    var key_iter = active_pixels.keyIterator();
    while (key_iter.next()) |p| {
        if (p.x < x_min) {
            x_min = p.x;
        } else if (p.x > x_max) {
            x_max = p.x;
        }
        if (p.y < y_min) {
            y_min = p.y;
        } else if (p.y > y_max) {
            y_max = p.y;
        }
    }

    return .{ .x_left = x_min, .x_right = x_max, .y_top = y_min, .y_bottom = y_max };
}

fn isOutsideLit(algorithm: []const u8, outside_was_lit: bool) bool {
    return if (outside_was_lit) algorithm[algorithm.len - 1] == '#' else algorithm[0] == '#';
}

fn applyAlgorithm(active_pixels: *std.AutoHashMap(Point, void), outside_lit: bool, algorithm: []const u8) !void {
    var active_pixels_new = try active_pixels.clone();
    active_pixels_new.clearRetainingCapacity();
    defer active_pixels_new.deinit();

    const extents = getImageExtents(active_pixels);
    // Each round the image grows by 2 pixels in all 4 directions
    var y = extents.y_top - 2;
    while (y <= extents.y_bottom + 2) : (y += 1) {
        var x = extents.x_left - 2;
        while (x <= extents.x_right + 2) : (x += 1) {
            const pixels_to_consider = [_]Point{
                .{ .x = x - 1, .y = y - 1 },
                .{ .x = x, .y = y - 1 },
                .{ .x = x + 1, .y = y - 1 },
                .{ .x = x - 1, .y = y },
                .{ .x = x, .y = y },
                .{ .x = x + 1, .y = y },
                .{ .x = x - 1, .y = y + 1 },
                .{ .x = x, .y = y + 1 },
                .{ .x = x + 1, .y = y + 1 },
            };

            var binary_index = [_]u8{'0'} ** 9;

            for (pixels_to_consider) |p, idx| {
                if (p.x < extents.x_left or p.x > extents.x_right or p.y < extents.y_top or p.y > extents.y_bottom) {
                    binary_index[idx] = if (outside_lit) '1' else '0';
                } else {
                    binary_index[idx] = if (active_pixels.contains(p)) '1' else '0';
                }
            }
            const index = try std.fmt.parseInt(usize, &binary_index, 2);
            if (algorithm[index] == '#') {
                try active_pixels_new.put(.{ .x = x, .y = y }, {});
            }
        }
    }

    std.mem.swap(std.AutoHashMap(Point, void), active_pixels, &active_pixels_new);
}

pub fn main() anyerror!void {
    const timer = try std.time.Timer.start();
    var lines = std.mem.tokenize(u8, input, "\r\n");
    const algo = lines.next().?;
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    var active_pixels = std.AutoHashMap(Point, void).init(allocator);
    var p1: usize = 0;

    var y: i64 = 0;
    while (lines.next()) |line| : (y += 1) {
        for (line) |pixel, x| {
            if (pixel == '#') {
                try active_pixels.put(.{ .x = @intCast(i64, x), .y = y }, {});
            }
        }
    }

    var outside_lit = false;

    var enhancements: usize = 0;
    while (enhancements < 50) : (enhancements += 1) {
        if (enhancements == 2) {
            p1 = active_pixels.count();
        }
        try applyAlgorithm(&active_pixels, outside_lit, algo);
        outside_lit = isOutsideLit(algo, outside_lit);
    }

    const time = timer.read();
    std.debug.print("Part1: {}\n", .{p1});
    std.debug.print("Part1: {}\n", .{active_pixels.count()});
    std.debug.print("Runtime (excluding output): {}ms\n", .{time / std.time.ns_per_ms});
}
