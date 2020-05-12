// A small test program to exercise most of TIGR's features.
package demo

import "tigr"
import "core:math"
import "core:fmt"
import "core:strings"

playerx, playery := f32(160), f32(200);
playerxs, playerys := f32(0), f32(0);
standing := true;
remaining := f32(0);
backdrop, screen : ^tigr.Tigr;

update :: proc(dt: f32) {
    if remaining > 0 {
        remaining -= dt;
    }
    // Read the keyboard and move the player.
    if standing && tigr.key_down(screen, i32(tigr.TKey.TK_SPACE)) != 0 do playerys -= 200;
    if tigr.key_held(screen, i32(tigr.TKey.TK_LEFT)) == 1 || tigr.key_held(screen, i32('A')) == 1 do playerxs -= 10;
    if tigr.key_held(screen, i32(tigr.TKey.TK_RIGHT)) == 1 || tigr.key_held(screen, i32('D')) == 1 do playerxs += 10;

    oldx, oldy := playerx, playery;

    // Apply simply physics.
    playerxs *= math.exp(-10.0 * dt);
    playerys *= math.exp(-2.0 * dt);
    playerys += dt * 200.0;
    playerx += dt * playerxs;
    playery += dt * playerys;

    // Apply collision.
    if playerx < 8 {
        playerx = 8;
        playerxs = 0;
    }

    if i32(playerx) > screen.w - 8.0 {
        playerx = f32(screen.w - 8.0);
        playerxs = 0;
    }

    // Apply playfield collision and stepping.
    dx := (playerx - oldx) / 10.0;
    dy := (playery - oldy) / 10.0;
    standing = false;

    for n in 0..<10 {
        p := tigr.get(backdrop, i32(oldx), i32(oldy) - 1);
        if p.r == 0 && p.g == 0 && p.b == 0 do oldy -= 1;
        if p.r == 0 && p.g == 0 && p.b == 0 && playerys > 0 {
            playerys = 0;
            dy = 0;
            standing = true;
        }
        oldx += dx;
        oldy += dy;
    }

    playerx, playery = oldx, oldy;
}

main :: proc() {
    // Load font.
    font_file := tigr.load_image("imgs/font.png");
    defer tigr.free(font_file);
    tFont := tigr.load_font(font_file, 1252);

    // Load our sprite.
    squinkle := tigr.load_image("imgs/squinkle.png");
    if squinkle == nil do tigr.error(nil, "Cannot load squinkle.png");
    defer tigr.free(squinkle);

    // Load some UTF-8 text.
    greeting := tigr.read_file("greeting.txt", 0);
    if greeting == nil do tigr.error(nil, "Cannot load greeting.txt");

    // Make a window and an off-screen backdrop.
    screen = tigr.window(320, 240, cstring(greeting), tigr.TIGR_2X);
    defer tigr.free(screen);
    backdrop = tigr.bitmap(screen.w, screen.h);
    defer tigr.free(backdrop);

    // Fill in the background.
    tigr.clear(backdrop, tigr.rgb(80, 180, 255));
	tigr.fill(backdrop, 0, 200, 320, 40, tigr.rgb(60, 120, 60));
	tigr.fill(backdrop, 0, 200, 320, 3,  tigr.rgb(0, 0, 0));
	tigr.fill(backdrop, 0, 201, 320, 201, tigr.rgb(255,255,255));

    // Enable post fx
    tigr.set_post_fx(screen, 1, 1, 1, 2.0);

    prevx, prevy, prev := i32(0), i32(0), i32(0);
    chars: [4]rune;
    for n in 0..<4 do chars[n] = '_';

    // Repeat till they close the window.
    for tigr.closed(screen) != 1 && tigr.key_down(screen, i32(tigr.TKey.TK_ESCAPE)) != 1 {

        // Update the game.
        dt := tigr.time();
        update(dt);

        // Read the mouse and draw lines when pressed.
        x, y, b: i32;
        tigr.mouse(screen, &x, &y, &b);
        if b&1 == 1 {
            if prev == 1 do tigr.line(backdrop, prevx, prevy, x ,y, tigr.rgb(0, 0, 0));
            prevx, prevy, prev = x, y, 1;
        } else {
            prev = 0;
        }
        // Composite the backdrop and sprite onto the screen.
        tigr.blit(screen, backdrop, 0, 0, 0, 0, backdrop.w, backdrop.h);
        tigr.blit_alpha(screen, squinkle, i32(playerx - f32(squinkle.w/2)), i32(playery-f32(squinkle.h)), 0, 0, squinkle.w, squinkle.h, 1.0);

        tigr.print(screen, tFont, 10, 10, tigr.rgba(0xc0,0xd0,0xff,0xc0), cstring(greeting));
		tigr.print(screen, tFont, 10, 222, tigr.rgba(0xff,0xff,0xff,0xff), "A D + SPACE");   
        for {
            c := tigr.read_char(screen);
            if c == 0 do break;
            for n in 1..<4 do chars[n-1] = chars[n];
            chars[3] = rune(c);
        }

        // Print out the character buffer.
        fmtChars := strings.clone_to_cstring(fmt.aprint("Chars: %s", chars));
		tigr.print(screen, tFont, 160, 222, tigr.rgb(255,255,255), fmtChars);
        delete(fmtChars);
        // Update the window.
        tigr.update(screen);
    }
}