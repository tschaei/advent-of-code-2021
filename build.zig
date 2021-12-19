const std = @import("std");

pub fn build(b: *std.build.Builder) !void {
    const target = b.standardTargetOptions(.{});
    const mode = b.standardReleaseOptions();
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    try makeBuildForDay(allocator, b, target, mode, "01");
    try makeBuildForDay(allocator, b, target, mode, "02");
    try makeBuildForDay(allocator, b, target, mode, "03");
    try makeBuildForDay(allocator, b, target, mode, "04");
    try makeBuildForDay(allocator, b, target, mode, "05");
    try makeBuildForDay(allocator, b, target, mode, "06");
    try makeBuildForDay(allocator, b, target, mode, "07");
    try makeBuildForDay(allocator, b, target, mode, "08");
    try makeBuildForDay(allocator, b, target, mode, "09");
    try makeBuildForDay(allocator, b, target, mode, "10");
    try makeBuildForDay(allocator, b, target, mode, "11");
    try makeBuildForDay(allocator, b, target, mode, "12");
    try makeBuildForDay(allocator, b, target, mode, "13");
    try makeBuildForDay(allocator, b, target, mode, "14");
    try makeBuildForDay(allocator, b, target, mode, "15");
    try makeBuildForDay(allocator, b, target, mode, "16");
    try makeBuildForDay(allocator, b, target, mode, "17");
    try makeBuildForDay(allocator, b, target, mode, "18");
}

pub fn makeBuildForDay(allocator: std.mem.Allocator, b: *std.build.Builder, target: std.zig.CrossTarget, mode: std.builtin.Mode, day: []const u8) !void {
    const stepName = try std.fmt.allocPrint(allocator, "day{s}", .{day});
    const stepSrc = try std.fmt.allocPrint(allocator, "src/{s}.zig", .{stepName});
    const step = b.addExecutable(stepName, stepSrc);
    step.setTarget(target);
    step.setBuildMode(mode);
    step.install();
    const run_cmd = step.run();
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }
    var runStepName = try std.fmt.allocPrint(allocator, "run_day{s}", .{day});
    var runDesc = try std.fmt.allocPrint(allocator, "Run {s}", .{stepName});
    const run_step = b.step(runStepName, runDesc);
    run_step.dependOn(&run_cmd.step);
}
