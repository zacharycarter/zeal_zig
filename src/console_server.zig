const std = @import("std");
const c = @cImport({
    // See https://github.com/zig-lang/zig/issues/515
    @cDefine("_NO_CRT_STDIO_INLINE", "1");
    @cInclude("SDL2/SDL.h");
    @cInclude("SDL2/SDL_net.h");
});


pub fn init() !void {
    var ip_addr: u32;

    if 
}