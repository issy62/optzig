const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});

    const optimize = b.standardOptimizeOption(.{});

    const module = b.addModule("optzig", .{ .root_source_file = b.path("src/optzig.zig") });

    const tests = b.addTest(.{
        .root_source_file = b.path("src/optzig.zig"),
        .target = target,
        .optimize = optimize,
    });

    tests.root_module.addImport("optzig", module);

    const exe = b.addExecutable(.{
        .name = "runner",
        .root_source_file = b.path("src/runner.zig"),
        .target = target,
        .optimize = optimize,
    });

    b.installArtifact(exe);

    exe.root_module.addImport("optzig", module);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());

    const run_tests = b.addRunArtifact(tests);
    run_tests.has_side_effects = true;

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_tests.step);
}

