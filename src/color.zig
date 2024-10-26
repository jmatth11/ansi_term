const std = @import("std");
const codes = @import("escape_codes.zig");
const commands = @import("commands.zig");
const rgb = @import("rgb.zig");

pub const color_result = std.meta.Tuple(.{ Color, usize });

const parse_param_limit: u8 = 5;

/// The color mode options.
pub const color_mode = enum {
    /// ISO colors
    bit4,
    /// 256 colors
    bit8,
    /// RGB true colors
    bit24,
};

/// Structure to handle modifier codes. (bold, italic, etc...)
pub const Modifier = struct {
    /// The modifier option
    mod: modifier_options = modifier_options.reset,
    /// Reset flag
    reset: bool = false,

    /// Get the modifier code.
    /// Handles normal and reset codes.
    pub fn code(self: *const Modifier) []const u8 {
        var base_code = self.mod.code();
        if (self.reset) {
            // 22 is reset code for code 1 and 2
            if (base_code == codes.bold) base_code = codes.dim;
            // reset all command is just zero by itself
            if (base_code != codes.reset_all) {
                return &[2]u8{ codes.reset_sequence_prefix, base_code };
            }
        }
        return &[1]u8{base_code};
    }

    /// Write out the modifier to the given writer.
    pub fn write(self: Modifier, w: std.io.AnyWriter) !usize {
        return try write_modifier(w, self);
    }
};

/// Base Color structure.
/// This structure should not be used directly.
/// Its main use is inside the Color structure.
pub const BaseColor = struct {
    /// Flag for bright colors
    bright: bool = false,
    /// Optional modifier object
    modifier: ?Modifier = null,
    /// The color option
    color: color_options = color_options.black,
};

/// Tagged enum for color type.
/// Switches between ISO 8 bit and the RGB variants.
pub const ColorType = union(enum) {
    /// ISO 8 bit color
    base_color: BaseColor,
    /// 256 or True RGB color
    rgb: rgb.RGB,
};

/// Structure to hold color data.
pub const Color = struct {
    mode: color_mode = .bit8,
    fg: bool = true,
    color: ColorType = .{ .rgb = rgb.standard_rgb_colors.black },

    pub fn write(self: *const Color, w: std.io.AnyWriter) !usize {
        return switch (self.mode) {
            .bit4 => {
                return try write_color_4bit(
                    w,
                    self.color.base_color.color,
                    self.fg,
                    self.color.base_color.bright,
                    self.color.base_color.modifier,
                );
            },
            .bit8 => {
                const val = try self.color.rgb.to_256();
                return try write_color_8bit(w, val, self.fg);
            },
            .bit24 => {
                const local_rgb = self.color.rgb;
                return try write_color_24bit(w, local_rgb.r, local_rgb.g, local_rgb.b, self.fg);
            },
        };
    }
};

pub const modifier_options = enum(u8) {
    reset = 0,
    bold,
    dim,
    italic,
    underline,
    blinking,
    // 6 is skipped
    reverse = 7,
    invisible,
    strikethrough,

    pub fn code(self: modifier_options) u8 {
        return switch (self) {
            modifier_options.reset => codes.reset_all,
            modifier_options.bold => codes.bold,
            modifier_options.dim => codes.dim,
            modifier_options.italic => codes.italic,
            modifier_options.underline => codes.underline,
            modifier_options.blinking => codes.blinking,
            modifier_options.reverse => codes.reverse,
            modifier_options.invisible => codes.invisible,
            modifier_options.strikethrough => codes.strikethrough,
        };
    }

    pub fn from_code(val: u8) ?modifier_options {
        return switch (val) {
            0...5 => @enumFromInt(val),
            7...9 => @enumFromInt(val),
            22 => modifier_options.bold,
            23 => modifier_options.italic,
            24 => modifier_options.underline,
            25 => modifier_options.blinking,
            27 => modifier_options.reverse,
            28 => modifier_options.invisible,
            29 => modifier_options.strikethrough,
            else => null,
        };
    }
};

