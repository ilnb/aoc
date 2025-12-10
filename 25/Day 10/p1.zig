const std = @import("std");

pub fn main() !void {
    const file = try std.fs.cwd().openFile("input", .{ .mode = .read_only });
    defer file.close();
    var file_buf: [512]u8 = undefined;
    var file_r = file.reader(&file_buf);
    const reader = &file_r.interface;

    var gpa = std.heap.DebugAllocator(.{}){};
    defer {
        const status = gpa.deinit();
        if (status == .leak) std.testing.expect(false) catch {};
    }
    const ga = gpa.allocator();

    const Machine = struct {
        config: u16,
        buttons: std.ArrayList(u16),
        joltage: std.ArrayList(u16),

        pub fn format(m: @This(), wr: *std.io.Writer) std.io.Writer.Error!void {
            try wr.print("{b} ", .{m.config});
            for (m.buttons.items) |btn| {
                try wr.print("{b}, ", .{btn});
            }
            try wr.writeAll("{");
            for (m.joltage.items) |j| {
                try wr.print("{d},", .{j});
            }
            try wr.writeAll("}");
        }
    };

    var machines = try std.ArrayList(Machine).initCapacity(ga, 10);
    defer {
        for (machines.items) |*m| {
            m.joltage.deinit(ga);
            m.buttons.deinit(ga);
        }
        machines.deinit(ga);
    }

    while (true) {
        const _l = try reader.takeDelimiter('\n');
        if (_l == null) break;

        const l = _l.?;
        var itr = std.mem.tokenizeScalar(u8, l, ' ');
        var m: Machine = .{
            .config = undefined,
            .buttons = try std.ArrayList(u16).initCapacity(ga, 5),
            .joltage = try std.ArrayList(u16).initCapacity(ga, 5),
        };

        const cfg = itr.next().?;
        m.config = cfg2Mask(cfg[1 .. cfg.len - 1]);

        while (true) {
            const sl = itr.next().?;

            if (sl[0] == '{') {
                var itr2 = std.mem.tokenizeAny(u8, sl, "{,}");
                while (itr2.next()) |nbuf| {
                    const num = try std.fmt.parseInt(u16, nbuf, 10);
                    try m.joltage.append(ga, num);
                }
                break;
            }
            const buf = sl[1 .. sl.len - 1];
            const num = btn2Mask(buf);

            try m.buttons.append(ga, num);
        }
        try machines.append(ga, m);
    }

    var p1: u64 = 0;
    for (machines.items) |m| {
        var val: u16 = std.math.maxInt(u16);
        toggleToOn(&val, 0, 0, 0, m.config, m.buttons.items);
        p1 += val;
    }
    var std_w = std.fs.File.stdout().writer(&.{});
    var stdout = &std_w.interface;

    try stdout.print("p1: {d}\n", .{p1});
    try stdout.flush();
}

fn toggleToOn(val: *u16, idx: u16, chosen: u16, mask: u16, cfg: u16, buttons: []u16) void {
    if (mask == cfg) {
        val.* = @min(val.*, chosen);
        return;
    }
    const n: u16 = @intCast(buttons.len);

    if (idx == n) return;

    var i = idx;
    while (i < n) : (i += 1) {
        const new_mask = mask ^ buttons[i];
        toggleToOn(val, i + 1, chosen + 1, new_mask, cfg, buttons);
        toggleToOn(val, i + 1, chosen, mask, cfg, buttons);
    }
}

fn btn2Mask(btn: []const u8) u16 {
    var ret: u16 = 0;
    for (btn) |c| {
        if (c == ',') continue;
        ret |= @as(u16, 1) << @as(u4, @intCast(c - '0'));
    }
    return ret;
}

fn cfg2Mask(cfg: []const u8) u16 {
    var ret: u16 = 0;
    for (cfg, 0..) |c, i| {
        if (c == '#')
            ret |= @as(u16, 1) << @as(u4, @intCast(i));
    }
    return ret;
}
