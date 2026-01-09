const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const dsu = b.createModule(.{
        .root_source_file = b.path("src/dsu.zig"),
        .optimize = optimize,
        .target = target,
    });

    const main_exe = b.addExecutable(.{
        .name = "main",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .optimize = optimize,
            .target = target,
            .imports = &.{
                .{ .name = "dsu", .module = dsu },
            },
        }),
    });
    b.installArtifact(main_exe);

    const main_run_step = b.step("run", "Run main.zig");
    const main_cmd = b.addRunArtifact(main_exe);
    main_run_step.dependOn(&main_cmd.step);
    main_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        main_cmd.addArgs(args);
    }
}
