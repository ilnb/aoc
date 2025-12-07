const std = @import("std");

pub fn main() !void {
    const file = try std.fs.cwd().openFile("input", .{ .mode = .read_only });
    defer file.close();
    var file_buf: [512]u8 = undefined;
    var file_r = file.reader(&file_buf);
    const reader = &file_r.interface;

    var p1: u64, var p2: u64 = .{ 0, 0 };
    while (true) {
        const _l = try reader.takeDelimiter('\n');
        if (_l == null) break;

        const line = _l.?;
        var itr = std.mem.tokenizeScalar(u8, line, '-');
        const ls = (itr.next()).?;
        const rs = (itr.next()).?;

        const l = try std.fmt.parseInt(u64, ls, 10);
        const r = try std.fmt.parseInt(u64, rs, 10);
        for (l..r + 1) |id| {
            var buf: [20]u8 = undefined;
            const s = try std.fmt.bufPrint(buf[0..], "{d}", .{id});
            if (!validId(s)) {
                p1 += id;
                p2 += id;
            } else if (!validId2(s)) {
                p2 += id;
            }
        }
    }

    var std_w = std.fs.File.stdout().writer(&.{});
    var stdout = &std_w.interface;

    try stdout.print("p1: {d}\np2: {d}\n", .{ p1, p2 });
    try stdout.flush();
}

fn validId(s: []u8) bool {
    const n = s.len;
    if (n % 2 == 1) return true;

    const m = n / 2;
    for (0..m) |i| {
        if (s[i] != s[i + m]) return true;
    }
    return false;
}

fn validId2(s: []u8) bool {
    const n = s.len;
    for (1..(n + 1) / 2) |l| {
        if (n % l != 0) continue;
        const pattern = s[0..l];
        var r = true;
        for (0..n) |i| {
            if (s[i] != pattern[i % l]) {
                r = false;
                break;
            }
        }
        if (r) return false;
    }
    return true;
}
