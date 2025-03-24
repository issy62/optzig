const std = @import("std");
const opt = @import("optzig");

pub fn main() !void {
    const io = std.io.getStdErr().writer();
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
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

    try io.print("Arena Capacity: {}\n", .{arena.queryCapacity()});
    try io.print("Port Number: {d}\n", .{port_n});
    try io.print("To Number: {s}\n", .{to_n});
    try io.print("Vebose: {}\n", .{verb});
}
