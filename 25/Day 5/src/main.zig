const std = @import("std");
const parseInt = std.fmt.parseInt;

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

    var ranges = std.ArrayList([2]u64).empty;
    defer ranges.deinit(ga);

    while (try reader.takeDelimiter('\n')) |l| {
        if (l.len == 0) break;

        var itr = std.mem.tokenizeScalar(u8, l, '-');
        const num1 = try parseInt(u64, (itr.next()).?, 10);
        const num2 = try parseInt(u64, (itr.next()).?, 10);

        try ranges.append(ga, [2]u64{ num1, num2 });
    }

    var nums = std.ArrayList(u64).empty;
    defer nums.deinit(ga);

    while (try reader.takeDelimiter('\n')) |l| {
        const num = try parseInt(u64, l, 10);
        try nums.append(ga, num);
    }

    sortAndMerge(&ranges);

    var p1: u64 = 0;
    for (nums.items) |n| {
        const items = ranges.items;
        const idx = std.sort.lowerBound([2]u64, items, n, struct {
            fn lt(ctx: u64, r: [2]u64) std.math.Order {
                return std.math.order(ctx, r[1]);
            }
        }.lt);

        p1 += @intFromBool(idx != items.len and items[idx][0] <= n);
    }

    var p2: u64 = 0;
    for (ranges.items) |r| p2 += r[1] - r[0] + 1;

    var std_w = std.Io.File.stdout().writer(io, &.{});
    var stdout = &std_w.interface;

    try stdout.print("p1: {d}\np2: {d}\n", .{ p1, p2 });
    try stdout.flush();
}

fn sortAndMerge(ranges: *std.ArrayList([2]u64)) void {
    std.mem.sort([2]u64, ranges.items, {}, struct {
        fn lt(_: void, a: [2]u64, b: [2]u64) bool {
            return a[0] < b[0];
        }
    }.lt);

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
