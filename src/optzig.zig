const std = @import("std");
const testing = std.testing;

pub const Error = error{
    ArgDefinitionEmptyName,
    ArgDefinitionEmptyDesc,
    ErroneusInput,
    BadBooleanInputValue,
    InfiniteFloat,
};

pub const ArgTypes = union(enum) {
    Boolean: bool,
    Int32: i32,
    Int64: i64,
    Int128: i128,
    UInt32: u32,
    UInt64: u64,
    UInt128: u128,
    Float32: f32,
    Float64: f64,
    Float128: f128,
    String: []const u8,

    pub fn toString(self: ArgTypes) []const u8 {
        return switch (self) {
            .Boolean => "bool",
            .Int32 => "i32",
            .Int64 => "i64",
            .Int128 => "i128",
            .UInt32 => "u32",
            .UInt64 => "u64",
            .UInt128 => "u128",
            .Float32 => "f32",
            .Float64 => "f64",
            .Float128 => "f128",
            .String => "[]const u8",
        };
    }
};

pub const ArgTypeValidity = enum {
    Invalid,
    Valid,
};

pub const Arg = struct {
    const Self = @This();
    name: []const u8,
    description: []const u8,
    value: ArgTypes,

    pub fn make_arg(arena: *std.heap.ArenaAllocator, name: []const u8, desc: []const u8, value_type: ArgTypes) !Self {
        if (name.len == 0) return Error.ArgDefinitionEmptyName;
        if (desc.len == 0) return Error.ArgDefinitionEmptyDesc;

        const temp_name = try std.mem.concat(arena.allocator(), u8, &[_][]const u8{ "--", name });

        return .{
            .name = temp_name,
            .description = desc,
            .value = value_type,
        };
    }
};

inline fn parseToBool(str: []const u8) !bool {
    if (std.mem.eql(u8, str, "true")) return true;
    if (std.mem.eql(u8, str, "false")) return false;
    if (std.mem.eql(u8, str, "1")) return true;
    if (std.mem.eql(u8, str, "0")) return false;

    return Error.BadBooleanInputValue;
}

pub const Args = struct {
    const Self = @This();
    arena: *std.heap.ArenaAllocator,
    items: std.StringHashMap(Arg),

    pub fn init(arena: *std.heap.ArenaAllocator) Self {
        return .{
            .arena = arena,
            .items = std.StringHashMap(Arg).init(arena.allocator()),
        };
    }

    pub fn put(self: *Self, name: []const u8, desc: []const u8, value: ArgTypes) !void {
        const arg = try Arg.make_arg(self.arena, name, desc, value);
        try self.items.put(name, arg);
    }

    pub fn deinit(self: *Self) void {
        self.arena.deinit();
    }

    inline fn parseBoolean(self: *Self, src: []const u8, active_key: []const u8) !void {
        if (self.items.getPtr(active_key)) |entry| {
            if (std.mem.eql(u8, src, "")) {
                entry.value = ArgTypes{ .Boolean = true };
            } else {
                entry.value = ArgTypes{ .Boolean = parseToBool(src) catch |err| {
                    return err;
                } };
            }
        }
    }

    inline fn parseString(self: *Self, src: []const u8, active_key: []const u8) !void {
        if (self.items.getPtr(active_key)) |entry| {
            entry.value = ArgTypes{ .String = src };
        }
    }

    inline fn parseNumeric(self: *Self, src: []const u8, active_key: []const u8) !void {
        switch (self.items.get(active_key).?.value) {
            .Int32 => {
                if (self.items.getPtr(active_key)) |entry| {
                    entry.value = ArgTypes{ .Int32 = std.fmt.parseInt(i32, src, 10) catch |err| {
                        return err;
                    } };
                }
            },
            .Int64 => {
                if (self.items.getPtr(active_key)) |entry| {
                    entry.value = ArgTypes{ .Int64 = std.fmt.parseInt(i64, src, 10) catch |err| {
                        return err;
                    } };
                }
            },
            .Int128 => {
                if (self.items.getPtr(active_key)) |entry| {
                    entry.value = ArgTypes{ .Int128 = std.fmt.parseInt(i128, src, 10) catch |err| {
                        return err;
                    } };
                }
            },
            .UInt32 => {
                if (self.items.getPtr(active_key)) |entry| {
                    entry.value = ArgTypes{ .UInt32 = std.fmt.parseInt(u32, src, 10) catch |err| {
                        return err;
                    } };
                }
            },
            .UInt64 => {
                if (self.items.getPtr(active_key)) |entry| {
                    entry.value = ArgTypes{ .UInt64 = std.fmt.parseInt(u64, src, 10) catch |err| {
                        return err;
                    } };
                }
            },
            .UInt128 => {
                if (self.items.getPtr(active_key)) |entry| {
                    entry.value = ArgTypes{ .UInt128 = std.fmt.parseInt(u128, src, 10) catch |err| {
                        return err;
                    } };
                }
            },
            .Float32 => {
                if (self.items.getPtr(active_key)) |entry| {
                    entry.value = ArgTypes{ .Float32 = std.fmt.parseFloat(f32, src) catch |err| {
                        return err;
                    } };

                    if (std.math.isInf(entry.value.Float32)) {
                        return Error.InfiniteFloat;
                    }
                }
            },
            .Float64 => {
                if (self.items.getPtr(active_key)) |entry| {
                    entry.value = ArgTypes{ .Float64 = std.fmt.parseFloat(f64, src) catch |err| {
                        return err;
                    } };

                    if (std.math.isInf(entry.value.Float64)) {
                        return Error.InfiniteFloat;
                    }
                }
            },
            .Float128 => {
                if (self.items.getPtr(active_key)) |entry| {
                    entry.value = ArgTypes{ .Float128 = std.fmt.parseFloat(f128, src) catch |err| {
                        return err;
                    } };

                    if (std.math.isInf(entry.value.Float128)) {
                        return Error.InfiniteFloat;
                    }
                }
            },
            else => {},
        }
    }

    pub fn parse(self: *Self, argv: *std.process.ArgIterator) !void {
        _ = argv.skip(); // skip the  executable
        var active_key: []const u8 = "";

        while (argv.next()) |in| {
            if (std.mem.startsWith(u8, in, "--")) {
                const tmp = std.mem.trimLeft(u8, in, "--");
                if (self.items.contains(tmp)) {
                    active_key = tmp;
                } else {
                    std.log.debug("Argument was not defined\n", .{});
                    return Error.ErroneusInput;
                }
            } else if (std.mem.startsWith(u8, in, "-")) {
                const tmp = std.mem.trimLeft(u8, in, "-");
                if (self.items.contains(tmp)) {
                    active_key = tmp;
                } else {
                    std.log.debug("Argument was not defined\n", .{});
                    return Error.ErroneusInput;
                }
            } else {
                if (in.len == 0) {
                    std.log.debug("Input: {s}", .{in});
                    return Error.ErroneusInput;
                } else {
                    const entry = self.items.get(active_key) orelse return Error.ErroneusInput;

                    switch (entry.value) {
                        .Boolean => {
                            try parseBoolean(self, in, active_key);
                        },
                        .Int32, .Int64, .Int128, .UInt32, .UInt64, .UInt128, .Float32, .Float64, .Float128 => {
                            try parseNumeric(self, in, active_key);
                        },
                        .String => {
                            try parseString(self, in, active_key);
                        },
                    }
                }
            }
        }
    }
};

test "Arg Init Test" {
    var my_arg = try Arg(bool).make_arg(testing.allocator, "verbose", "Verbose", false);
    defer my_arg.freeArg(testing.allocator);
}

