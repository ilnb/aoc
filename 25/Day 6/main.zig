const std = @import("std");
const N = 4;
const L = 3772;

pub fn main() !void {
    const file = try std.fs.cwd().openFile("input", .{ .mode = .read_only });
    defer file.close();
    var file_buf: [4000]u8 = undefined;
    var file_r = file.reader(&file_buf);
    const reader = &file_r.interface;

    var gpa = std.heap.DebugAllocator(.{}){};
    defer {
        const status = gpa.deinit();
        if (status == .leak) std.testing.expect(false) catch @panic("FAILURE");
    }
    const ga = gpa.allocator();

    var lines = try std.ArrayList([]u8).initCapacity(ga, N);
    defer {
        for (lines.items) |str| ga.free(str);
        lines.deinit(ga);
    }

    var nums = try std.ArrayList(std.ArrayList(u64)).initCapacity(ga, N);
    defer {
        for (nums.items) |*arr| arr.deinit(ga);
        nums.deinit(ga);
    }

    for (0..N) |i| {
        try nums.append(ga, std.ArrayList(u64){});

        const l = (try reader.takeDelimiter('\n')).?;
        const cp = try ga.alloc(u8, l.len);
        @memcpy(cp, l);
        try lines.append(ga, cp);

        var itr = std.mem.tokenizeScalar(u8, l, ' ');
        while (itr.next()) |nbuf| {
            const n = try std.fmt.parseInt(u64, nbuf, 10);
            try nums.items[i].append(ga, n);
        }
    }

    var ops = try std.ArrayList(u8).initCapacity(ga, N);
    defer ops.deinit(ga);

    {
        const l = (try reader.takeDelimiter('\n')).?;

        var itr = std.mem.tokenizeScalar(u8, l, ' ');
        while (itr.next()) |entry| {
            try ops.append(ga, entry[0]);
        }
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
    var ridx: usize = L - 1;
    var oidx = ops.items.len - 1;
    while (oidx >= 0) : (oidx -= 1) {
        while (true) {
            var found = false;
            for (0..N) |i| {
                if (lines.items[i][ridx] != ' ') {
                    found = true;
                    break;
                }
            }
            if (found) break;
            ridx -= 1;
        }

        const op = ops.items[oidx];
        var t: u64 = if (op == '+') 0 else 1;
        while (true) {
            var n: u64 = 0;
            for (0..N) |i| {
                if (lines.items[i][ridx] != ' ') {
                    n = n * 10 + lines.items[i][ridx] - '0';
                }
            }
            if (n == 0) break;

            switch (op) {
                '+' => t += n,
                '*' => t *= n,
                else => unreachable,
            }

            if (ridx == 0) break;
            ridx -= 1;
        }
        p2 += t;
        if (oidx == 0) break;
    }

    var stdout_buf: [30]u8 = undefined;
    var stdout_writer = std.fs.File.stdout().writer(&stdout_buf);
    const stdout = &stdout_writer.interface;

    try stdout.print("p1: {d}\np2: {d}\n", .{ p1, p2 });
    try stdout.flush();
}
