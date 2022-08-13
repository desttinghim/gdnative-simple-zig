# GDNative Simple in Zig

This is a small example of working with the GDNative API from Zig. Ideally this should be a lot easier, but a bug with the Zig compiler generates the incorrect ABI for passing small structs. This causes mysterious and confusing segfaults.

To solve this I made some small wrapper functions in C to handle those functions, and then I called them from zig.
