const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const lib_mod = b.createModule(.{
        .root_source_file = b.path("src/ansi.zig"),
        .target = target,
        .optimize = optimize,
    });
    const linkage = b.option(std.builtin.LinkMode, "linkage", "Linking type.") orelse .static;
    // library setup
    const lib = b.addLibrary(.{
        .name = "ansi_term",
        .root_module = lib_mod,
        .linkage = linkage,
    });
    b.installArtifact(lib);

    const lib_test_mod = b.createModule(.{
        .root_source_file = b.path("src/root.test.zig"),
        .target = target,
        .optimize = optimize,
    });
    // unit test setup
    const lib_unit_tests = b.addTest(.{
        .name = "test",
        .root_module = lib_test_mod,
    });
    const run_lib_unit_tests = b.addRunArtifact(lib_unit_tests);
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_lib_unit_tests.step);
}
