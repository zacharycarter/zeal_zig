const Builder = @import("std").build.Builder;

pub fn build(b: *Builder) void {
    const mode = b.standardReleaseOptions();
    
    const zeal_editor_exe = b.addExecutable("zeal_editor", "src/main.zig");
    zeal_editor_exe.linkSystemLibrary("SDL2");
    zeal_editor_exe.setBuildMode(mode);

    const run_step = b.step("run", "Run the editor");
    const run_cmd = b.addCommand(".", b.env_map, [][]const u8{zeal_editor_exe.getOutputPath()});
    run_step.dependOn(&run_cmd.step);
    run_cmd.step.dependOn(&zeal_editor_exe.step);

    b.default_step.dependOn(&zeal_editor_exe.step);
    b.installArtifact(zeal_editor_exe);
}
