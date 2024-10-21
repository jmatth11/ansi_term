const std = @import("std");
const testing = std.testing;

const codes = @import("escape_codes.zig");
const color = @import("color.zig");

fn gen_escape_code(buf: []u8, text: []const u8) void {
    buf[0] = codes.escape_code;
    var text_idx: usize = 0;
    while (text_idx < text.len) : (text_idx += 1) {
        buf[text_idx + 1] = text[text_idx];
    }
}

test "default Modifier code test" {
    const mod: color.Modifier = .{};
    try testing.expect(mod.mod == color.modifier_options.reset);
    try testing.expect(mod.reset == false);
    const expected: []const u8 = &[_]u8{'0'};
    const result = mod.code();
    try testing.expectEqualSlices(u8, expected, result);
}

test "Modifier code test normal" {
    var mod: color.Modifier = .{};
    mod.mod = color.modifier_options.bold;
    var expected: []const u8 = &[_]u8{codes.bold};
    var result = mod.code();
    try testing.expectEqualSlices(u8, expected, result);
    mod.mod = color.modifier_options.blinking;
    expected = &[_]u8{codes.blinking};
    result = mod.code();
    try testing.expectEqualSlices(u8, expected, result);
}

test "Modifier code test reset" {
    var mod: color.Modifier = .{
        .reset = true,
    };

    // bold use case uses correct reset code
    mod.mod = color.modifier_options.bold;
    var expected: []const u8 = &[_]u8{ codes.reset_sequence_prefix, codes.dim };
    var result = mod.code();
    try testing.expectEqualSlices(u8, expected, result);

    // dim works as expected
    mod.mod = color.modifier_options.dim;
    expected = &[_]u8{ codes.reset_sequence_prefix, codes.dim };
    result = mod.code();
    try testing.expectEqualSlices(u8, expected, result);

    // normal use case
    mod.mod = color.modifier_options.blinking;
    expected = &[_]u8{ codes.reset_sequence_prefix, codes.blinking };
    result = mod.code();
    try testing.expectEqualSlices(u8, expected, result);

    // reset use case
    mod.mod = color.modifier_options.reset;
    expected = &[_]u8{codes.reset_all};
    result = mod.code();
    try testing.expectEqualSlices(u8, expected, result);
}

test "Modifier write reset code" {
    const mod: color.Modifier = .{};
    var writer = std.ArrayList(u8).init(testing.allocator);
    defer writer.deinit();
    var expected: [4]u8 = undefined;
    gen_escape_code(&expected, "[0m");
    const result_n = try mod.write(writer.writer().any());
    try testing.expect(result_n == 4);
    try testing.expectEqualSlices(u8, &expected, writer.items);
}

test "Modifier write bold code" {
    const mod: color.Modifier = .{
        .mod = color.modifier_options.bold,
    };
    var writer = std.ArrayList(u8).init(testing.allocator);
    defer writer.deinit();
    var expected: [4]u8 = undefined;
    gen_escape_code(&expected, "[1m");
    const result_n = try mod.write(writer.writer().any());
    try testing.expect(result_n == 4);
    try testing.expectEqualSlices(u8, &expected, writer.items);
}

test "Modifier write reset reverse code" {
    const mod: color.Modifier = .{
        .mod = color.modifier_options.reverse,
        .reset = true,
    };
    var writer = std.ArrayList(u8).init(testing.allocator);
    defer writer.deinit();
    var expected: [5]u8 = undefined;
    gen_escape_code(&expected, "[27m");
    const result_n = try mod.write(writer.writer().any());
    try testing.expect(result_n == 5);
    try testing.expectEqualSlices(u8, &expected, writer.items);
}

//test "ansi escape code" {
//    const test_str = ;
//    try testing.expect(test_str == ansi.escape_code);
//}
//
//test "parse ansi code 256 value - foreground color" {
//    const test_str: [*:0]const u8 = "[38;5;56m";
//    var text_buff = [_]u8{0} ** 10;
//    gen_escape_code(&text_buff, test_str, 9);
//    const result = try ansi.parse_color(&text_buff);
//    try testing.expect(result.bytes_read == 10);
//    try testing.expect(result.color.foreground == true);
//    try testing.expect(result.color.r == 99);
//    try testing.expect(result.color.g == 81);
//    try testing.expect(result.color.b == 215);
//    try testing.expect(result.reset == false);
//    try testing.expect(result.color.use_color == true);
//}
//
//test "parse ansi code 256 value - foreground standard color" {
//    const test_str: [*:0]const u8 = "[38;5;10m";
//    var text_buff = [_]u8{0} ** 10;
//    gen_escape_code(&text_buff, test_str, 9);
//    const result = try ansi.parse_color(&text_buff);
//    try testing.expect(result.bytes_read == 10);
//    try testing.expect(result.color.foreground == true);
//    try testing.expect(result.color.r == 0);
//    try testing.expect(result.color.g == 255);
//    try testing.expect(result.color.b == 0);
//    try testing.expect(result.reset == false);
//    try testing.expect(result.color.use_color == true);
//}
//
//test "parse ansi code 256 value - background gray" {
//    const test_str: [*:0]const u8 = "[48;5;239m";
//    var text_buff = [_]u8{0} ** 11;
//    gen_escape_code(&text_buff, test_str, 10);
//    const result = try ansi.parse_color(&text_buff);
//    try testing.expect(result.bytes_read == 11);
//    try testing.expect(result.color.foreground == false);
//    try testing.expect(result.color.r == 78);
//    try testing.expect(result.color.g == 78);
//    try testing.expect(result.color.b == 78);
//    try testing.expect(result.reset == false);
//    try testing.expect(result.color.use_color == true);
//}
//
//test "parse ansi code 256 value - reset code" {
//    const test_str: [*:0]const u8 = "[0m";
//    var text_buff = [_]u8{0} ** 4;
//    gen_escape_code(&text_buff, test_str, 4);
//    const result = try ansi.parse_color(&text_buff);
//    try testing.expect(result.bytes_read == 4);
//    try testing.expect(result.color.foreground == false);
//    try testing.expect(result.color.r == 0);
//    try testing.expect(result.color.g == 0);
//    try testing.expect(result.color.b == 0);
//    try testing.expect(result.reset == true);
//    try testing.expect(result.color.use_color == false);
//}
//
//test "parse ansi code 256 value - bold" {
//    const test_str: [*:0]const u8 = "[0m";
//    var text_buff = [_]u8{0} ** 4;
//    gen_escape_code(&text_buff, test_str, 4);
//    const result = try ansi.parse_color(&text_buff);
//    try testing.expect(result.bytes_read == 4);
//    try testing.expect(result.color.foreground == false);
//    try testing.expect(result.color.r == 0);
//    try testing.expect(result.color.g == 0);
//    try testing.expect(result.color.b == 0);
//    try testing.expect(result.reset == false);
//    try testing.expect(result.color.use_color == false);
//    try testing.expect(result.color.bold == true);
//}
//test "parse ansi code 256 value - at index" {
//    const test_str: [*:0]const u8 = "[38;5;56m";
//    var text_buff = [_]u8{0} ** 15;
//    gen_escape_code_post_fix(&text_buff, test_str, 5, 9);
//    const result = try ansi.parse_color_at(&text_buff, 5);
//    try testing.expect(result.bytes_read == 10);
//    try testing.expect(result.color.foreground == true);
//    try testing.expect(result.color.r == 99);
//    try testing.expect(result.color.g == 81);
//    try testing.expect(result.color.b == 215);
//    try testing.expect(result.reset == false);
//    try testing.expect(result.color.use_color == false);
//}
