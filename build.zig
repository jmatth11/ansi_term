const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const root_file = b.path("src/ansi.zig");
    // library setup
    const lib = b.addStaticLibrary(.{
        .name = "ansi_term",
        .root_source_file = root_file,
        .target = target,
        .optimize = optimize,
    });
    b.installArtifact(lib);

    // add as module to be imported
    _ = b.addModule("ansi", .{
        .root_source_file = root_file,
    });

    // unit test setup
    const lib_unit_tests = b.addTest(.{
        .root_source_file = b.path("src/root.test.zig"),
        .target = target,
        .optimize = optimize,
    });
    const run_lib_unit_tests = b.addRunArtifact(lib_unit_tests);
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_lib_unit_tests.step);
}
