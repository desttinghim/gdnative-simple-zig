const gdnative = @import("gdnative");
const api = gdnative.api;
const gd = gdnative.gd;

const Classes = gdnative.Classes;
const Godot = gdnative.Godot;

const Node = gdnative.Gen.Node;
const Node2D = gdnative.Gen.Node2D;

const String = gdnative.Types.String;
const Array = gdnative.Types.Array;
const Variant = gdnative.Types.Variant;

const std = @import("std");

pub const TestNode2D = struct {

    base: Node2D,
    data: i64,
    test_property: f32,
    setget_property: u16,

    pub const GodotClass = Classes.DefineGodotClass(TestNode2D, Node2D);
    pub usingnamespace GodotClass;

    const Self = @This();

    pub fn constructor(self: *Self) void {
        self.data = 0;
        self.test_property = 0;
        self.setget_property = 0;
    }

    pub fn destructor(self: *Self) void {
        _ = self;
    }

    pub fn registerMembers() void {
        Classes.registerMethod(Self, "_process", _process, gd.GODOT_METHOD_RPC_MODE_DISABLED);
        Classes.registerMethod(Self, "test_method", test_method, gd.GODOT_METHOD_RPC_MODE_DISABLED);
        Classes.registerMethod(Self, "test_return", test_return, gd.GODOT_METHOD_RPC_MODE_DISABLED);
        Classes.registerMethod(Self, "test_return_string", test_return_string, gd.GODOT_METHOD_RPC_MODE_DISABLED);
        Classes.registerMethod(Self, "test_return_array", test_return_array, gd.GODOT_METHOD_RPC_MODE_DISABLED);
        Classes.registerMethod(Self, "test_memnew_and_cast", test_memnew_and_cast, gd.GODOT_METHOD_RPC_MODE_DISABLED);

        Classes.registerFunction(Self, "test_static_function", test_static_function, gd.GODOT_METHOD_RPC_MODE_DISABLED);

        Classes.registerProperty(Self, "test_property", "test_property", @as(f32, 0), null, null,
            gd.GODOT_METHOD_RPC_MODE_DISABLED, gd.GODOT_PROPERTY_USAGE_DEFAULT, gd.GODOT_PROPERTY_HINT_NONE, ""
        );
        Classes.registerProperty(Self, "setget_property", "setget_property", @as(u16, 0), set_setget_property, get_setget_property,
            gd.GODOT_METHOD_RPC_MODE_DISABLED, gd.GODOT_PROPERTY_USAGE_DEFAULT, gd.GODOT_PROPERTY_HINT_NONE, ""
        );

        Classes.registerSignal(Self, "test_signal", .{ .{"arg0", i32}, .{"arg1", f32}, });
    }

    pub fn _process(self: *Self, delta: f64) void {
        _ = self;

        self.base.rotate(delta);
    }

    pub fn test_method(self: *const Self, a: i32, b: bool) void {
        _ = self;
        std.debug.print("test_method a:{} b:{}\n", .{a, b});
    }

    pub fn test_return(self: *Self, a: i64) i64 {
        self.data += a;
        return self.data;
    }

    pub fn test_return_string(self: *const Self) String {
        _ = self;
        return String.initUtf8("String returned from zig");
    }

    pub fn test_return_array(self: *const Self) Array {
        _ = self;

        var array = Array.init();
        array.pushBackVars(.{ true, 1337, 420.69, "My Variant String" });

        return array;
    }

    pub fn test_static_function(a: i64) void {
        std.debug.print("static_function:{}\n", .{a});
    }

    pub fn set_setget_property(self: *Self, value: u16) void {
        self.setget_property += value * 2;
    }

    pub fn get_setget_property(self: *const Self) u16 {
        return self.setget_property + 1;
    }

    pub fn test_memnew_and_cast(self: *const Self) void {
        {
            const node = TestNode2D._memnew();
            defer node.base.base.base.queueFree();
            const cast = Classes.castTo(Node2D, node);
            std.debug.print("Cast:{}\n", .{@ptrToInt(cast)});
        }

        {
            const node = Node._memnew();
            defer node.queueFree();
            const cast = Classes.castTo(Node2D, node);
            std.debug.print("Cast:{}\n", .{@ptrToInt(cast)}); //Null
        }

        {
            const child_node = self.base.base.base.getChild(0);
            const cast = Classes.castTo(Node2D, child_node);
            std.debug.print("Cast:{}\n", .{@ptrToInt(cast)});
        }

        {
            const child_node = self.base.base.base.getChild(0);
            const cast = Classes.castTo(TestNode2D, child_node);
            std.debug.print("Cast:{}\n", .{@ptrToInt(cast)});
        }
    }

};
