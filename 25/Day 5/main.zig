const std = @import("std");

pub fn main() !void {
    const in_file = try std.fs.cwd().openFile("input", .{ .mode = .read_only });
    defer in_file.close();
    var in_buf: [100]u8 = undefined;
    var in_r = in_file.reader(&in_buf);
    const reader = &in_r.interface;

    var gpa = std.heap.DebugAllocator(.{}){};
    defer {
        const status = gpa.deinit();
        if (status == .leak) std.testing.expect(false) catch @panic("FAILURE");
    }
    const ga = gpa.allocator();

    var ranges = try std.ArrayList([2]u64).initCapacity(ga, 10);
    defer ranges.deinit(ga);

    while (true) {
        const l = (try reader.takeDelimiter('\n')).?;
        if (l.len == 0) break;

        var itr = std.mem.tokenizeScalar(u8, l, '-');
        const num1: u64 = try std.fmt.parseInt(u64, (itr.next()).?, 10);
        const num2: u64 = try std.fmt.parseInt(u64, (itr.next()).?, 10);

        try ranges.append(ga, [2]u64{ num1, num2 });
    }

    var nums = try std.ArrayList(u64).initCapacity(ga, 10);
    defer nums.deinit(ga);

    while (true) {
        const _l = (try reader.takeDelimiter('\n'));
        if (_l == null) break;

        const l = _l.?;
        if (l.len == 0) break;

        const num = try std.fmt.parseInt(u64, l, 10);
        try nums.append(ga, num);
    }

    for (nums.items) |*n| {
        var found = false;
        for (ranges.items) |r| {
            if (r[0] <= n.* and n.* <= r[1]) {
                found = true;
                break;
            }
        }
        if (!found) n.* = 0;
    }

    var p1: u64 = 0;
    for (nums.items) |n| {
        if (n != 0)
            p1 += 1;
    }

    std.sort.heap([2]u64, ranges.items, {}, struct {
        fn lessThan(_: void, a: [2]u64, b: [2]u64) bool {
            return a[0] < b[0];
        }
    }.lessThan);

    // interval merging
    var idx: usize = 0;
    for (ranges.items[1..]) |r| {
        var prev = &ranges.items[idx];
        if (r[0] <= prev[1]) {
            // p[0]..r[0]..p[1]..r[1] -> p[0]..r[0]..r[1]
            // like [2..8], [5..10] -> [2..10], [5..10]
            if (r[1] > prev[1]) prev[1] = r[1];
        } else {
            idx += 1;
            // overwrites the redundant interval
            ranges.items[idx] = r;
        }
    }
    // rest is garbage
    ranges.shrinkRetainingCapacity(idx + 1);

    var p2: u64 = 0;
    for (ranges.items) |r| {
        p2 += r[1] - r[0] + 1;
    }

    var stdout_buf: [20]u8 = undefined;
    var stdout_writer = std.fs.File.stdout().writer(&stdout_buf);
    const stdout = &stdout_writer.interface;

    try stdout.print("p1: {d}\np2: {d}\n", .{ p1, p2 });
    try stdout.flush();
}
