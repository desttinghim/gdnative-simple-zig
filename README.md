# GDNative Simple in Zig

This is a small example of working with the GDNative API from Zig. Ideally this should be a lot easier, but a bug with the Zig compiler generates the incorrect ABI for passing small structs. This causes mysterious and confusing segfaults.

To solve this I made some small wrapper functions in C to handle those functions, and then I called them from zig.

## Dependencies

- [zig (master branch)](https://ziglang.org/)
- [Godot 3.4.4 Stable](https://godotengine.org/)

## Usage

*NOTE:* This has only been tested for Linux 64-bit in Godot 3.4.4 Stable. It will probably work for other platforms but you won't know until you try it.

This project uses a submodule for the `godot-headers` repository, so clone the repository recursively:

``` bash
git clone --recursive https://github.com/desttinghim/gdnative-simple-zig
cd gdnative-simple-zig
zig build
godot
```

Clicking the button should show the string "Data = World from GDNative" to the screen.
