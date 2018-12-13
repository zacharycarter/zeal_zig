const std = @import("std");
const bgfx = @import("bgfx.zig");
const sdl = @import("sdl.zig");
const event = @import("event.zig");
const input = @import("input.zig");

const ZealErrors = error {
    SDLInitError,
    SDLWindowCreationError,
    SDLWindowManagerInfoError,
    BGFXInitError,
};

const QUIT_FAILURE = 1;
const QUIT_SUCCESS = 0;
const SDL_WINDOWPOS_UNDEFINED = @bitCast(c_int, sdl.SDL_WINDOWPOS_UNDEFINED_MASK);

var window: ?*sdl.SDL_Window = null;

fn init() !void {
    if (sdl.SDL_Init(sdl.SDL_INIT_VIDEO) != 0) {
        std.debug.warn("unable to initialize sdl: {s}", sdl.SDL_GetError());
        return ZealErrors.SDLInitError;
    }

    var sdl_version = sdl.SDL_version {.major = 0, .minor = 0, .patch = 0};
    sdl.SDL_GetVersion(@ptrCast([*]sdl.SDL_version, &sdl_version));
    sdl.SDL_Log(c"sdl version %d.%d.%d initialized", sdl_version.major, sdl_version.minor, sdl_version.patch);

    window = sdl.SDL_CreateWindow(
        c"zeal",
        SDL_WINDOWPOS_UNDEFINED,
        SDL_WINDOWPOS_UNDEFINED,
        @intCast(c_int, 800),
        @intCast(c_int, 600),
        sdl.SDL_WINDOW_SHOWN,
    ) orelse {
        sdl.SDL_Log(c"unable to create sdl window: %s", sdl.SDL_GetError());
        return ZealErrors.SDLWindowCreationError;
    };

    var pd: bgfx.bgfx_platform_data_t = bgfx.bgfx_platform_data_t {
        .ndt = null,
        .nwh = null,
        .context = null,
        .backBuffer = null,
        .backBufferDS = null,
        .session = null,
    };

    var windowWMInfo: sdl.SDL_SysWMinfo = undefined;

    sdl.SDL_VERSION(&windowWMInfo.version);

    if (sdl.SDL_GetWindowWMInfo(window, @ptrCast([*]sdl.SDL_SysWMinfo, &windowWMInfo)) == sdl.SDL_bool.SDL_FALSE) {
        sdl.SDL_Log(c"unable to retrieve window information from window manager: %s", sdl.SDL_GetError());
        return ZealErrors.SDLWindowManagerInfoError;
    }

    var platform_data: bgfx.bgfx_platform_data_t = undefined;
    if (bgfx.BX_PLATFORM_OSX != 0) {
        platform_data.ndt = null;
        platform_data.nwh = windowWMInfo.info.cocoa.window;
    }

    bgfx.bgfx_set_platform_data(@ptrCast([*]bgfx.bgfx_platform_data_t, &pd));

    if (sdl.SDL_Init(sdl.SDL_INIT_VIDEO) != 0) {
        std.debug.warn("unable to initialize sdl: {s}", sdl.SDL_GetError());
        return ZealErrors.SDLInitError;
    }

    var bgfx_init: bgfx.bgfx_init_t = undefined;
    bgfx.bgfx_init_ctor(@ptrCast([*]bgfx.bgfx_init_t, &bgfx_init));
    
    if (!bgfx.bgfx_init(@ptrCast([*]bgfx.bgfx_init_t, &bgfx_init))) {
        std.debug.warn("unable to initialize bgfx");
        return ZealErrors.BGFXInitError;
    }
}

fn pollEvent() ?event.Event {
    var sdl_event: sdl.SDL_Event = undefined;

    if (sdl.SDL_PollEvent(@ptrCast([*]sdl.SDL_Event, &sdl_event)) == 0) {
        return null;
    }

    return event.mapSDLEvent(sdl_event);
}

fn shutdown() void {
    bgfx.bgfx_shutdown();
    if (window) |win| {
        sdl.SDL_DestroyWindow(win);
    }
    sdl.SDL_Quit();
}

pub fn main() u8 {
    var quit = false;

    init() catch |err| {
        switch (err) {
            ZealErrors.SDLInitError => {
                
            },
            ZealErrors.SDLWindowCreationError => {
                sdl.SDL_Quit();
            },
            ZealErrors.SDLWindowManagerInfoError => {
                if (window) |win| {
                    sdl.SDL_DestroyWindow(win);
                }
                sdl.SDL_Quit();
            },
            else => {
                defer shutdown();
            }
        }
        return QUIT_FAILURE;
    };

    while (!quit) {
        while (pollEvent()) |ev| {
            switch (ev) {
                event.Event.Quit => {
                    quit = true;
                },
                else => {},
            }
        }
    }

    shutdown();
    return QUIT_SUCCESS;
}