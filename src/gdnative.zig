const c = @import("c.zig");
const std = @import("std");

pub const NativeAPI = struct {
    api: *const c.godot_gdnative_core_api_struct,
    nativescript_api: *const c.godot_gdnative_ext_nativescript_api_struct,
    p_handle: *anyopaque,

    pub const InitOptions = c.godot_gdnative_init_options;

    pub fn init(p_options: *InitOptions) !NativeAPI {
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

        return NativeAPI{
            .api = api,
            .nativescript_api = nativescript_api,
            .p_handle = undefined,
        };
    }

    pub fn deinit(_: NativeAPI, p_options: *c.godot_gdnative_terminate_options) void {
        _ = p_options;
    }

    pub fn setHandle(gd: *NativeAPI, p_handle: *anyopaque) void {
        gd.p_handle = p_handle;
    }

    const ConstructorFn = fn (?*c.godot_object, ?*anyopaque) callconv(.C) ?*anyopaque;
    const DestructorFn = fn (?*c.godot_object, ?*anyopaque, ?*anyopaque) callconv(.C) void;
    const MethodFn = fn (?*c.godot_object, ?*anyopaque, ?*anyopaque, c_int, [*c][*c]c.godot_variant) callconv(.C) c.godot_variant;

    pub fn registerClass(gd: NativeAPI, name: [*:0]const u8, base: [*:0]const u8, constructor: ConstructorFn, destructor: DestructorFn) void {
        const builder = c.init_class_builder(gd.api, gd.p_handle, name, base);
        c.init_class_constructor(builder, constructor, null, null);
        c.init_class_destructor(builder, destructor, null, null);
        c.finalize_class(gd.api, gd.nativescript_api, builder);
    }

    pub fn registerMethod(gd: NativeAPI, name: [*:0]const u8, method_name: [*:0]const u8, method: MethodFn) void {
        const attributes: c.godot_method_attributes = .{ .rpc_type = c.GODOT_METHOD_RPC_MODE_DISABLED };
        c.init_class_method(gd.nativescript_api, gd.p_handle, name, method_name, attributes, method, null, null);
    }
};
