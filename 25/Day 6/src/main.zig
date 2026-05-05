const std = @import("std");
const N = 4;
const L = 3772;

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
    var file_buf: [4000]u8 = undefined;
    var file_r = file.reader(io, &file_buf);
    const reader = &file_r.interface;

    var lines: std.ArrayList([]u8) = try .initCapacity(ga, N);
    defer {
        for (lines.items) |str| ga.free(str);
        lines.deinit(ga);
    }

    var nums: std.ArrayList(std.ArrayList(u64)) = try .initCapacity(ga, N);
    defer {
        for (nums.items) |*arr| arr.deinit(ga);
        nums.deinit(ga);
    }

    for (0..N) |i| {
        try nums.append(ga, std.ArrayList(u64).empty);

        const l = (try reader.takeDelimiter('\n')).?;
        try lines.append(ga, try ga.dupe(u8, l));

        var itr = std.mem.tokenizeScalar(u8, l, ' ');
        while (itr.next()) |nbuf| {
            const n = try std.fmt.parseInt(u64, nbuf, 10);
            try nums.items[i].append(ga, n);
        }
    }

    var ops: std.ArrayList(u8) = try .initCapacity(ga, N);
    defer ops.deinit(ga);

    const l = (try reader.takeDelimiter('\n')).?;

    var itr = std.mem.tokenizeScalar(u8, l, ' ');
    while (itr.next()) |entry| {
        try ops.append(ga, entry[0]);
    }

    var p1: u64 = 0;
    for (ops.items, 0..) |op, j| {
        var t: u64 = if (op == '+') 0 else 1;
        for (0..N) |i| {
            switch (op) {
                '+' => t += nums.items[i].items[j],
                '*' => t *= nums.items[i].items[j],
                else => unreachable,
            }
        }
        p1 += t;
    }

    var p2: u64 = 0;
    var ridx: i32 = @intCast(L - 1);
    var oidx: i32 = @intCast(ops.items.len - 1);
    while (oidx >= 0) : (oidx -= 1) {
        while (true) {
            var found = false;
            const ri: usize = @intCast(ridx);
            for (0..N) |i| {
                if (lines.items[i][ri] != ' ') {
                    found = true;
                    break;
                }
            }
            if (found) break;
            ridx -= 1;
        }

        const op = ops.items[@intCast(oidx)];
        var t: u64 = if (op == '+') 0 else 1;
        while (ridx >= 0) {
            var n: u64 = 0;
            const ri: usize = @intCast(ridx);
            for (0..N) |i| {
                if (lines.items[i][ri] != ' ') {
                    n = n * 10 + lines.items[i][ri] - '0';
                }
            }
            if (n == 0) break;

            switch (op) {
                '+' => t += n,
                '*' => t *= n,
                else => unreachable,
            }
            ridx -= 1;
        }
        p2 += t;
    }

    var std_w = std.Io.File.stdout().writer(io, &.{});
    var stdout = &std_w.interface;

    try stdout.print("p1: {d}\np2: {d}\n", .{ p1, p2 });
    try stdout.flush();
}
