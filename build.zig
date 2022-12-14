const std = @import("std");

pub fn build(b: *std.build.Builder) void {
    const target = b.standardTargetOptions(.{});
    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const mode = b.standardReleaseOptions();

    const lib = b.addSharedLibrary("simple", "src/main.zig", b.version(0, 1, 0));
    lib.setTarget(target);
    lib.setBuildMode(mode);
    lib.linkLibC();
    lib.addIncludeDir("deps/godot-headers");
    lib.addIncludeDir("src/");
    lib.addCSourceFile("src/simple.c", &.{});

    lib.force_pic = true;

    lib.install();
}
