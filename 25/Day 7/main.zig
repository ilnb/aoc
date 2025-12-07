const std = @import("std");
const N = 150;

pub fn main() !void {
    const file = try std.fs.cwd().openFile("input", .{ .mode = .read_only });
    defer file.close();
    var file_buf: [300]u8 = undefined;
    var file_r = file.reader(&file_buf);
    const reader = &file_r.interface;

    var tl: [N]u64 = .{0} ** N;

    const pos: usize = blk: {
        const l = (try reader.takeDelimiter('\n')).?;
        var idx: usize = 0;
        while (idx < l.len) : (idx += 1) {
            if (l[idx] == 'S')
                break;
        }
        break :blk idx;
    };

    tl[pos] = 1;

    var skip = true;
    var p1: u16 = 0;
    var p2: u64 = 0;
    while (true) {
        const _l = try reader.takeDelimiter('\n');
        if (_l == null) break;

        const _s = skip;
        skip = !skip;
        if (_s) continue;

        const l = _l.?;
        for (l, 0..) |c, i| {
            if (c == '^' and tl[i] != 0) {
                // tls in this path
                const v = tl[i];
                p1 += 1;
                if (i > 0) tl[i - 1] += v;
                if (i < N - 1) tl[i + 1] += v;
                tl[i] = 0;
            }
        }
    }
    for (tl) |s| p2 += s;

    var stdout_buf: [30]u8 = undefined;
    var stdout_writer = std.fs.File.stdout().writer(&stdout_buf);
    const stdout = &stdout_writer.interface;

    try stdout.print("p1: {d}\np2: {d}\n", .{ p1, p2 });
    try stdout.flush();
}
