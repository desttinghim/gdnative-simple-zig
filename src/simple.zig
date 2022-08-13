const c = @import("c.zig");
const std = @import("std");

extern const api: ?*c.godot_gdnative_core_api_struct;
extern const nativescript_api: ?*c.godot_gdnative_ext_nativescript_api_struct;

export fn nativescript_init(p_handle: *anyopaque) void {
    const builder = c.init_class_builder(p_handle, "Simple", "Reference");
    c.init_class_constructor(builder, constructor, null, null);
    c.init_class_destructor(builder, destructor, null, null);
    c.finalize_class(builder);

    const attributes: c.godot_method_attributes = .{ .rpc_type = c.GODOT_METHOD_RPC_MODE_DISABLED };
    c.init_class_method(p_handle, "Simple", "get_data", attributes, get_data, null, null);
}

export fn constructor(p_instance: ?*c.godot_object, method_data: ?*anyopaque) callconv(.C) ?*anyopaque {
    _ = p_instance;
    _ = method_data;
    var user_data: *c.user_data_struct = @ptrCast(*c.user_data_struct, api.?.godot_alloc.?(@sizeOf(c.user_data_struct)));
    _ = std.fmt.bufPrintZ(&user_data.data, "World from GDNative", .{}) catch unreachable;

    return user_data;
}

export fn destructor(p_instance: ?*c.godot_object, method_data: ?*anyopaque, p_user_data: ?*anyopaque) callconv(.C) void {
    _ = p_instance;
    _ = method_data;
    api.?.godot_free.?(p_user_data);
}

export fn get_data(p_instance: ?*c.godot_object, method_data: ?*anyopaque, p_user_data: ?*anyopaque, num_args: c_int, args: [*c][*c]c.godot_variant) callconv(.C) c.godot_variant {
    _ = p_instance;
    _ = method_data;
    _ = num_args;
    _ = args;
    var data: c.godot_string = undefined;
    var ret: c.godot_variant = undefined;
    var user_data: *c.user_data_struct = @ptrCast(*c.user_data_struct, p_user_data);

    api.?.godot_string_new.?(&data);
    _ = api.?.godot_string_parse_utf8.?(&data, &user_data.data);
    api.?.godot_variant_new_string.?(&ret, &data);
    api.?.godot_string_destroy.?(&data);

    return ret;
}
