const sfml = @cImport({
    // See https://github.com/zig-lang/zig/issues/515
    @cDefine("_NO_CRT_STDIO_INLINE", "1");
    @cInclude("SFML/Window.h");
});

const std = @import("std");
const bgfx = @import("bgfx.zig");
const input = @import("input.zig");
const console_server = @import("console_server.zig");

const ZealErrors = error {
    SFMLWindowCreationError,
    BGFXInitError,
    ConsoleServerInitError,
};

const QUIT_FAILURE = 1;
const QUIT_SUCCESS = 0;

const DeviceOptions = struct {
    foo: u8,
    bar: []const u8,
};

const MainThreadArgs = struct {
    device_options: *DeviceOptions,
};

var window: ?*sfml.sfWindow = undefined;

fn start1(ctx: void) u8 {
    return 0;
}

fn init() !void {
    // const main_thread_args = MainThreadArgs{ .device_options = &DeviceOptions{ .foo = 1, .bar = "bar" } };
    // const main_thread = try std.os.spawnThread({}, start1);
    // main_thread.wait();

    window = sfml.sfWindow_create(sfml.sfVideoMode{ .width = 800, .height = 600, .bitsPerPixel = 32 }, c"zeal", sfml.sfDefaultStyle, null);
    if (window == null) {
        std.debug.warn("unable to create sfml window");
        return ZealErrors.SFMLWindowCreationError;
    }

    // console_server.init() catch |err| {
    //     std.debug.warn("unable to initialize sdl: {s}", err);
    //     return ZealErrors.ConsoleServerInitError;
    // };

    const system_window_handle = sfml.sfWindow_getSystemHandle(window);

    var platform_data: bgfx.bgfx_platform_data_t = undefined;
    if (bgfx.BX_PLATFORM_OSX != 0) {
        platform_data.ndt = null;
        platform_data.nwh = system_window_handle;
    }

    bgfx.bgfx_set_platform_data(@ptrCast([*]bgfx.bgfx_platform_data_t, &platform_data));

    var bgfx_init: bgfx.bgfx_init_t = undefined;
    bgfx.bgfx_init_ctor(@ptrCast([*]bgfx.bgfx_init_t, &bgfx_init));
    
    if (!bgfx.bgfx_init(@ptrCast([*]bgfx.bgfx_init_t, &bgfx_init))) {
        std.debug.warn("unable to initialize bgfx");
        return ZealErrors.BGFXInitError;
    }
}

fn pollEvent() void {
    var ev: sfml.sfEvent = undefined;
    while (sfml.sfWindow_pollEvent(window, @ptrCast([*]sfml.sfEvent, &ev)) > 0) {
        if (@enumToInt(ev.type) == sfml.sfEvtClosed) {
            sfml.sfWindow_close(window);
        }
    }
}

fn shutdown() void {
    bgfx.bgfx_shutdown();
    if (window) |win| {
        sfml.sfWindow_destroy(window);
    }
}

pub fn main() u8 {
    var quit = false;

    init() catch |err| {
        switch (err) {
            ZealErrors.SFMLWindowCreationError => {
                
            },
            ZealErrors.BGFXInitError => {
                if (window) |win| {
                    sfml.sfWindow_destroy(window);
                }
            },
            else => {
                shutdown();
            }
        }
        return QUIT_FAILURE;
    };

    while (sfml.sfWindow_isOpen(window) > 0) {
        pollEvent();
    }

    shutdown();
    return QUIT_SUCCESS;
}