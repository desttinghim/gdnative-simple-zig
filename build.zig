const std = @import("std");

const pkgs = struct {
    const gdnative = std.build.Pkg{
        .name = "gdnative",
        .source = .{ .path = "deps/GodotZigBindings/src/lib.zig" },
        .dependencies = &[_]std.build.Pkg{},
    };
};


pub fn build(b: *std.build.Builder) void {
    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const mode = b.standardReleaseOptions();

    const lib = b.addSharedLibrary("simple", "src/simple.zig", b.version(0, 1, 0));
    // lib.addPackage(pkgs.gdnative);
    lib.setBuildMode(mode);

    lib.force_pic = true;

    lib.linkLibC();
    lib.addIncludeDir("deps/godot-headers");
    lib.addIncludeDir("src/");
    // lib.addIncludeDir("deps/GodotZigBindings/src/");
    lib.addCSourceFile("src/simple.c", &.{});

    lib.install();
}