/// Enum type of symbol 8bit colors
pub const color_options = enum(u8) {
    black = 0,
    red,
    green,
    yellow,
    blue,
    magenta,
    cyan,
    white,
    // skipped 8
    default = 9,

    pub fn code(self: color_options) u8 {
        return switch (self) {
            color_options.black => codes.base_black,
            color_options.red => codes.base_red,
            color_options.green => codes.base_green,
            color_options.yellow => codes.base_yellow,
            color_options.blue => codes.base_blue,
            color_options.magenta => codes.base_magenta,
            color_options.cyan => codes.base_cyan,
            color_options.white => codes.base_white,
            else => codes.base_default,
        };
    }
    pub fn from_code(val: u8) ?color_options {
        const base_value = switch (val) {
            30...39 => val - 30,
            40...49 => val - 40,
            90...99 => val - 90,
            100...109 => val - 100,
            // else return value
            else => val,
        };
        return switch (base_value) {
            0 => color_options.black,
            1 => color_options.red,
            2 => color_options.green,
            3 => color_options.yellow,
            4 => color_options.blue,
            5 => color_options.magenta,
            6 => color_options.cyan,
            7 => color_options.white,
            9 => color_options.default,
            else => null,
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

/// Write out a modifier code. (bold, italic, etc...)
///
/// @param w The writer to write out to.
/// @param modifier The modifier object to write.
/// @return The number of bytes written.
pub fn write_modifier(w: std.io.AnyWriter, modifier: Modifier) !usize {
    var write_len = try w.write(&commands.csi);
    write_len += try w.write(modifier.code());
    try w.writeByte(codes.csi_end);
    write_len += 1;
    return write_len;
}

/// Write out an 4bit color with the given parameters.
///
/// @param w The writer to write out to.
/// @param color The color type enum.
/// @param fg Flag for foreground color or background.
/// @param bright Flag for bright colors or regular colors.
/// @param modifier The modifier object to apply to the color. (bold, italic, etc..)
/// @return The number of bytes written.
pub fn write_color_4bit(w: std.io.AnyWriter, color: color_options, fg: bool, bright: bool, modifier: ?Modifier) !usize {
    var write_len = try w.write(&commands.csi);
    if (modifier) |mod| {
        write_len += try w.write(mod.code());
        try w.writeByte(codes.param_sep);
        write_len += 1;
    }
    if (bright) {
        if (fg) {
            try w.writeByte(codes.base_bright_foreground_prefix);
            write_len += 1;
        } else {
            write_len += try w.write(&codes.base_bright_background_prefix);
        }
    } else {
        if (fg) {
            try w.writeByte(codes.base_foreground_prefix);
        } else {
            try w.writeByte(codes.base_background_prefix);
        }
        write_len += 1;
    }
    try w.writeByte(color.code());
    try w.writeByte(codes.csi_end);
    write_len += 2;
    return write_len;
}

/// Write out a 256(8bit) color with the given parameters.
///
/// @param w The writer to write out to.
/// @param val The 256 color value.
/// @param fg The flag for foreground or background coloring.
/// @return The number of bytes written.
pub fn write_color_8bit(w: std.io.AnyWriter, val: u8, fg: bool) !usize {
    var write_len = try w.write(&commands.csi);
    if (fg) {
        write_len += try w.write(&codes.foreground_ext);
    } else {
        write_len += try w.write(&codes.background_ext);
    }
    try w.writeByte(codes.param_sep);
    try w.writeByte(codes.flag_256);
    try w.writeByte(codes.param_sep);
    write_len += 3;
    try std.fmt.format(w, "{d}", .{val});
    write_len += write_len_of_int(val);
    try w.writeByte(codes.csi_end);
    write_len += 1;
    return write_len;
}

/// Write out a true RGB(24bit) color with the given parameters.
///
/// @param w The writer to write out to.
/// @param r The red value.
/// @param g The green value.
/// @param b The blue value.
/// @param fg The flag for foreground or background coloring.
/// @return The number of bytes written.
pub fn write_color_24bit(w: std.io.AnyWriter, r: u8, g: u8, b: u8, fg: bool) !usize {
    var write_len = try w.write(&commands.csi);
    if (fg) {
        write_len += try w.write(&codes.foreground_ext);
    } else {
        write_len += try w.write(&codes.background_ext);
    }
    try w.writeByte(codes.param_sep);
    try w.writeByte(codes.true_color_flag);
    try w.writeByte(codes.param_sep);
    write_len += 3;
    try std.fmt.format(w, "{d}", .{r});
    write_len += write_len_of_int(r);
    try w.writeByte(codes.param_sep);
    write_len += 1;
    try std.fmt.format(w, "{d}", .{g});
    write_len += write_len_of_int(g);
    try w.writeByte(codes.param_sep);
    write_len += 1;
    try std.fmt.format(w, "{d}", .{b});
    write_len += write_len_of_int(b);
    try w.writeByte(codes.csi_end);
    write_len += 1;
    return write_len;
}

fn check_for_modifier(val: u8, result: *Color) bool {
    const modifier = modifier_options.from_code(val);
    if (modifier == null) return false;
    result.color.base_color.modifier = .{
        .mod = modifier,
    };
    switch (val) {
        22...29 => result.color.base_color.modifier.?.reset = true,
    }
    return true;
}

fn check_for_base_color(val: u8, result: *Color) bool {
    const base_color = color_options.from_code(val);
    if (base_color == null) return false;
    result.color.base_color.color = base_color;
    switch (val) {
        30...39 => result.fg = true,
        40...49 => result.fg = false,
        90...99 => {
            result.color.base_color.bright = true;
            result.fg = true;
        },
        100...109 => {
            result.color.base_color.bright = true;
            result.fg = false;
        },
    }
    return true;
}

fn assign_ansi_values(groupings: [parse_param_limit]u8, groupings_len: u8) codes.ansi_errors!Color {
    var result: Color = .{};
    switch (groupings_len) {
        1 => {
            result.mode = .bit4;
            const num = groupings[0];
            switch (num) {
                0...29 => {
                    if (!check_for_modifier(num, &result)) {
                        return codes.ansi_errors.invalid_format;
                    }
                },
                30...49 => {
                    if (!check_for_base_color(num, &result)) {
                        return codes.ansi_errors.invalid_format;
                    }
                },
                90...109 => {
                    if (!check_for_base_color(num, &result)) {
                        return codes.ansi_errors.invalid_format;
                    }
                },
            }
        },
        2 => {
            result.mode = .bit4;
            const modifier = groupings[0];
            const color = groupings[1];
            switch (modifier) {
                0...29 => {
                    if (!check_for_modifier(modifier, &result)) {
                        return codes.ansi_errors.invalid_format;
                    }
                },
            }
            switch (color) {
                30...49 => {
                    if (!check_for_base_color(color, &result)) {
                        return codes.ansi_errors.invalid_format;
                    }
                },
                90...109 => {
                    if (!check_for_base_color(color, &result)) {
                        return codes.ansi_errors.invalid_format;
                    }
                },
            }
        },
        3 => {
            const param_one = groupings[0];
            const flag = groupings[1];
            const color = groupings[2];
            if (param_one != codes.base_foreground_prefix and param_one != codes.base_background_prefix) {
                return codes.ansi_errors.invalid_format;
            }
            result.fg = (param_one == codes.base_foreground_prefix);
            if (flag != codes.flag_256) {
                return codes.ansi_errors.invalid_format;
            }
            result.mode = .bit8;
            result.rgb.rgb = rgb.standard_rgb_colors.from_256(color);
        },
        5 => {
            const param_one = groupings[0];
            const flag = groupings[1];
            const color_r = groupings[2];
            const color_g = groupings[3];
            const color_b = groupings[4];
            if (param_one != codes.base_foreground_prefix and param_one != codes.base_background_prefix) {
                return codes.ansi_errors.invalid_format;
            }
            result.fg = (param_one == codes.base_foreground_prefix);
            if (flag != codes.true_color_flag) {
                return codes.ansi_errors.invalid_format;
            }
            result.mode = .bit24;
            result.color.rgb.r = color_r;
            result.color.rgb.g = color_g;
            result.color.rgb.b = color_b;
        },
        else => return codes.ansi_error.unsupported_format,
    }
    return result;
}

/// Parse out a color_result from the given string.
///
/// @param str The string to parse.
/// @return A color result tuple of <Color, usize> where usize is the number of bytes read.
pub fn parse_color(str: []const u8) codes.ansi_error!color_result {
    if (str.len < 4) return codes.ansi_error.invalid_format;
    if (str[0] != codes.escape_code or str[1] != codes.control_sequence_introducer) return codes.ansi_error.invalid_format;
    var process = true;
    var str_starting_idx: u8 = 2;
    var parsed_number: u8 = 0;
    var groupings: [parse_param_limit]u8 = undefined;
    while (process) {
        var buf: [4]u8 = undefined;
        var idx: u8 = 0;
        while (idx < buf.len) : (idx += 1) {
            const cur_idx = str_starting_idx + idx;
            if (cur_idx >= str.len) return codes.ansi_error.invalid_format;
            const cur_char = str[cur_idx];
            if (cur_char == 'm') {
                process = false;
                break;
            }
            if (cur_char == ';') break;
            buf[idx] = cur_char;
        }
        str_starting_idx += idx + 1;
        parsed_number += 1;
        if (parsed_number >= parse_param_limit) return codes.ansi_error.invalid_format;
        const num: u8 = std.fmt.parseInt(u8, buf[0..idx], 10) catch return codes.ansi_error.error_parsing;
        groupings[(parsed_number - 1)] = num;
    }
    const result = try assign_ansi_values(groupings, parsed_number);
    return .{ result, str_starting_idx };
}
