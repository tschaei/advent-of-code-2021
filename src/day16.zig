const std = @import("std");

const input = @embedFile("day16.input");

const ParseResult = struct {
    version_sum: u64,
    value: u64,
    remaining_input: []const u8,
};

const BitCountChildIterator = struct {
    bit_count: usize,
    current: usize,
    buf: *[]const u8,
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator, buf: *[]const u8, bit_count: usize) BitCountChildIterator {
        return .{
            .bit_count = bit_count,
            .current = 0,
            .buf = buf,
            .allocator = allocator,
        };
    }

    pub fn next(self: *BitCountChildIterator) !?ParseResult {
        if (self.bit_count == self.current) {
            return null;
        }

        const result = try parsePacket(self.allocator, self.buf.*);
        self.current += self.buf.len - result.remaining_input.len;
        self.buf.* = result.remaining_input;
        return result;
    }
};

const PacketCountChildIterator = struct {
    packets_to_parse: usize,
    count: usize,
    buf: *[]const u8,
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator, buf: *[]const u8, packets_to_parse: usize) PacketCountChildIterator {
        return .{
            .packets_to_parse = packets_to_parse,
            .count = 0,
            .buf = buf,
            .allocator = allocator,
        };
    }

    pub fn next(self: *PacketCountChildIterator) !?ParseResult {
        if (self.packets_to_parse == self.count) {
            return null;
        }

        const result = try parsePacket(self.allocator, self.buf.*);
        self.count += 1;
        self.buf.* = result.remaining_input;
        return result;
    }
};

fn parseOperator(comptime T: type, iter: *T, packet_version: u8, packet_type_id: u8) !ParseResult {
    var version_sum: u64 = packet_version;
    var value: u64 = switch (packet_type_id) {
        0, 3, 5, 6, 7 => 0,
        1 => 1,
        2 => std.math.maxInt(u64),
        else => unreachable,
    };
    var remaining_input: []const u8 = undefined;
    if (packet_type_id < 5) {
        while (try iter.next()) |result| {
            switch (packet_type_id) {
                0 => {
                    value += result.value;
                },
                1 => {
                    value *= result.value;
                },
                2 => {
                    value = std.math.min(value, result.value);
                },
                3 => {
                    value = std.math.max(value, result.value);
                },
                else => unreachable,
            }
            version_sum += result.version_sum;
            remaining_input = result.remaining_input;
        }
    } else {
        const resultA = (try iter.next()) orelse return error.ParseError;
        const resultB = (try iter.next()) orelse return error.ParseError;
        switch (packet_type_id) {
            5 => value = if (resultA.value > resultB.value) 1 else 0,
            6 => value = if (resultA.value < resultB.value) 1 else 0,
            7 => value = if (resultA.value == resultB.value) 1 else 0,
            else => unreachable,
        }
        version_sum += resultA.version_sum + resultB.version_sum;
        remaining_input = resultB.remaining_input;
    }

    return ParseResult{
        .version_sum = version_sum,
        .value = value,
        .remaining_input = remaining_input,
    };
}

inline fn consume(comptime T: type, bits: *[]const u8, count: usize) !T {
    const result = try std.fmt.parseInt(T, bits.*[0..count], 2);
    bits.* = bits.*[count..];
    return result;
}

fn parsePacket(allocator: std.mem.Allocator, input_bits: []const u8) anyerror!ParseResult {
    var packet = input_bits;
    var literal_buffer = std.ArrayList(u64).init(allocator);
    defer literal_buffer.deinit();
    // 1. read packet version
    const packet_version = try consume(u8, &packet, 3);
    const packet_type_id = try consume(u8, &packet, 3);
    switch (packet_type_id) {
        4 => {
            // literal value
            var literal_group_idx: usize = 0;
            var literal_done = false;
            var literal: u64 = 0;
            while (!literal_done) : (literal_group_idx += 5) {
                if (packet[0] == '0') {
                    literal_done = true;
                }
                try literal_buffer.append((try consume(u8, &packet, 5)) & 0b1111);
            }

            for (literal_buffer.items) |nibble, idx| {
                literal += nibble << @intCast(u6, ((literal_buffer.items.len - 1) - idx) * 4);
            }

            return ParseResult{
                .version_sum = packet_version,
                .value = literal,
                .remaining_input = packet,
            };
        },
        else => {
            // operator packets
            switch (try consume(u8, &packet, 1)) {
                0 => {
                    // next 15 bits are number that represents total length in bits of sub-packets
                    const bits_to_parse = (try consume(u16, &packet, 15)) & 0b111111111111111;
                    var iter = BitCountChildIterator.init(allocator, &packet, bits_to_parse);
                    return parseOperator(BitCountChildIterator, &iter, packet_version, packet_type_id);
                },
                1 => {
                    // next 11 bits are number that represents number of sub-packets immediately contained by this packet
                    const packets_to_parse = (try consume(u16, &packet, 11)) & 0b11111111111;
                    var iter = PacketCountChildIterator.init(allocator, &packet, packets_to_parse);
                    return parseOperator(PacketCountChildIterator, &iter, packet_version, packet_type_id);
                },
                else => unreachable,
            }
            unreachable;
        },
    }
}

pub fn main() anyerror!void {
    const timer = try std.time.Timer.start();
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const allocator = arena.allocator();
    var bits = std.ArrayList(u8).init(allocator);
    for (input) |hex| {
        try bits.appendSlice(switch (hex) {
            '0' => "0000",
            '1' => "0001",
            '2' => "0010",
            '3' => "0011",
            '4' => "0100",
            '5' => "0101",
            '6' => "0110",
            '7' => "0111",
            '8' => "1000",
            '9' => "1001",
            'A' => "1010",
            'B' => "1011",
            'C' => "1100",
            'D' => "1101",
            'E' => "1110",
            'F' => "1111",
            else => unreachable,
        });
    }

    const result = try parsePacket(allocator, bits.items);
    const time = timer.read();
    std.debug.print("Part1: {}\n", .{result.version_sum});
    std.debug.print("Part2: {}\n", .{result.value});
    std.debug.print("Runtime (excluding output): {}us\n", .{time / std.time.ns_per_us});
}
