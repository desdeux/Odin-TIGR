package tigr

foreign import "tigr.lib"
import "core:c"

TPixel :: struct {
	b, g, r, a: c.uchar,
};

Tigr :: struct {
	w, h: c.int,	   // width/height (unscaled)
	pix: ^TPixel,	   // pixel data
	handle: rawptr,	   // OS window handle, NULL for off-screen bitmaps.
};

TigrGlyph :: struct {
    code: c.int,
    x, y, w, h: c.int,
};

TigrFont :: struct {
    bitmap: ^Tigr,
    numGlyphs: c.int,
    glyphs: ^TigrGlyph,
};

TKey :: enum i32 {
	TK_PAD0=128,TK_PAD1,TK_PAD2,TK_PAD3,TK_PAD4,TK_PAD5,TK_PAD6,TK_PAD7,TK_PAD8,TK_PAD9,
	TK_PADMUL,TK_PADADD,TK_PADENTER,TK_PADSUB,TK_PADDOT,TK_PADDIV,
	TK_F1,TK_F2,TK_F3,TK_F4,TK_F5,TK_F6,TK_F7,TK_F8,TK_F9,TK_F10,TK_F11,TK_F12,
	TK_BACKSPACE,TK_TAB,TK_RETURN,TK_SHIFT,TK_CONTROL,TK_ALT,TK_PAUSE,TK_CAPSLOCK,
	TK_ESCAPE,TK_SPACE,TK_PAGEUP,TK_PAGEDN,TK_END,TK_HOME,TK_LEFT,TK_UP,TK_RIGHT,TK_DOWN,
	TK_INSERT,TK_DELETE,TK_LWIN,TK_RWIN,TK_NUMLOCK,TK_SCROLL,TK_LSHIFT,TK_RSHIFT,
	TK_LCONTROL,TK_RCONTROL,TK_LALT,TK_RALT,TK_SEMICOLON,TK_EQUALS,TK_COMMA,TK_MINUS,
	TK_DOT,TK_SLASH,TK_BACKTICK,TK_LSQUARE,TK_BACKSLASH,TK_RSQUARE,TK_TICK
};

TIGR_FIXED :: 0;	// window's bitmap is a fixed size (default)
TIGR_AUTO :: 1;	// window's bitmap will automatically resize after each tigrUpdate
TIGR_2X :: 2;	// always enforce (at least) 2X pixel scale
TIGR_3X :: 4;	// always enforce (at least) 3X pixel scale
TIGR_4X :: 8;	// always enforce (at least) 4X pixel scale
TIGR_RETINA :: 16;

@(default_calling_convention="c")
foreign tigr {

    @(link_name="tigrWindow")
    window :: proc(w, h: c.int, title: cstring, flags: c.int) -> ^Tigr ---;

    @(link_name="tigrBitmap")
    bitmap :: proc(w, h: c.int) -> ^Tigr ---;

    @(link_name="tigrFree")
    free :: proc(bmp: ^Tigr) ---;
    
    @(link_name="tigrClosed")
    closed :: proc(bmp: ^Tigr) -> c.int ---;
    
    @(link_name="tigrUpdate")
    update :: proc(bmp: ^Tigr) ---;
    
    @(link_name="tigrBeginOpenGL")
    begin_opengl :: proc(bmp: ^Tigr) -> c.int ---;
    
    @(link_name="tigrSetPostFX")
    set_post_fx :: proc(bmp: ^Tigr, hblur, vblur: c.int, scanlines, contrast: c.float) ---;
    
    @(link_name="tigrGet")
    get :: proc(bmp: ^Tigr, x, y: c.int) -> TPixel ---;
    
    @(link_name="tigrPlot")
    plot :: proc(bmp: ^Tigr, x, y: c.int, pix: TPixel) ---;
    
    @(link_name="tigrClear")
    clear :: proc(bmp: ^Tigr, color: TPixel) ---;

    @(link_name="tigrFill")
    fill :: proc(bmp: ^Tigr, x, y, w, h: c.int, color: TPixel) ---;

    @(link_name="tigrRect")
    rect :: proc(bmp: ^Tigr, x, y, w, h: c.int, color: TPixel) ---;

    @(link_name="tigrLine")
    line :: proc(bmp: ^Tigr, x0, y0, x1, y1: c.int, color: TPixel) ---;

    @(link_name="tigrBlit")
    blit :: proc(dest: ^Tigr, src: ^Tigr, dx, dy, sx, sy, w, h: c.int) ---;

    @(link_name="tigrBlitAlpha")
    blit_alpha :: proc(dest: ^Tigr, src: ^Tigr, dx, dy, sx, sy, w, h: c.int, alpha: c.float) ---;

    @(link_name="tigrBlitTint")
    blit_tint :: proc(dest: ^Tigr, src: ^Tigr, dx, dy, sx, sy, w, h: c.int, tint: TPixel) ---;

    @(link_name="tigrLoadFont")
    load_font :: proc(bitmap: ^Tigr, codepage: c.int) -> ^TigrFont ---;

    @(link_name="tigrFreeFont")
    free_font :: proc(font: ^TigrFont) ---;

    @(link_name="tigrPrint")
    print :: proc(dest: ^Tigr, font: ^TigrFont, x, y: c.int, color: TPixel, text: cstring, v: ..any) ---;

    @(link_name="tigrTextWidth")
    text_width :: proc(font: ^TigrFont, text: cstring) -> c.int ---;
    
    @(link_name="tigrTextHeight")
    text_height :: proc(font: ^TigrFont, text: cstring) -> c.int ---;
    
    @(link_name="tigrMouse")
    mouse :: proc(bmp: ^Tigr, x, y: ^c.int, buttons: ^c.int) ---;

    @(link_name="tigrKeyDown")
    key_down :: proc(bmp: ^Tigr, key: c.int) -> c.int ---;

    @(link_name="tigrKeyHeld")
    key_held :: proc(bmp: ^Tigr, key: c.int) -> c.int ---;

    @(link_name="tigrReadChar")
    read_char :: proc(bmp: ^Tigr) -> c.int ---;

    @(link_name="tigrLoadImage")
    load_image :: proc(filename: cstring) -> ^Tigr ---;

    @(link_name="tigrLoadImageMem")
    load_image_mem :: proc(data: rawptr, length: c.int) -> ^Tigr ---;

    @(link_name="tigrSaveImage")
    save_image :: proc(filename: cstring, bmp: ^Tigr) -> c.int ---;
    
    @(link_name="tigrTime")
    time :: proc() -> c.float ---;
    
    @(link_name="tigrError")
    error :: proc(bmp: ^Tigr, message: cstring, v: ..any) ---;

    @(link_name="tigrReadFile")
    read_file :: proc(filename: cstring, length: c.int) -> rawptr ---;

    @(link_name="tigrInflate")
    inflate :: proc(out: rawptr, outlen: c.uint, inP: rawptr, inlen: c.uint) -> c.int ---;

    @(link_name="tigrDecodeUTF8")
    decode_utf8 :: proc(text: cstring, cp: ^c.int) -> cstring ---;

    @(link_name="tigrEncodeUTF8")
    encode_utf8 :: proc(text: cstring, cp: c.int) -> cstring ---;

}

rgb :: proc(r, g, b: c.uchar) -> TPixel {
    return TPixel{r = r, g = g, b = b, a = 0xff};
}

rgba :: proc(r, g, b, a: c.uchar) -> TPixel {
    return TPixel{r = r, g = g, b = b, a = a};
}