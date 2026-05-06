const std = @import("std");
const DSU = @import("dsu").DSU;
const N = 1000;

const Point = @Tuple(&.{ u32, u32, u32 });

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

    var lines: [N]Point = undefined;
    for (0..N) |i| {
        var it = std.mem.tokenizeScalar(u8, (try reader.takeDelimiter('\n')).?, ',');
        const x = try std.fmt.parseInt(u32, (it.next()).?, 10);
        const y = try std.fmt.parseInt(u32, (it.next()).?, 10);
        const z = try std.fmt.parseInt(u32, (it.next()).?, 10);
        lines[i] = .{ x, y, z };
    }

    const Data = @Tuple(&.{ u64, usize, usize });

    var pq = std.PriorityQueue(Data, void, struct {
        fn lt(_: void, a: Data, b: Data) std.math.Order {
            return std.math.order(a.@"0", b.@"0");
        }
    }.lt).empty;
    defer pq.deinit(ga);

    for (0..N) |i| for (i + 1..N) |j| {
        const d = dist(lines[i], lines[j]);
        try pq.push(ga, .{ d, i, j });
    };

    var dsu = try DSU(usize).init(ga, N);
    defer dsu.deinit();

    for (0..N) |_| {
        _, const u, const v = pq.pop().?;
        dsu.join(u, v);
    }

    var size_pq = std.PriorityQueue(usize, void, struct {
        fn lt(_: void, a: usize, b: usize) std.math.Order {
            return std.math.order(a, b);
        }
    }.lt).empty;
    defer size_pq.deinit(ga);

    for (dsu.size) |x| {
        try size_pq.push(ga, x);
        if (size_pq.items.len > 3) _ = size_pq.pop();
    }

    var p1: u64 = 1;
    while (size_pq.pop()) |v| p1 *= v;

    var p2: u64 = 0;
    while (pq.pop()) |t| {
        _, const u, const v = t;
        dsu.join(u, v);
        if (dsu.ncomps == 1) {
            const x1 = lines[u].@"1";
            const x2 = lines[v].@"1";
            p2 = x1 * x2;
            break;
        }
    }

    var std_w = std.Io.File.stdout().writer(io, &.{});
    var stdout = &std_w.interface;

    try stdout.print("p1: {d}\np2: {d}\n", .{ p1, p2 });
    try stdout.flush();
}

fn dist(p1: Point, p2: Point) u64 {
    const x1, const y1, const z1 = p1;
    const x2, const y2, const z2 = p2;

    const dx = @as(i64, x1) - @as(i64, x2);
    const dy = @as(i64, y1) - @as(i64, y2);
    const dz = @as(i64, z1) - @as(i64, z2);

    var sum: u64 = @intCast(dx * dx);
    sum += @intCast(dy * dy);
    sum += @intCast(dz * dz);
    return sum;
}
