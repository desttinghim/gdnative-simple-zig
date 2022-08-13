const c = @import("c.zig");
const GD = @import("gdnative.zig");

const Simple = @import("simple.zig");

var _gd: GD.NativeAPI = undefined;
pub const gd = &_gd;

export fn godot_gdnative_init(p_options: *GD.NativeAPI.InitOptions) callconv(.C) void {
    _gd = GD.NativeAPI.init(p_options) catch @panic("Could not initialize");
}

export fn godot_gdnative_terminate(p_options: *c.godot_gdnative_terminate_options) callconv(.C) void {
    _gd.deinit(p_options);
}

export fn godot_nativescript_init(p_handle: *anyopaque) callconv(.C) void {
    _gd.setHandle(p_handle);

    _gd.registerClass(Simple.name, Simple.base, Simple.constructor, Simple.destructor);
    _gd.registerMethod(Simple.name, "get_data", Simple.get_data);
}
