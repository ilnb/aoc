const std = @import("std");

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    const ga = init.gpa;
    const args = try init.minimal.args.toSlice(init.arena.allocator());
    if (args.len < 2) {
        std.debug.print("Provide the input file from cmdline\n", .{});
        return error.ExpectedArgument;
    }

    const file = try std.Io.Dir.cwd().openFile(io, args[1], .{ .mode = .read_only });
    defer file.close(io);
    var file_buf: [128]u8 = undefined;
    var file_r = file.reader(io, &file_buf);
    const reader = &file_r.interface;

    var lines = std.ArrayList([]u8).empty;
    defer {
        for (lines.items) |l| ga.free(l);
        lines.deinit(ga);
    }

    var p1: u32 = 0;
    while (try reader.takeDelimiter('\n')) |l| {
        try lines.append(ga, try ga.dupe(u8, l));

        var prev: u8, var curr: u8 = .{0} ** 2;

        var i: i32 = @intCast(l.len - 2);
        var save: usize = 0;
        while (i >= 0) : (i -= 1) {
            const ii: usize = @intCast(i);
            if (l[ii] - '0' >= curr) {
                curr = l[ii] - '0';
                save = ii;
            }
        }

        for (l[save + 1 ..]) |c| {
            prev = @max(prev, c - '0');
        }
        p1 += 10 * curr + prev;
    }

    var p2: u64 = 0;
    for (lines.items) |l| {
        var st = std.ArrayList(u8).empty;
        defer st.deinit(ga);

        var r = l.len - 12;
        const len = &st.items.len;
        for (l) |c| {
            const d = c - '0';
            while (len.* != 0 and r > 0 and st.items[len.* - 1] < d) {
                _ = st.pop();
                r -= 1;
            }
            try st.append(ga, d);
        }

        var val: u64 = 0;
        for (st.items[0..12]) |n| val = val * 10 + n;
        p2 += val;
    }

    var std_w = std.Io.File.stdout().writer(io, &.{});
    var stdout = &std_w.interface;

    try stdout.print("p1: {d}\np2: {d}\n", .{ p1, p2 });
    try stdout.flush();
}
