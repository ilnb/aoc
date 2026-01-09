const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const main_exe = b.addExecutable(.{
        .name = "main",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .optimize = optimize,
            .target = target,
        }),
    });
    b.installArtifact(main_exe);

    const main_run_step = b.step("run_main", "Run main.zig");
    const main_cmd = b.addRunArtifact(main_exe);
    main_run_step.dependOn(&main_cmd.step);
    main_cmd.step.dependOn(b.getInstallStep());

    const arr_exe = b.addExecutable(.{
        .name = "arr",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/arr.zig"),
            .optimize = optimize,
            .target = target,
        }),
    });
    b.installArtifact(arr_exe);

    const arr_run_step = b.step("run_arr", "Run arr.zig");
    const arr_cmd = b.addRunArtifact(arr_exe);
    arr_run_step.dependOn(&arr_cmd.step);
    arr_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        main_cmd.addArgs(args);
        arr_cmd.addArgs(args);
    }
}
