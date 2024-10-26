/// Error types for RGB.
pub const rgb_error = error{
    conversion_error,
};

const rgb_256_steps: [6]u8 = [_]u8{ 0, 95, 135, 175, 215, 255 };
const colors_to_manually_check: [7]RGB = [_]RGB{
    standard_rgb_colors.maroon,
    standard_rgb_colors.green,
    standard_rgb_colors.olive,
    standard_rgb_colors.navy,
    standard_rgb_colors.purple,
    standard_rgb_colors.teal,
    standard_rgb_colors.silver,
};

fn indexes_in_256_step(color: *const RGB) [3]i8 {
    var idx: usize = 0;
    var result: [3]i8 = [_]i8{ -1, -1, -1 };
    while (idx < 6) : (idx += 1) {
        if (color.r == rgb_256_steps[idx]) {
            result[0] = @intCast(idx);
        }
        if (color.g == rgb_256_steps[idx]) {
            result[1] = @intCast(idx);
        }
        if (color.b == rgb_256_steps[idx]) {
            result[2] = @intCast(idx);
        }
    }
    return result;
}

/// Standard red, green, and blue structure.
pub const RGB = struct {
    r: u8,
    g: u8,
    b: u8,

    /// Convert the RGB value to its appropriate 256 value.
    /// This method performs a 1-to-1 conversion and if the RGB values
    /// cannot be directly converted this method throws a conversion_error.
    pub fn to_256(self: *const RGB) rgb_error!u8 {
        const rgb_same = self.r == self.g and self.g == self.b;
        const steps = indexes_in_256_step(self);
        const in_256_step: bool = steps[0] != -1 and steps[1] != -1 and steps[2] != -1;
        // this handles some of the standard base colors as well
        if (in_256_step) {
            const red: u8 = @intCast(steps[0]);
            const green: u8 = @intCast(steps[1]);
            const blue: u8 = @intCast(steps[2]);
            return 16 + ((36 * red) + (6 * green) + blue);
        }
        // 192 is for silver base color
        if (rgb_same and self.r != 192) {
            // grey value
            return ((self.r - 8) / 10) + 232;
        }
        // one of the standard base colors
        for (colors_to_manually_check, 1..) |c, idx| {
            if (self.cmp(c)) {
                return @intCast(idx);
            }
        }
        return rgb_error.conversion_error;
    }

    /// Compare another RGB's values for equality.
    pub fn cmp(self: RGB, other: RGB) bool {
        return (self.r == other.r and self.g == other.g and self.b == other.b);
    }
};

/// Structure to hold standard RGB colors.
pub const standard_rgb_colors = struct {
    pub const black: RGB = .{
        .r = 0,
        .g = 0,
        .b = 0,
    };
    pub const white: RGB = .{
        .r = 255,
        .g = 255,
        .b = 255,
    };
    pub const red: RGB = .{
        .r = 255,
        .g = 0,
        .b = 0,
    };
    pub const lime: RGB = .{
        .r = 0,
        .g = 255,
        .b = 0,
    };
    pub const blue: RGB = .{
        .r = 0,
        .g = 0,
        .b = 255,
    };
    pub const yellow: RGB = .{
        .r = 255,
        .g = 255,
        .b = 0,
    };
    pub const cyan: RGB = .{
        .r = 0,
        .g = 255,
        .b = 255,
    };
    pub const magenta: RGB = .{
        .r = 255,
        .g = 0,
        .b = 255,
    };
    pub const silver: RGB = .{
        .r = 192,
        .g = 192,
        .b = 192,
    };
    pub const gray: RGB = .{
        .r = 128,
        .g = 128,
        .b = 128,
    };
    pub const maroon: RGB = .{
        .r = 128,
        .g = 0,
        .b = 0,
    };
    pub const olive: RGB = .{
        .r = 128,
        .g = 128,
        .b = 0,
    };
    pub const green: RGB = .{
        .r = 0,
        .g = 128,
        .b = 0,
    };
    pub const purple: RGB = .{
        .r = 128,
        .g = 0,
        .b = 128,
    };
    pub const teal: RGB = .{
        .r = 0,
        .g = 128,
        .b = 128,
    };
    pub const navy: RGB = .{
        .r = 0,
        .g = 0,
        .b = 128,
    };

    /// Generate RGB value from a given 256 color value.
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
                const index_r = ((n - 16) / 36);
                if (index_r > 0) color.r = 55 + index_r * 40;
                const index_g = @mod((n - 16), 36) / 6;
                if (index_g > 0) color.g = 55 + index_g * 40;
                const index_b: f32 = (@mod((n - 16), 6));
                if (index_b > 0) color.b = 55 + index_b * 40;
                return color;
            },
            232...255 => {
                var color: RGB = .{
                    .r = 0,
                    .g = 0,
                    .b = 0,
                };
                const gray_color: u8 = (n - 232) * 10 + 8;
                color.r = gray_color;
                color.g = gray_color;
                color.b = gray_color;
                return color;
            },
            else => standard_rgb_colors.white,
        };
    }
};
