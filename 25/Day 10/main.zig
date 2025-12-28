// https://www.reddit.com/r/adventofcode/comments/1pk87hl/2025_day_10_part_2_bifurcate_your_way_to_victory/
// legendary post

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

    var p1: u16, var p2: u16 = .{ 0, 0 };
    for (machines.items) |m| {
        var val: u16 = std.math.maxInt(u16);
        toggleToOn(&val, 0, 0, 0, m.config, m.buttons.items);
        p1 += val;
        val = toggleToJolt(m.config, m.buttons.items, m.joltage.items);
        p2 += val;
    }

    var std_w = std.fs.File.stdout().writer(&.{});
    var stdout = &std_w.interface;

    try stdout.print("p1: {d}\np2: {d}\n", .{ p1, p2 });
    try stdout.flush();
}

fn toggleToOn(val: *u16, idx: u16, chosen: u16, curr: u16, cfg: u16, buttons: []u16) void {
    if (curr == cfg) {
        val.* = @min(val.*, chosen);
        return;
    }
    const n: u16 = @intCast(buttons.len);

    if (idx == n) return;

    var i = idx;
    while (i < n) : (i += 1) {
        toggleToOn(val, i + 1, chosen + 1, curr ^ buttons[i], cfg, buttons);
        toggleToOn(val, i + 1, chosen, curr, cfg, buttons);
    }
}

fn toggleToJolt(cfg: u16, buttons: []u16, joltage: []u16) u16 {
    var done = true;
    for (joltage) |j| {
        if (j != 0) done = false;
    }
    if (done) return 0;

    var new_cfg = cfg;
    for (joltage, 0..) |j, b| {
        if (j % 2 == 1)
            new_cfg ^= @as(u16, 1) << @as(u4, @intCast(b));
    }

    var min_cost: u16 = std.math.maxInt(u16);
    findMinCost(&min_cost, 0, cfg, new_cfg, buttons, joltage, [_]u8{0} ** 16);
    return min_cost;
}

fn findMinCost(min_cost: *u16, idx: u16, curr: u16, final: u16, buttons: []u16, joltage: []u16, presses: [16]u8) void {
    if (idx == buttons.len) {
        if (curr == final) {
            // Compute cost for this solution
            var val: u16 = 0;
            for (presses) |p| val += p;

            var s_jolts = [_]i32{0} ** 16;
            for (joltage, 0..) |j, i| s_jolts[i] = @intCast(j);

            for (presses, 0..) |p, i| {
                if (p == 0) continue;

                const changes = buttons[i];
                for (0..joltage.len) |j| {
                    const c = (changes >> @as(u4, @intCast(j))) & 1;
                    if (c == 1) s_jolts[j] -= @as(i32, p);
                }
            }

            // Check if all values are valid
            for (0..joltage.len) |i| {
                if (s_jolts[i] < 0 or @mod(s_jolts[i], 2) != 0) return;
                s_jolts[i] = @divTrunc(s_jolts[i], 2);
            }

            var new_jolts = [_]u16{0} ** 16;
            for (0..joltage.len) |i| new_jolts[i] = @intCast(s_jolts[i]);

            const cost = toggleToJolt(final, buttons, new_jolts[0..joltage.len]);
            if (cost == std.math.maxInt(u16))
                return;
            const total = val + 2 * cost;
            if (total < min_cost.*) min_cost.* = total;
        }
        return;
    }

    const n: u16 = @intCast(buttons.len);
    if (idx == n) return;

    findMinCost(min_cost, idx + 1, curr, final, buttons, joltage, presses);

    var chosen = presses;
    chosen[idx] += 1;
    findMinCost(min_cost, idx + 1, curr ^ buttons[idx], final, buttons, joltage, chosen);
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
