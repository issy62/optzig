const std = @import("std");
const opt = @import("optzig");
const builtin = @import("builtin");
const compressor = std.compress.zlib;

const BUILD_MODE = builtin.mode;

pub fn main() !void {
    const io = std.io.getStdErr().writer();

    var dba: if (BUILD_MODE == .Debug) std.heap.DebugAllocator(.{}) else void =
        if (BUILD_MODE == .Debug) std.heap.DebugAllocator(.{}).init else {};

    var arena = std.heap.ArenaAllocator.init(switch (BUILD_MODE) {
        .ReleaseFast, .ReleaseSmall, .ReleaseSafe => std.heap.smp_allocator,
        .Debug => dba.allocator(),
    });

    defer arena.deinit();

    var ag = opt.Args.init(&arena);

    try ag.put("verbose", "verbosity level", opt.ArgTypes{ .Boolean = false });
    try ag.put("port", "binding port", opt.ArgTypes{ .Float32 = undefined });
    try ag.put("to", "outbound phone number", opt.ArgTypes{ .String = undefined });

    var arg_iputs = try std.process.argsWithAllocator(arena.allocator());

    try ag.parse(&arg_iputs);

    const port_n = ag.items.get("port").?.value.Float32;
    const to_n = ag.items.get("to").?.value.String;
    const verb = ag.items.get("verbose").?.value.Boolean;

    try io.print("Port Number: {d}\n", .{port_n});
    try io.print("To Number: {s}\n", .{to_n});
    try io.print("Vebose: {}\n", .{verb});
}

