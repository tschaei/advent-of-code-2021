const std = @import("std");

const input = @embedFile("day21.input");

const GameState = struct {
    player_one_pos: u64,
    player_one_score: u64,
    player_two_pos: u64,
    player_two_score: u64,
};

const Wins = struct {
    player_one: u64,
    player_two: u64,
};

fn play(state: GameState, played: *std.AutoHashMap(GameState, Wins)) anyerror!Wins {
    if (state.player_one_score >= 21) {
        return Wins{ .player_one = 1, .player_two = 0 };
    }
    if (state.player_two_score >= 21) {
        return Wins{ .player_one = 0, .player_two = 1 };
    }
    if (played.contains(state)) {
        return played.get(state).?;
    } else {
        var wins = Wins{
            .player_one = 0,
            .player_two = 0,
        };
        var i: usize = 1;
        while (i <= 3) : (i += 1) {
            var j: usize = 1;
            while (j <= 3) : (j += 1) {
                var k: usize = 1;
                while (k <= 3) : (k += 1) {
                    const player_one_score = ((state.player_one_pos + i + j + k - 1) % 10) + 1;
                    const wins_new = try play(.{
                        .player_one_pos = state.player_two_pos,
                        .player_one_score = state.player_two_score,
                        .player_two_pos = player_one_score,
                        .player_two_score = state.player_one_score + player_one_score,
                    }, played);
                    wins.player_one += wins_new.player_two;
                    wins.player_two += wins_new.player_one;
                }
            }
        }
        try played.put(state, wins);
        return wins;
    }
}

pub fn main() anyerror!void {
    var players = std.mem.tokenize(u8, input, "\r\n");
    var player_one_input = std.mem.split(u8, players.next().?, ": ");
    _ = player_one_input.next().?;
    var player_one = try std.fmt.parseInt(u64, player_one_input.next().?, 10);
    var player_two_input = std.mem.split(u8, players.next().?, ": ");
    _ = player_two_input.next().?;
    var player_two = try std.fmt.parseInt(u64, player_two_input.next().?, 10);

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    var played = std.AutoHashMap(GameState, Wins).init(allocator);

    var p1_state = GameState{
        .player_one_pos = player_one,
        .player_one_score = 0,
        .player_two_pos = player_two,
        .player_two_score = 0,
    };
    const p2_state = p1_state;

    var die: u8 = 1;
    var die_rolls: u64 = 0;
    while (p1_state.player_one_score < 1000 and p1_state.player_two_score < 1000) {
        var roll: usize = 1;
        var rolls: u64 = 0;
        while (roll <= 3) : (roll += 1) {
            rolls += die;
            die = (die % 100) + 1;
            die_rolls += 1;
        }
        p1_state.player_one_pos = ((p1_state.player_one_pos + rolls - 1) % 10) + 1;
        p1_state.player_one_score += p1_state.player_one_pos;
        if (p1_state.player_one_score >= 1000) continue;
        roll = 1;
        rolls = 0;
        while (roll <= 3) : (roll += 1) {
            rolls += die;
            die = (die % 100) + 1;
            die_rolls += 1;
        }
        p1_state.player_two_pos = ((p1_state.player_two_pos + rolls - 1) % 10) + 1;
        p1_state.player_two_score += p1_state.player_two_pos;
    }

    var loser = if (p1_state.player_one_score > p1_state.player_two_score) p1_state.player_two_score else p1_state.player_one_score;

    var p2 = play(p2_state, &played);
    std.debug.print("Part1: {}\n", .{loser * die_rolls});
    std.debug.print("Part2: {}\n", .{p2});
}
