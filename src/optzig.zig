const std = @import("std");
const testing = std.testing;

pub const ArgDefinitionError = error{
    EmptyName,
    EmptyDesc,
    Duplicate,
};

pub const ArgParserError = error{
    ErroneousInput,
    ArgumentNotDefined,
    BadBooleanInputValue,
    RequiredArgument,
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
    required: bool,
    supplied: bool,
    value: ArgTypes,

    pub fn make_arg(name: []const u8, desc: []const u8, required: bool, value_type: ArgTypes) !Self {
        if (name.len == 0) return ArgDefinitionError.EmptyName;
        if (desc.len == 0) return ArgDefinitionError.EmptyDesc;

        return .{
            .name = name,
            .description = desc,
            .required = required,
            .supplied = false,
            .value = value_type,
        };
    }
};

inline fn parse_to_bool(str: []const u8) ArgParserError!bool {
    var buffer: [5]u8 = undefined;
    const sanitized_str = std.ascii.lowerString(&buffer, std.mem.trim(u8, str, &std.ascii.whitespace));

    if (sanitized_str.len == 1) {
        return switch (sanitized_str[0]) {
            '0' => false,
            '1' => true,
            else => return ArgParserError.ErroneousInput,
        };
    }

    if (std.mem.eql(u8, sanitized_str, "true")) return true;
    if (std.mem.eql(u8, sanitized_str, "false")) return false;

    return ArgParserError.BadBooleanInputValue;
}

