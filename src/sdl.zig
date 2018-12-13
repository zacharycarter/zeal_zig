const c = @cImport({
    // See https://github.com/zig-lang/zig/issues/515
    @cDefine("_NO_CRT_STDIO_INLINE", "1");
    @cInclude("SDL2/SDL.h");
    @cInclude("SDL2/SDL_syswm.h");
});

pub use c;

pub inline fn SDL_VERSIONNUM(x: comptime_int, y: comptime_int, z: comptime_int) comptime_int {
    return x * 1000 + y * 100 + z;
}

pub inline fn SDL_VERSION(version: *SDL_version) void {
    version.major = c.SDL_MAJOR_VERSION;
    version.minor = c.SDL_MINOR_VERSION;
    version.patch = c.SDL_PATCHLEVEL;
}

pub const SDL_WINDOWPOS_UNDEFINED = @bitCast(c_int, c.SDL_WINDOWPOS_UNDEFINED_MASK);