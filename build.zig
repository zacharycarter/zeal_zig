const Builder = @import("std").build.Builder;

pub fn build(b: *Builder) void {
    const mode = b.standardReleaseOptions();
    const exe = b.addExecutable("zeal", "src/main.zig");
    exe.addIncludeDir("/usr/local/include/bx");
    exe.linkSystemLibrary("csfml-window");
    exe.linkSystemLibrary("csfml-network");
    exe.linkSystemLibrary("bgfx-shared-libDebug");
    exe.linkSystemLibrary("c");
    exe.setBuildMode(mode);

    const run_step = b.step("run", "Run the app");
    const run_cmd = b.addCommand(".", b.env_map, [][]const u8{exe.getOutputPath()});
    run_step.dependOn(&run_cmd.step);
    run_cmd.step.dependOn(&exe.step);

    b.default_step.dependOn(&exe.step);
    b.installArtifact(exe);
}
