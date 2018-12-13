const sdl = @import("sdl.zig");
const input = @import("input.zig");

pub const Event = union(enum) {
    KeyDown: input.Key,
    KeyUp: input.Key,
    Quit,
};

fn getKey(sym: sdl.SDL_Keycode) ?input.Key {
    return switch (sym) {
        sdl.SDLK_ESCAPE => input.Key.Escape,
        sdl.SDLK_BACKSPACE => input.Key.Backspace,
        sdl.SDLK_RETURN => input.Key.Return,
        sdl.SDLK_F2 => input.Key.F2,
        sdl.SDLK_F3 => input.Key.F3,
        sdl.SDLK_F4 => input.Key.F4,
        sdl.SDLK_F5 => input.Key.F5,
        sdl.SDLK_UP => input.Key.Up,
        sdl.SDLK_DOWN => input.Key.Down,
        sdl.SDLK_LEFT => input.Key.Left,
        sdl.SDLK_RIGHT => input.Key.Right,
        sdl.SDLK_SPACE => input.Key.Space,
        sdl.SDLK_BACKQUOTE => input.Key.Backquote,
        sdl.SDLK_m => input.Key.M,
        sdl.SDLK_n => input.Key.N,
        sdl.SDLK_y => input.Key.Y,
        else => null,
    };
}

pub fn mapSDLEvent(sdl_event: sdl.SDL_Event) ?Event {
    switch (sdl_event.type) {
        sdl.SDL_KEYDOWN => {
            if (sdl_event.key.repeat == 0) {
                if (getKey(sdl_event.key.keysym.sym)) |key| {
                return Event{ .KeyDown = key};
                }
            }
        },
        sdl.SDL_KEYUP => {
            if (getKey(sdl_event.key.keysym.sym)) |key| {
                return Event{ .KeyUp = key };
            }
        },
        sdl.SDL_QUIT => {
            return Event{ .Quit = {} };
        },
        else => {},
    }

    return null;
}