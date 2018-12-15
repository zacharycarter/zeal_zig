const std = @import("std");
const defines = @import("defines.zig");
const ZealErrors = @import("error.zig").ZealErrors;
const sfml = @cImport({
    // See https://github.com/zig-lang/zig/issues/515
    @cDefine("_NO_CRT_STDIO_INLINE", "1");
    @cInclude("SFML/Network.h");
});

var listener: ?*sfml.sfTcpListener = undefined;

pub fn init() u8 {
    listener = sfml.sfTcpListener_create();
    if (listener == null) {
        return defines.QUIT_FAILURE;
    }

    var socket_status = sfml.sfTcpListener_listen(listener, 8080, sfml.sfIpAddress_Any);
    
    return defines.QUIT_SUCCESS;
}