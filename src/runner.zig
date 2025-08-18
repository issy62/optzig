const std = @import("std");
const opt = @import("optzig");

pub fn main() !void {
    const io = std.io.getStdOut().writer();

    var arena = std.heap.ArenaAllocator.init(std.heap.smp_allocator);
    defer arena.deinit();

    var arg_iputs = try std.process.argsWithAllocator(arena.allocator());

    var ag = opt.Args.init(arena.allocator());
    const verb = try ag.boolean("verbose", "verbosity level", false, false);
    const port = try ag.int32("port", "binding port", false, 0);
    const to = try ag.string("to", "outbound phone number", true, "");
    const help = try ag.boolean("help", "Print this usage", false, false);

    ag.parse(std.process.ArgIterator, &arg_iputs) catch |err| {
        switch (err) {
            opt.ArgParserError.RequiredArgument => try ag.usage(null),
            else => return err,
        }
    };

    if (help.*) {
        try ag.usage(null);
    }

    try io.print("Port Number: {d}\n", .{port.*});
    try io.print("To Number: {s}\n", .{to.*});
    try io.print("Vebose: {}\n", .{verb.*});
}

