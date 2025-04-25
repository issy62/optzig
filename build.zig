const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});

    const optimize = b.standardOptimizeOption(.{});

    const module = b.addModule("optzig", .{ .root_source_file = b.path("src/optzig.zig") });

    const lib = b.addStaticLibrary(.{
        .name = "optzig",
        .root_source_file = b.path("src/optzig.zig"),
        .target = target,
        .optimize = optimize,
    });

    lib.root_module.addImport("optzig", module);

    b.installArtifact(lib);

    const lib_unit_tests = b.addTest(.{
        .root_source_file = b.path("src/optzig.zig"),
        .target = target,
        .optimize = optimize,
    });

    lib_unit_tests.root_module.addImport("optzig", module);

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

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    const run_lib_unit_tests = b.addRunArtifact(lib_unit_tests);
    run_lib_unit_tests.has_side_effects = true;

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_lib_unit_tests.step);
}

