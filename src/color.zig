const std = @import("std");
const codes = @import("escape_codes.zig");
const commands = @import("commands.zig");

pub const RGB = struct {
    r: u8,
    g: u8,
    b: u8,
};

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

pub const standard_rgb_colors = struct {
    const black: RGB = .{
        .r = 0,
        .g = 0,
        .b = 0,
    };
    const white: RGB = .{
        .r = 255,
        .g = 255,
        .b = 255,
    };
    const red: RGB = .{
        .r = 255,
        .g = 0,
        .b = 0,
    };
    const lime: RGB = .{
        .r = 0,
        .g = 255,
        .b = 0,
    };
    const blue: RGB = .{
        .r = 0,
        .g = 0,
        .b = 255,
    };
    const yellow: RGB = .{
        .r = 255,
        .g = 255,
        .b = 0,
    };
    const cyan: RGB = .{
        .r = 0,
        .g = 255,
        .b = 255,
    };
    const magenta: RGB = .{
        .r = 255,
        .g = 0,
        .b = 255,
    };
    const silver: RGB = .{
        .r = 192,
        .g = 192,
        .b = 192,
    };
    const gray: RGB = .{
        .r = 128,
        .g = 128,
        .b = 128,
    };
    const maroon: RGB = .{
        .r = 128,
        .g = 0,
        .b = 0,
    };
    const olive: RGB = .{
        .r = 128,
        .g = 128,
        .b = 0,
    };
    const green: RGB = .{
        .r = 0,
        .g = 128,
        .b = 0,
    };
    const purple: RGB = .{
        .r = 128,
        .g = 0,
        .b = 128,
    };
    const teal: RGB = .{
        .r = 0,
        .g = 128,
        .b = 128,
    };
    const navy: RGB = .{
        .r = 0,
        .g = 0,
        .b = 128,
    };

    pub fn from_256(n: u8) RGB {
        return switch (n) {
            0 => standard_rgb_colors.black,
            1 => standard_rgb_colors.maroon,
            2 => standard_rgb_colors.green,
            3 => standard_rgb_colors.olive,
            4 => standard_rgb_colors.navy,
            5 => standard_rgb_colors.purple,
            6 => standard_rgb_colors.teal,
            7 => standard_rgb_colors.silver,
            8 => standard_rgb_colors.gray,
            9 => standard_rgb_colors.red,
            10 => standard_rgb_colors.lime,
            11 => standard_rgb_colors.yellow,
            12 => standard_rgb_colors.blue,
            13 => standard_rgb_colors.magenta,
            14 => standard_rgb_colors.cyan,
            15 => standard_rgb_colors.white,
            16...231 => {
                var color: RGB = .{
                    .r = 0,
                    .g = 0,
                    .b = 0,
                };
                const float_n: f32 = @floatFromInt(n);
                const index_r: f32 = ((float_n - 16.0) / 36.0);
                if (index_r > 0) color.r = @intFromFloat(55.0 + index_r * 40.0);
                const index_g: f32 = (@mod((float_n - 16.0), 36.0) / 6.0);
                if (index_g > 0) color.g = @intFromFloat(55.0 + index_g * 40.0);
                const index_b: f32 = (@mod((float_n - 16.0), 6.0));
                if (index_b > 0) color.b = @intFromFloat(55.0 + index_b * 40.0);
                return color;
            },

            else => standard_rgb_colors.white,
        };
    }
};