pub const Args = struct {
    const Self = @This();
    allocator: std.mem.Allocator,
    args: std.StringHashMap(*Arg),

    pub fn init(allocator: std.mem.Allocator) Self {
        return .{
            .allocator = allocator,
            .args = std.StringHashMap(*Arg).init(allocator),
        };
    }

    pub fn add(self: *Self, name: []const u8, desc: []const u8, required: bool, value: ArgTypes) !void {
        if (self.args.contains(name)) {
            return ArgDefinitionError.Duplicate;
        }

        const arg = try self.allocator.create(Arg);
        arg.* = try Arg.make_arg(name, desc, required, value);
        try self.args.put(name, arg);
    }

    pub fn boolean(self: *Self, name: []const u8, desc: []const u8, required: bool, value: bool) !*bool {
        if (self.args.contains(name)) {
            return ArgDefinitionError.Duplicate;
        }

        const arg = try self.allocator.create(Arg);
        arg.* = try Arg.make_arg(name, desc, required, ArgTypes{ .Boolean = value });
        try self.args.put(name, arg);
        return &arg.value.Boolean;
    }

    pub fn int32(self: *Self, name: []const u8, desc: []const u8, required: bool, value: i32) !*i32 {
        if (self.args.contains(name)) {
            return ArgDefinitionError.Duplicate;
        }

        const arg = try self.allocator.create(Arg);
        arg.* = try Arg.make_arg(name, desc, required, ArgTypes{ .Int32 = value });
        try self.args.put(name, arg);
        return &arg.value.Int32;
    }

    pub fn int64(self: *Self, name: []const u8, desc: []const u8, required: bool, value: i64) !*i64 {
        if (self.args.contains(name)) {
            return ArgDefinitionError.Duplicate;
        }

        const arg = try self.allocator.create(Arg);
        arg.* = try Arg.make_arg(name, desc, required, ArgTypes{ .Int64 = value });
        try self.args.put(name, arg);
        return &arg.value.Int64;
    }

    pub fn int128(self: *Self, name: []const u8, desc: []const u8, required: bool, value: i128) !*i128 {
        if (self.args.contains(name)) {
            return ArgDefinitionError.Duplicate;
        }

        const arg = try self.allocator.create(Arg);
        arg.* = try Arg.make_arg(name, desc, required, ArgTypes{ .Int128 = value });
        try self.args.put(name, arg);
        return &arg.value.Int128;
    }

    pub fn uint32(self: *Self, name: []const u8, desc: []const u8, required: bool, value: u32) !*u32 {
        if (self.args.contains(name)) {
            return ArgDefinitionError.Duplicate;
        }

        const arg = try self.allocator.create(Arg);
        arg.* = try Arg.make_arg(name, desc, required, ArgTypes{ .UInt32 = value });
        try self.args.put(name, arg);
        return &arg.value.UInt32;
    }

    pub fn uint64(self: *Self, name: []const u8, desc: []const u8, required: bool, value: u64) !*u64 {
        if (self.args.contains(name)) {
            return ArgDefinitionError.Duplicate;
        }

        const arg = try self.allocator.create(Arg);
        arg.* = try Arg.make_arg(name, desc, required, ArgTypes{ .UInt64 = value });
        try self.args.put(name, arg);
        return &arg.value.UInt64;
    }

    pub fn uint128(self: *Self, name: []const u8, desc: []const u8, required: bool, value: u128) !*u128 {
        if (self.args.contains(name)) {
            return ArgDefinitionError.Duplicate;
        }

        const arg = try self.allocator.create(Arg);
        arg.* = try Arg.make_arg(name, desc, required, ArgTypes{ .UInt128 = value });
        try self.args.put(name, arg);
        return &arg.value.UInt128;
    }

    pub fn float32(self: *Self, name: []const u8, desc: []const u8, required: bool, value: f32) !*f32 {
        if (self.args.contains(name)) {
            return ArgDefinitionError.Duplicate;
        }

        const arg = try self.allocator.create(Arg);
        arg.* = try Arg.make_arg(name, desc, required, ArgTypes{ .Float32 = value });
        try self.args.put(name, arg);
        return &arg.value.Float32;
    }

    pub fn float64(self: *Self, name: []const u8, desc: []const u8, required: bool, value: f64) !*f64 {
        if (self.args.contains(name)) {
            return ArgDefinitionError.Duplicate;
        }

        const arg = try self.allocator.create(Arg);
        arg.* = try Arg.make_arg(name, desc, required, ArgTypes{ .Float64 = value });
        try self.args.put(name, arg);
        return &arg.value.Float64;
    }

    pub fn float128(self: *Self, name: []const u8, desc: []const u8, required: bool, value: f128) !*f128 {
        if (self.args.contains(name)) {
            return ArgDefinitionError.Duplicate;
        }

        const arg = try self.allocator.create(Arg);
        arg.* = try Arg.make_arg(name, desc, required, ArgTypes{ .Float128 = value });
        try self.args.put(name, arg);
        return &arg.value.Float128;
    }

    pub fn string(self: *Self, name: []const u8, desc: []const u8, required: bool, value: []const u8) !*[]const u8 {
        if (self.args.contains(name)) {
            return ArgDefinitionError.Duplicate;
        }

        const arg = try self.allocator.create(Arg);
        arg.* = try Arg.make_arg(name, desc, required, ArgTypes{ .String = value });
        try self.args.put(name, arg);
        return &arg.value.String;
    }

    pub fn get_value(self: Self, key: []const u8) !ArgTypes {
        const arg = self.args.get(key) orelse return ArgParserError.ArgumentNotDefined;
        return arg.value;
    }

    inline fn parse_boolean(self: *Self, src: []const u8, active_key: []const u8) !void {
        if (self.args.get(active_key)) |entry| {
            entry.value = ArgTypes{ .Boolean = parse_to_bool(src) catch |err| {
                return err;
            } };
        }
    }

    inline fn parse_string(self: *Self, src: []const u8, active_key: []const u8) !void {
        if (self.args.get(active_key)) |entry| {
            entry.value = ArgTypes{ .String = src };
        }
    }

    inline fn parse_numeric(self: *Self, src: []const u8, active_key: []const u8) !void {
        if (self.args.get(active_key)) |entry| {
            switch (entry.value) {
                .Int32 => {
                    entry.value = ArgTypes{ .Int32 = std.fmt.parseInt(i32, src, 10) catch |err| {
                        return err;
                    } };
                },
                .Int64 => {
                    entry.value = ArgTypes{ .Int64 = std.fmt.parseInt(i64, src, 10) catch |err| {
                        return err;
                    } };
                },
                .Int128 => {
                    entry.value = ArgTypes{ .Int128 = std.fmt.parseInt(i128, src, 10) catch |err| {
                        return err;
                    } };
                },
                .UInt32 => {
                    entry.value = ArgTypes{ .UInt32 = std.fmt.parseInt(u32, src, 10) catch |err| {
                        return err;
                    } };
                },
                .UInt64 => {
                    entry.value = ArgTypes{ .UInt64 = std.fmt.parseInt(u64, src, 10) catch |err| {
                        return err;
                    } };
                },
                .UInt128 => {
                    entry.value = ArgTypes{ .UInt128 = std.fmt.parseInt(u128, src, 10) catch |err| {
                        return err;
                    } };
                },
                .Float32 => {
                    entry.value = ArgTypes{ .Float32 = std.fmt.parseFloat(f32, src) catch |err| {
                        return err;
                    } };
                },
                .Float64 => {
                    entry.value = ArgTypes{ .Float64 = std.fmt.parseFloat(f64, src) catch |err| {
                        return err;
                    } };
                },
                .Float128 => {
                    entry.value = ArgTypes{ .Float128 = std.fmt.parseFloat(f128, src) catch |err| {
                        return err;
                    } };
                },
                else => return ArgParserError.ErroneousInput,
            }
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
                        if (self.args.contains(tmp)) {
                            // Boolean togglable flag only works with double dash
                            const entry = self.args.get(tmp) orelse return ArgParserError.ErroneousInput;

                            if (std.meta.activeTag(entry.value) == .Boolean) {
                                entry.value.Boolean = !entry.value.Boolean;
                            }

                            active_key = tmp;

                            if (entry.required) entry.*.supplied = true;
                        } else {
                            return ArgParserError.ArgumentNotDefined;
                        }
                    } else if (std.mem.startsWith(u8, in, "-")) {
                        const tmp = std.mem.trimLeft(u8, in, "-");

                        // Check if the input is a negative numerical value or a float value stating with .
                        const is_num_val = tmp.len > 0 and (std.ascii.isDigit(tmp[0]) or tmp[0] == '.');

                        if (self.args.contains(tmp)) {
                            active_key = tmp;
                            const entry = self.args.get(tmp) orelse return ArgParserError.ErroneousInput;
                            if (entry.required) entry.*.supplied = true;
                        } else if (is_num_val and active_key.len > 0) {
                            const entry = self.args.get(active_key) orelse return ArgParserError.ErroneousInput;
                            switch (entry.value) {
                                .Int32, .Int64, .Int128, .Float32, .Float64, .Float128 => {
                                    try parse_numeric(self, in, active_key);
                                },
                                else => return ArgParserError.ErroneousInput,
                            }

                            if (entry.required) entry.*.supplied = true;
                        } else {
                            return ArgParserError.ArgumentNotDefined;
                        }
                    } else {
                        if (in.len == 0) {
                            // Handle empty string value
                            return ArgParserError.ErroneousInput;
                        } else {
                            const entry = self.args.get(active_key) orelse return ArgParserError.ErroneousInput;

                            switch (entry.value) {
                                .Boolean => {
                                    try parse_boolean(self, in, active_key);
                                },
                                .Int32, .Int64, .Int128, .UInt32, .UInt64, .UInt128, .Float32, .Float64, .Float128 => {
                                    try parse_numeric(self, in, active_key);
                                },
                                .String => {
                                    try parse_string(self, in, active_key);
                                },
                            }
                        }
                    }
                }
            },
            else => @compileError("Only use ArgIterator (Release) and MockArgIterator (Testing)."),
        }
        // Check if the required arguments were passed otherwise error out.
        var passed_it = self.args.iterator();
        while (passed_it.next()) |passed| {
            if (passed.value_ptr.*.required and !passed.value_ptr.*.supplied) {
                return ArgParserError.RequiredArgument;
            }
        }
    }

    pub fn usage(self: *Self, callback: ?*const fn () void) !void {
        if (callback) |cb| {
            cb();
        } else {
            const io = std.io.getStdOut().writer();
            var it = self.args.valueIterator();

            try io.writeAll("USAGE\n");
            try io.writeAll("  Flags:\n");

            while (it.next()) |item| {
                try io.print("\t--{s} [{s}] - Required: {} - {s}\n", .{ item.*.name, item.*.value.toString(), item.*.required, item.*.description });
            }
            std.process.exit(0);
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
    const test_object = try Arg.make_arg("valid", "description", false, .{ .Boolean = false });

    try testing.expectEqualStrings("valid", test_object.name);
    try testing.expectEqualStrings("description", test_object.description);
    try testing.expectEqual(false, test_object.required);
    try testing.expectEqual(false, test_object.value.Boolean);
}

test "Optzig.Arg make_arg empty name error check" {
    const test_object = Arg.make_arg("", "description", false, .{ .Boolean = false });

    try testing.expectError(ArgDefinitionError.EmptyName, test_object);
}

test "Optzig.Arg.make_arg empty description error check" {
    const test_object = Arg.make_arg("flag", "", false, .{ .Boolean = false });

    try testing.expectError(ArgDefinitionError.EmptyDesc, test_object);
}

test "Optzig parse_to_bool" {
    try testing.expectEqual(parse_to_bool("True"), true);
    try testing.expectEqual(parse_to_bool("true"), true);
    try testing.expectEqual(parse_to_bool("False"), false);
    try testing.expectEqual(parse_to_bool("false"), false);
    try testing.expectEqual(parse_to_bool("1"), true);
    try testing.expectEqual(parse_to_bool("0"), false);
}

test "Optzig parse_to_bool error check" {
    try testing.expectError(ArgParserError.BadBooleanInputValue, parse_to_bool("z3R0"));
}

test "Optzig.Args validation" {
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();

    var args = Args.init(arena.allocator());

    try args.add("verbose", "Set the application verbosity levels.", false, ArgTypes{ .Boolean = false });
    try args.add("port", "Set the server binding port.", true, ArgTypes{ .UInt32 = 8080 });

    try testing.expectEqualStrings("verbose", args.args.get("verbose").?.name);
    try testing.expectEqualStrings("Set the application verbosity levels.", args.args.get("verbose").?.description);
    try testing.expectEqual(false, args.args.get("verbose").?.required);
    try testing.expectEqual(false, args.args.get("verbose").?.value.Boolean);

    try testing.expectEqualStrings("port", args.args.get("port").?.name);
    try testing.expectEqualStrings("Set the server binding port.", args.args.get("port").?.description);
    try testing.expectEqual(true, args.args.get("port").?.required);
    try testing.expectEqual(8080, args.args.get("port").?.value.UInt32);
}

test "Optzig.Args parse validation" {
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();

    var args = Args.init(arena.allocator());

    try args.add("verbose", "Set the application verbosity levels.", false, ArgTypes{ .Boolean = false });
    try args.add("port", "Set the server binding port.", false, ArgTypes{ .UInt32 = 0 });

    var mock_it = MockArgIterator.init(&[_][]const u8{ "test", "--verbose", "false", "--port", "8080" });

    try args.parse(MockArgIterator, &mock_it);

    try testing.expectEqual(false, args.args.get("verbose").?.value.Boolean);
    try testing.expectEqual(8080, args.args.get("port").?.value.UInt32);
}

test "Optzig.Args parse ArgumentNotDefined" {
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();

    var args = Args.init(arena.allocator());

    try args.add("verbose", "Set the application verbosity levels.", false, ArgTypes{ .Boolean = false });

    var mock_it = MockArgIterator.init(&[_][]const u8{ "test", "--verbosity", "false" });

    const parse_res = args.parse(MockArgIterator, &mock_it);

    try testing.expectError(ArgParserError.ArgumentNotDefined, parse_res);
}

test "Optzig.Args parse negative value" {
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();

    var args = Args.init(arena.allocator());

    try args.add("sr", "Set the query search radious.", false, ArgTypes{ .Float32 = 0.0 });
    try args.add("scalar", "Multiplier factor.", false, ArgTypes{ .Int32 = 0 });

    var mock_it = MockArgIterator.init(&[_][]const u8{ "test", "--sr", "-12.5", "--scalar", "-54" });

    try args.parse(MockArgIterator, &mock_it);

    try testing.expectEqual(-12.5, args.args.get("sr").?.value.Float32);
    try testing.expectEqual(-54, args.args.get("scalar").?.value.Int32);
}

test "Optzig.Args parse single dash and negative number differentiation" {
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();

    var args = Args.init(arena.allocator());

    try args.add("search-radius", "Set the query search radious.", false, ArgTypes{ .Float32 = 0.0 });
    try args.add("scalar", "Multiplier factor.", false, ArgTypes{ .Int32 = 0 });

    var mock_it = MockArgIterator.init(&[_][]const u8{ "test", "-search-radius", "-.35", "-scalar", "-125" });

    try args.parse(MockArgIterator, &mock_it);

    try testing.expectEqual(-0.35, args.args.get("search-radius").?.value.Float32);
    try testing.expectEqual(-125, args.args.get("scalar").?.value.Int32);
}

test "Optzig.Args parse togglable boolean" {
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();

    var args = Args.init(arena.allocator());

    try args.add("verbose", "Toggle output verbosity.", false, ArgTypes{ .Boolean = false });

    var mock_it = MockArgIterator.init(&[_][]const u8{ "test", "--verbose" });

    try args.parse(MockArgIterator, &mock_it);

    try testing.expectEqual(true, args.args.get("verbose").?.value.Boolean);
}

test "Optzig.Args binding functions" {
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();

    var args = Args.init(arena.allocator());

    const b = try args.boolean("bool", "Boolean flag", false, false);
    const i32_val = try args.int32("int32", "Int32 value", false, 0);
    const i64_val = try args.int64("int64", "Int64 value", false, 0);
    const i128_val = try args.int128("int128", "Int128 value", false, 0);
    const u32_val = try args.uint32("uint32", "UInt32 value", false, 0);
    const u64_val = try args.uint64("uint64", "UInt64 value", false, 0);
    const u128_val = try args.uint128("uint128", "UInt128 value", false, 0);
    const f32_val = try args.float32("float32", "Float32 value", false, 0.0);
    const f64_val = try args.float64("float64", "Float64 value", false, 0.0);
    const f128_val = try args.float128("float128", "Float128 value", false, 0.0);
    const str_val = try args.string("string", "String value", false, "");

    var mock_it = MockArgIterator.init(&[_][]const u8{ "test", "--bool", "true", "--int32", "-123", "--int64", "999999", "--int128", "-999999999", "--uint32", "456", "--uint64", "3000000", "--uint128", "123456789", "--float32", "2.5", "--float64", "3.14159", "--float128", "2.71828", "--string", "hello" });

    try args.parse(MockArgIterator, &mock_it);

    try testing.expectEqual(true, b.*);
    try testing.expectEqual(-123, i32_val.*);
    try testing.expectEqual(999999, i64_val.*);
    try testing.expectEqual(-999999999, i128_val.*);
    try testing.expectEqual(456, u32_val.*);
    try testing.expectEqual(3000000, u64_val.*);
    try testing.expectEqual(123456789, u128_val.*);
    try testing.expectEqual(@as(f32, 2.5), f32_val.*);
    try testing.expectEqual(@as(f64, 3.14159), f64_val.*);
    try testing.expectEqual(@as(f128, 2.71828), f128_val.*);
    try testing.expectEqualStrings("hello", str_val.*);
}

test "Optzig.Args required argument not passed error" {
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();

    var args = Args.init(arena.allocator());

    _ = try args.string("config", "Path to the configuration file.", true, "");
    _ = try args.boolean("verbose", "Increate the verbosity levels.", false, false);

    var mock_it = MockArgIterator.init(&[_][]const u8{ "test", "--verbose" });

    const parse_res = args.parse(MockArgIterator, &mock_it);

    try testing.expectError(ArgParserError.RequiredArgument, parse_res);
}

test "Optzig.Args required argument passed" {
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();

    var args = Args.init(arena.allocator());

    const config = try args.string("config", "Path to the configuration file.", true, "");
    const verbose = try args.boolean("verbose", "Increate the verbosity levels.", false, false);

    var mock_it = MockArgIterator.init(&[_][]const u8{ "test", "--config", "~/.config/app/conf.json", "--verbose" });

    try args.parse(MockArgIterator, &mock_it);

    try testing.expectEqual("~/.config/app/conf.json", config.*);
    try testing.expectEqual(true, verbose.*);
}

