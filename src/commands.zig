const std = @import("std");
const codes = @import("escape_codes.zig");

pub const csi: [2]u8 = [_]u8{ codes.escape_code, codes.control_sequence_introducer };
pub const dcs: [2]u8 = [_]u8{ codes.escape_code, codes.device_control_string };
pub const osc: [2]u8 = [_]u8{ codes.escape_code, codes.os_command };
