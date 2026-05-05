const std = @import("std");
const N = 150;

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    const args = try init.minimal.args.toSlice(init.arena.allocator());
    if (args.len < 2) {
        std.debug.print("Provide the input file from cmdline\n", .{});
        return error.ExpectedArgument;
    }

    const file = try std.Io.Dir.cwd().openFile(io, args[1], .{ .mode = .read_only });
    defer file.close(io);
    var file_buf: [300]u8 = undefined;
    var file_r = file.reader(io, &file_buf);
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
    while (try reader.takeDelimiter('\n')) |l| {
        const s = skip;
        skip = !skip;
        if (s) continue;

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

    var std_w = std.Io.File.stdout().writer(io, &.{});
    var stdout = &std_w.interface;

    try stdout.print("p1: {d}\np2: {d}\n", .{ p1, p2 });
    try stdout.flush();
}
