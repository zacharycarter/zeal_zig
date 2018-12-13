const std = @import("std");
const sdl = @import("sdl.zig");
const event = @import("event.zig");
const input = @import("input.zig");

const ZealErrors = error {
    SDLInitError,
    SDLWindowCreationError,
};

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
}

fn pollEvent() ?event.Event {
    var sdl_event: sdl.SDL_Event = undefined;

    if (sdl.SDL_PollEvent(@ptrCast([*]sdl.SDL_Event, &sdl_event)) == 0) {
        return null;
    }

    return event.mapSDLEvent(sdl_event);
}

fn shutdown() void {
    if (window) |win| {
        sdl.SDL_DestroyWindow(win);
    }
    sdl.SDL_Quit();
}

pub fn main() void {
    var quit = false;

    init() catch |err| {
        switch (err) {
            ZealErrors.SDLInitError => {
                return;
            },
            else => {
                quit = true;
            }
        }
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
}