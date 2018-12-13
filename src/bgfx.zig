pub use @cImport({
    // See https://github.com/zig-lang/zig/issues/515
    @cDefine("_NO_CRT_STDIO_INLINE", "1");
    @cInclude("bgfx/c99/platform.h");
    @cInclude("bgfx/c99/bgfx.h");
});