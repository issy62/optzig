const std = @import("std");
const testing = std.testing;

pub const ArgDefinitionError = error{
    EmptyName,
    EmptyDesc,
};

pub const ArgParserError = error{
    ErroneousInput,
    ArgumentNotDefined,
    BadBooleanInputValue,
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

pub const Arg = struct {
    const Self = @This();
    name: []const u8,
    description: []const u8,
    value: ArgTypes,

    pub fn make_arg(name: []const u8, desc: []const u8, value_type: ArgTypes) !Self {
        if (name.len == 0) return ArgDefinitionError.EmptyName;
        if (desc.len == 0) return ArgDefinitionError.EmptyDesc;

        return .{
            .name = name,
            .description = desc,
            .value = value_type,
        };
    }
};

fn parseToBool(str: []const u8) ArgParserError!bool {
    if (std.mem.eql(u8, str, "TRUE") or
        std.mem.eql(u8, str, "True") or
        std.mem.eql(u8, str, "true")) return true;

    if (std.mem.eql(u8, str, "FALSE") or
        std.mem.eql(u8, str, "False") or
        std.mem.eql(u8, str, "false")) return false;

    if (std.mem.eql(u8, str, "1")) return true;
    if (std.mem.eql(u8, str, "0")) return false;

    return ArgParserError.BadBooleanInputValue;
}

pub const Args = struct {
    const Self = @This();
    allocator: std.mem.Allocator,
    items: std.StringHashMap(Arg),

    pub fn init(allocator: std.mem.Allocator) Self {
        return .{
            .allocator = allocator,
            .items = std.StringHashMap(Arg).init(allocator),
        };
    }

    pub fn put(self: *Self, name: []const u8, desc: []const u8, value: ArgTypes) !void {
        const arg = try Arg.make_arg(name, desc, value);
        try self.items.put(name, arg);
    }

    inline fn parseBoolean(self: *Self, src: []const u8, active_key: []const u8) !void {
        if (self.items.getPtr(active_key)) |entry| {
            entry.value = ArgTypes{ .Boolean = parseToBool(src) catch |err| {
                return err;
            } };
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
                }
            },
            .Float64 => {
                if (self.items.getPtr(active_key)) |entry| {
                    entry.value = ArgTypes{ .Float64 = std.fmt.parseFloat(f64, src) catch |err| {
                        return err;
                    } };
                }
            },
            .Float128 => {
                if (self.items.getPtr(active_key)) |entry| {
                    entry.value = ArgTypes{ .Float128 = std.fmt.parseFloat(f128, src) catch |err| {
                        return err;
                    } };
                }
            },
            else => {},
        }
    }

    pub fn parse(self: *Self, comptime ItType: type, argv: *ItType) !void {
        switch (ItType) {
            std.process.ArgIterator, MockArgIterator => {
                _ = argv.skip(); // skip the  executable
                var active_key: []const u8 = "";

                while (argv.next()) |in| {
                    if (std.mem.startsWith(u8, in, "--")) {
                        const tmp = std.mem.trimLeft(u8, in, "--");
                        if (self.items.contains(tmp)) {
                            // Boolean togglable flag only works with double dash
                            const entry = self.items.get(tmp) orelse return ArgParserError.ErroneousInput;

                            if (std.meta.activeTag(entry.value) == .Boolean) {
                                if (self.items.getPtr(tmp)) |ptr| {
                                    ptr.value.Boolean = !entry.value.Boolean;
                                }
                            }

                            active_key = tmp;
                        } else {
                            return ArgParserError.ArgumentNotDefined;
                        }
                    } else if (std.mem.startsWith(u8, in, "-")) {
                        const tmp = std.mem.trimLeft(u8, in, "-");

                        // Check if the input is a negative numerical value or a float value stating with .
                        const is_num_val = tmp.len > 0 and (std.ascii.isDigit(tmp[0]) or tmp[0] == '.');

                        if (self.items.contains(tmp)) {
                            active_key = tmp;
                        } else if (is_num_val and active_key.len > 0) {
                            const entry = self.items.get(active_key) orelse return ArgParserError.ErroneousInput;
                            switch (entry.value) {
                                .Int32, .Int64, .Int128, .Float32, .Float64, .Float128 => {
                                    try parseNumeric(self, in, active_key);
                                },
                                else => return ArgParserError.ErroneousInput,
                            }
                        } else {
                            return ArgParserError.ArgumentNotDefined;
                        }
                    } else {
                        if (in.len == 0) {
                            // Handle empty string value
                            return ArgParserError.ErroneousInput;
                        } else {
                            const entry = self.items.get(active_key) orelse return ArgParserError.ErroneousInput;

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
            },
            else => @compileError("Only use ArgIterator (Release) and MockArgIterator (Testing)."),
        }
    }
};

// ========================================
// =               TESTING                =
// ========================================

const MockArgIterator = struct {
    args: []const []const u8,
    index: usize = 0,

    pub fn init(args_slice: []const []const u8) MockArgIterator {
        return .{ .args = args_slice };
    }

    pub fn skip(self: *MockArgIterator) ?[]const u8 {
        if (self.index < self.args.len) {
            const skipped = self.args[self.index];
            self.index += 1;
            return skipped;
        }
        return null;
    }

    pub fn next(self: *MockArgIterator) ?[]const u8 {
        if (self.index < self.args.len) {
            const next_arg = self.args[self.index];
            self.index += 1;
            return next_arg;
        }
        return null;
    }
};

test "Optzig.Arg make_arg validation" {
    const test_object = try Arg.make_arg("valid", "description", .{ .Boolean = false });

    try testing.expectEqualStrings("valid", test_object.name);
    try testing.expectEqualStrings("description", test_object.description);
    const data = .{ .Boolean = false };
    try testing.expectEqual(data.Boolean, test_object.value.Boolean);
}

test "Optzig.Arg make_arg empty name error check" {
    const test_object = Arg.make_arg("", "description", .{ .Boolean = false });

    try testing.expectError(ArgDefinitionError.EmptyName, test_object);
}

test "Optzig.Arg.make_arg empty description error check" {
    const test_object = Arg.make_arg("flag", "", .{ .Boolean = false });

    try testing.expectError(ArgDefinitionError.EmptyDesc, test_object);
}

test "Optzig parseToBool" {
    try testing.expectEqual(parseToBool("True"), true);
    try testing.expectEqual(parseToBool("true"), true);
    try testing.expectEqual(parseToBool("False"), false);
    try testing.expectEqual(parseToBool("false"), false);
    try testing.expectEqual(parseToBool("1"), true);
    try testing.expectEqual(parseToBool("0"), false);
}

test "Optzig parseToBool error check" {
    try testing.expectError(ArgParserError.BadBooleanInputValue, parseToBool("z3R0"));
}

test "Optzig.Args validation" {
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();

    var args = Args.init(arena.allocator());

    try args.put("verbose", "Set the application verbosity levels.", ArgTypes{ .Boolean = false });
    try args.put("port", "Set the server binding port.", ArgTypes{ .UInt32 = 8080 });

    try testing.expectEqualStrings("verbose", args.items.get("verbose").?.name);
    try testing.expectEqualStrings("Set the application verbosity levels.", args.items.get("verbose").?.description);
    try testing.expectEqual(false, args.items.get("verbose").?.value.Boolean);

    try testing.expectEqualStrings("port", args.items.get("port").?.name);
    try testing.expectEqualStrings("Set the server binding port.", args.items.get("port").?.description);
    try testing.expectEqual(8080, args.items.get("port").?.value.UInt32);
}

test "Optzig.Args parse validation" {
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();

    var args = Args.init(arena.allocator());

    try args.put("verbose", "Set the application verbosity levels.", ArgTypes{ .Boolean = false });
    try args.put("port", "Set the server binding port.", ArgTypes{ .UInt32 = 0 });

    var mock_it = MockArgIterator.init(&[_][]const u8{ "test", "--verbose", "false", "--port", "8080" });

    try args.parse(MockArgIterator, &mock_it);

    try testing.expectEqual(false, args.items.get("verbose").?.value.Boolean);
    try testing.expectEqual(8080, args.items.get("port").?.value.UInt32);
}

test "Optzig.Args parse ArgumentNotDefined" {
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();

    var args = Args.init(arena.allocator());

    try args.put("verbose", "Set the application verbosity levels.", ArgTypes{ .Boolean = false });

    var mock_it = MockArgIterator.init(&[_][]const u8{ "test", "--verbosity", "false" });

    const parse_res = args.parse(MockArgIterator, &mock_it);

    try testing.expectError(ArgParserError.ArgumentNotDefined, parse_res);
}

test "Optzig.Args parse negative value" {
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();

    var args = Args.init(arena.allocator());

    try args.put("sr", "Set the query search radious.", ArgTypes{ .Float32 = 0.0 });
    try args.put("scalar", "Multiplier factor.", ArgTypes{ .Int32 = 0 });

    var mock_it = MockArgIterator.init(&[_][]const u8{ "test", "--sr", "-12.5", "--scalar", "-54" });

    try args.parse(MockArgIterator, &mock_it);

    try testing.expectEqual(-12.5, args.items.get("sr").?.value.Float32);
    try testing.expectEqual(-54, args.items.get("scalar").?.value.Int32);
}

test "Optzig.Args parse single dash and negative number differentiation" {
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();

    var args = Args.init(arena.allocator());

    try args.put("search-radius", "Set the query search radious.", ArgTypes{ .Float32 = 0.0 });
    try args.put("scalar", "Multiplier factor.", ArgTypes{ .Int32 = 0 });

    var mock_it = MockArgIterator.init(&[_][]const u8{ "test", "-search-radius", "-.35", "-scalar", "-125" });

    try args.parse(MockArgIterator, &mock_it);

    try testing.expectEqual(-0.35, args.items.get("search-radius").?.value.Float32);
    try testing.expectEqual(-125, args.items.get("scalar").?.value.Int32);
}

test "Optzig.Args parse togglable boolean" {
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();

    var args = Args.init(arena.allocator());

    try args.put("verbose", "Toggle output verbosity.", ArgTypes{ .Boolean = false });

    var mock_it = MockArgIterator.init(&[_][]const u8{ "test", "--verbose" });

    try args.parse(MockArgIterator, &mock_it);

    try testing.expectEqual(true, args.items.get("verbose").?.value.Boolean);
}

