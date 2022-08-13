const c = @import("c.zig");
const std = @import("std");
const GD = @import("gdnative.zig");

const gd = @import("main.zig").gd;

pub const name = "Simple";
pub const base = "Reference";

const UserData = struct {
    data: [256]u8,
};

pub export fn constructor(p_instance: ?*c.godot_object, method_data: ?*anyopaque) callconv(.C) ?*anyopaque {
    _ = p_instance;
    _ = method_data;
    var user_data: *UserData = @ptrCast(*UserData, gd.api.godot_alloc.?(@sizeOf(UserData)));
    _ = std.fmt.bufPrintZ(&user_data.data, "World from GDNative", .{}) catch unreachable;

    return user_data;
}

pub export fn destructor(p_instance: ?*c.godot_object, method_data: ?*anyopaque, p_user_data: ?*anyopaque) callconv(.C) void {
    _ = p_instance;
    _ = method_data;
    gd.api.godot_free.?(p_user_data);
}

pub export fn get_data(p_instance: ?*c.godot_object, method_data: ?*anyopaque, p_user_data: ?*anyopaque, num_args: c_int, args: [*c][*c]c.godot_variant) callconv(.C) c.godot_variant {
    _ = p_instance;
    _ = method_data;
    _ = num_args;
    _ = args;
    var data: c.godot_string = undefined;
    var ret: c.godot_variant = undefined;
    var user_data: *UserData = @ptrCast(*UserData, p_user_data);

    gd.api.godot_string_new.?(&data);
    _ = gd.api.godot_string_parse_utf8.?(&data, &user_data.data);
    gd.api.godot_variant_new_string.?(&ret, &data);
    gd.api.godot_string_destroy.?(&data);

    return ret;
}
