/// Top level escape codes
/// Ansi Escape Code
pub const escape_code: u8 = 0x1b;
/// Character to start a control sequence.
pub const control_sequence_introducer: u8 = '[';
/// Character to start a device control string.
pub const device_control_string: u8 = 'P';
/// Character to start an OS command.
pub const os_command: u8 = ']';
pub const csi_end: u8 = 'm';
pub const param_sep: u8 = ';';

pub const bell: u8 = 0x07;
pub const backspace: u8 = 0x08;
pub const horizontal_tab: u8 = 0x09;
pub const line_feed: u8 = 0x0A;
pub const vertical_tab: u8 = 0x0B;
pub const form_feed: u8 = 0x0C;
pub const carriage_return: u8 = 0x0D;
pub const delete_char: u8 = 0x7F;

pub const foreground_ext: [2]u8 = [_]u8{ '3', '8' };
pub const background_ext: [2]u8 = [_]u8{ '4', '8' };
pub const flag_256: u8 = '5';
pub const true_color_flag: u8 = '2';

pub const move_cursor_pos: u8 = 'H';
pub const move_cursor_up: u8 = 'A';
pub const move_cursor_down: u8 = 'B';
pub const move_cursor_right: u8 = 'C';
pub const move_cursor_left: u8 = 'D';
pub const move_cursor_beg_of_next_line: u8 = 'E';
pub const move_cursor_beg_of_prev_line: u8 = 'F';
pub const move_cursor_column: u8 = 'G';
/// Returns response in format ESC[#;#R
pub const request_cursor_pos: [2]u8 = [_]u8{ '6', 'n' };
pub const move_cursor_up_with_scroll: u8 = 'M';
pub const save_cursor_pos_dec: u8 = '7';
pub const restore_cursor_pos_dec: u8 = '8';
pub const save_cursor_pos_sco: u8 = 's';
pub const restore_cursor_pos_sco: u8 = 'u';

pub const erase_display: u8 = 'J';
pub const erase_until_end_of_screen: [2]u8 = [_]u8{ '0', erase_display };
pub const erase_until_beg_of_screen: [2]u8 = [_]u8{ '1', erase_display };
pub const erase_entire_screen: [2]u8 = [_]u8{ '2', erase_display };
pub const erase_saved_lines: [2]u8 = [_]u8{ '3', erase_display };

pub const erase_line: u8 = 'K';
pub const erase_until_end_of_line: [2]u8 = [_]u8{ '0', erase_line };
pub const erase_until_beg_of_line: [2]u8 = [_]u8{ '1', erase_line };
pub const erase_entire_line: [2]u8 = [_]u8{ '2', erase_line };

pub const reset_all: u8 = '0';
pub const bold: u8 = '1';
pub const dim: u8 = '2';
pub const italic: u8 = '3';
pub const underline: u8 = '4';
pub const blinking: u8 = '5';
pub const reverse: u8 = '7';
pub const invisible: u8 = '8';
pub const strikethrough: u8 = '9';
pub const reset_sequence_prefix: u8 = '2';

pub const base_black: u8 = '0';
pub const base_red: u8 = '1';
pub const base_green: u8 = '2';
pub const base_yellow: u8 = '3';
pub const base_blue: u8 = '4';
pub const base_magenta: u8 = '5';
pub const base_cyan: u8 = '6';
pub const base_white: u8 = '7';
pub const base_default: u8 = '9';
pub const base_foreground_prefix: u8 = '3';
pub const base_background_prefix: u8 = '4';
pub const base_bright_foreground_prefix: u8 = '9';
pub const base_bright_background_prefix: [2]u8 = [_]u8{ '1', '0' };

pub const screen_mode_code: u8 = 'h';
pub const screen_mode_reset: u8 = 'l';
pub const screen_monochrome_40x25: u8 = '0';
pub const screen_color_40x25: u8 = '1';
pub const screen_monochrome_80x25: u8 = '2';
pub const screen_color_80x25: u8 = '3';
pub const screen_4color_320x200: u8 = '4';
pub const screen_monochrome_320x200: u8 = '5';
pub const screen_monochrome_640x200: u8 = '6';
pub const screen_enable_line_wrapping: u8 = '7';
pub const screen_color_320x200: [2]u8 = [_]u8{ '1', '3' };
pub const screen_color_640x200: [2]u8 = [_]u8{ '1', '4' };
pub const screen_monochrome_640x350: [2]u8 = [_]u8{ '1', '5' };
pub const screen_color_640x350: [2]u8 = [_]u8{ '1', '6' };
pub const screen_monochrome_640x480: [2]u8 = [_]u8{ '1', '7' };
pub const screen_color_640x480: [2]u8 = [_]u8{ '1', '8' };
pub const screen_256color_320x200: [2]u8 = [_]u8{ '1', '9' };

/// General errors
pub const ansi_errors = error{
    /// An incorrect format
    invalid_format,
    /// Possibly a correct format but not supported yet.
    unsupported_format,
    /// Error parsing values out from string.
    error_parsing,
};
