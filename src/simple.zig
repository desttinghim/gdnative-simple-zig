const c = @import("c.zig");
const std = @import("std");

const GDNativeAPI = struct {
    api: *const c.godot_gdnative_core_api_struct,
    nativescript_api: *const c.godot_gdnative_ext_nativescript_api_struct,

    pub fn init(p_options: *c.godot_gdnative_init_options) !GDNativeAPI {
        const api: *const c.godot_gdnative_core_api_struct = p_options.api_struct;

        // Find NativeScript extensions.
        const nativescript_api = nativescript_api: {
            const extensions = api.extensions[0..api.num_extensions];
            for (extensions) |ext, i| {
                const extension: *const c.godot_gdnative_api_struct = ext;
                switch (extension.type) {
                    c.GDNATIVE_EXT_NATIVESCRIPT => break :nativescript_api @ptrCast(*const c.godot_gdnative_ext_nativescript_api_struct, api.extensions[i]),
                    else => {},
                }
            }
            return error.MissingNativeScriptExtension;
        };

        return GDNativeAPI{
            .api = api,
            .nativescript_api = nativescript_api,
        };
    }

    pub fn deinit(_: GDNativeAPI, p_options: *c.godot_gdnative_terminate_options) void {
        _ = p_options;
    }
};

var gd: GDNativeAPI = undefined;

export fn godot_gdnative_init(p_options: *c.godot_gdnative_init_options) callconv(.C) void {
    gd = GDNativeAPI.init(p_options) catch @panic("Could not initialize");
}

export fn godot_gdnative_terminate(p_options: *c.godot_gdnative_terminate_options) callconv(.C) void {
    gd.deinit(p_options);
}

const UserData = struct {
    data: [256]u8,
};

export fn godot_nativescript_init(p_handle: *anyopaque) callconv(.C) void {
    const builder = c.init_class_builder(gd.api, p_handle, "Simple", "Reference");
    c.init_class_constructor(builder, constructor, null, null);
    c.init_class_destructor(builder, destructor, null, null);
    c.finalize_class(gd.api, gd.nativescript_api, builder);

    const attributes: c.godot_method_attributes = .{ .rpc_type = c.GODOT_METHOD_RPC_MODE_DISABLED };
    c.init_class_method(gd.nativescript_api, p_handle, "Simple", "get_data", attributes, get_data, null, null);
}

export fn constructor(p_instance: ?*c.godot_object, method_data: ?*anyopaque) callconv(.C) ?*anyopaque {
    _ = p_instance;
    _ = method_data;
    var user_data: *UserData = @ptrCast(*UserData, gd.api.godot_alloc.?(@sizeOf(UserData)));
    _ = std.fmt.bufPrintZ(&user_data.data, "World from GDNative", .{}) catch unreachable;

    return user_data;
}

export fn destructor(p_instance: ?*c.godot_object, method_data: ?*anyopaque, p_user_data: ?*anyopaque) callconv(.C) void {
    _ = p_instance;
    _ = method_data;
    gd.api.godot_free.?(p_user_data);
}

export fn get_data(p_instance: ?*c.godot_object, method_data: ?*anyopaque, p_user_data: ?*anyopaque, num_args: c_int, args: [*c][*c]c.godot_variant) callconv(.C) c.godot_variant {
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
