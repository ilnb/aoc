const std = @import("std");

pub fn main() !void {
    const file = try std.fs.cwd().openFile("input", .{ .mode = .read_only });
    defer file.close();
    var file_buf: [100]u8 = undefined;
    var file_r = file.reader(&file_buf);
    const reader = &file_r.interface;

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

    sortAndMerge(&ranges);

    var p1: u64 = 0;
    for (nums.items) |*n| {
        const items = ranges.items;
        const idx = std.sort.lowerBound([2]u64, items, n.*, struct {
            fn lt(ctx: u64, r: [2]u64) std.math.Order {
                return if (ctx < r[1]) .lt else if (ctx > r[1]) .gt else .eq;
            }
        }.lt);

        p1 += if (idx != items.len and items[idx][0] <= n.*) 1 else 0;
    }

    var p2: u64 = 0;
    for (ranges.items) |r| p2 += r[1] - r[0] + 1;

    var std_w = std.fs.File.stdout().writer(&.{});
    var stdout = &std_w.interface;

    try stdout.print("p1: {d}\np2: {d}\n", .{ p1, p2 });
    try stdout.flush();
}

fn sortAndMerge(ranges: *std.ArrayList([2]u64)) void {
    std.sort.heap([2]u64, ranges.items, {}, struct {
        fn lessThan(_: void, a: [2]u64, b: [2]u64) bool {
            return a[0] < b[0];
        }
    }.lessThan);

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
}
