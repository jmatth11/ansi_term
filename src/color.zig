const std = @import("std");
const codes = @import("escape_codes.zig");
const commands = @import("commands.zig");

/// Enum type of symbol 8bit colors
pub const color_type = enum {
    black,
    red,
    green,
    yellow,
    blue,
    magenta,
    cyan,
    white,
    default,

    pub fn color_8bit(self: color_type) []u8 {
        return switch (self) {
            color_type.black => codes.base_black,
            color_type.red => codes.base_red,
            color_type.green => codes.base_green,
            color_type.yellow => codes.base_yellow,
            color_type.blue => codes.base_blue,
            color_type.magenta => codes.base_magenta,
            color_type.cyan => codes.base_cyan,
            color_type.white => codes.base_white,
            else => codes.base_default,
        };
    }
};

fn write_len_of_int(n: u8) usize {
    if (n < 10) {
        return 1;
    } else if (n < 100) {
        return 2;
    }
    return 3;
}

/// Write out an 8bit color with the given parameters.
///
/// @param w The writer to write out to.
/// @param color The color type enum.
/// @param fg Flag for foreground color or background.
/// @param bright Flag for bright colors or regular colors.
/// @return The number of bytes written.
pub fn color_8bit(w: std.io.AnyWriter, color: color_type, fg: bool, bright: bool) !usize {
    var write_len = try w.write(commands.csi);
    if (bright) {
        if (fg) {
            try w.writeByte(codes.base_bright_foreground_prefix);
            write_len += 1;
        } else {
            write_len += try w.write(codes.base_bright_background_prefix);
        }
    } else {
        if (fg) {
            try w.writeByte(codes.base_foreground_prefix);
        } else {
            try w.writeByte(codes.base_background_prefix);
        }
        write_len += 1;
    }
    try w.writeByte(color.color_8bit());
    try w.writeByte(codes.csi_end);
    write_len += 2;
    return write_len;
}

/// Write out a 256 color with the given parameters.
///
/// @param w The writer to write out to.
/// @param val The 256 color value.
/// @param fg The flag for foreground or background coloring.
/// @return The number of bytes written.
pub fn color_256(w: std.io.AnyWriter, val: u8, fg: bool) !usize {
    var write_len = try w.write(w.ctx, commands.csi);
    if (fg) {
        write_len += try w.write(w.ctx, codes.foreground_ext);
    } else {
        write_len += try w.write(w.ctx, codes.background_ext);
    }
    try w.writeByte(w.ctx, codes.param_sep);
    try w.writeByte(w.ctx, codes.flag_256);
    try w.writeByte(w.ctx, codes.param_sep);
    write_len += 3;
    try w.writeInt(u8, val, std.builtin.Endian.little);
    write_len += write_len_of_int(val);
    try w.writeByte(w.ctx, codes.csi_end);
    write_len += 1;
    return write_len;
}

/// Write out a true RGB color with the given parameters.
///
/// @param w The writer to write out to.
/// @param r The red value.
/// @param g The green value.
/// @param b The blue value.
/// @param fg The flag for foreground or background coloring.
/// @return The number of bytes written.
pub fn color_true(w: std.io.AnyWriter, r: u8, g: u8, b: u8, fg: bool) !usize {
    var write_len = try w.write(w.ctx, commands.csi);
    if (fg) {
        write_len += try w.write(w.ctx, codes.foreground_ext);
    } else {
        write_len += try w.write(w.ctx, codes.background_ext);
    }
    try w.writeByte(w.ctx, codes.param_sep);
    try w.writeByte(w.ctx, codes.true_color_flag);
    try w.writeByte(w.ctx, codes.param_sep);
    write_len += 3;
    try w.writeInt(u8, r, std.builtin.Endian.little);
    write_len += write_len_of_int(r);
    try w.writeByte(w.ctx, codes.param_sep);
    write_len += 1;
    try w.writeInt(u8, g, std.builtin.Endian.little);
    write_len += write_len_of_int(g);
    try w.writeByte(w.ctx, codes.param_sep);
    write_len += 1;
    try w.writeInt(u8, b, std.builtin.Endian.little);
    write_len += write_len_of_int(b);
    try w.writeByte(w.ctx, codes.csi_end);
    write_len += 1;
    return write_len;
}
