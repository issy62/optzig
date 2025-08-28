const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});

    const optimize = b.standardOptimizeOption(.{});

    const options = b.addOptions();

    const use_llvm = b.option(bool, "use_llvm", "Allows you to swap between LLVM or the x86 backend.") orelse true;

    options.addOption(bool, "use_llvm", use_llvm);

    const module = b.addModule("optzig", .{
        .root_source_file = b.path("src/optzig.zig"),
        .target = target,
        .optimize = optimize,
    });

    const optizg_object = b.addObject(.{
        .name = "optzig",
        .root_module = module,
        .use_llvm = use_llvm,
    });

    const tests = b.addTest(.{
        .root_module = module,
        .use_llvm = use_llvm,
    });

    tests.root_module.addImport("optzig", module);
    tests.root_module.addOptions("add_options", options);

    const exe = b.addExecutable(.{
        .name = "runner",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/runner.zig"),
            .target = target,
            .optimize = optimize,
        }),
        .use_llvm = use_llvm,
    });

    b.installArtifact(exe);

    exe.root_module.addImport("optzig", module);
    exe.root_module.addOptions("add_options", options);

    const doc = b.addInstallDirectory(.{
        .source_dir = optizg_object.getEmittedDocs(),
        .install_dir = .prefix,
        .install_subdir = "docs",
    });

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

    const doc_step = b.step("docs", "Generate docs to ziz-out/docs");
    doc_step.dependOn(&doc.step);
}

