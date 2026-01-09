const std = @import("std");
const DSU = @import("dsu").DSU;
const N = 1000;

const Point = struct { x: u32, y: u32, z: u32 };

pub fn main() !void {
    var gpa = std.heap.DebugAllocator(.{}){};
    defer {
        const status = gpa.deinit();
        if (status == .leak) std.testing.expect(false) catch @panic("FAILURE");
    }
    const ga = gpa.allocator();

    const args = try std.process.argsAlloc(ga);
    defer std.process.argsFree(ga, args);

    if (args.len < 2) {
        std.debug.print("Provide the input file from cmdline\n", .{});
        return error.ExpectedArgument;
    }

    const file = try std.fs.cwd().openFile(args[1], .{ .mode = .read_only });
    defer file.close();
    var file_buf: [128]u8 = undefined;
    var file_r = file.reader(&file_buf);
    const reader = &file_r.interface;

    var lines: [N]Point = undefined;
    for (0..N) |i| {
        var it = std.mem.tokenizeScalar(u8, (try reader.takeDelimiter('\n')).?, ',');
        const x = try std.fmt.parseInt(u32, (it.next()).?, 10);
        const y = try std.fmt.parseInt(u32, (it.next()).?, 10);
        const z = try std.fmt.parseInt(u32, (it.next()).?, 10);
        lines[i] = .{ .x = x, .y = y, .z = z };
    }

    const Data = struct {
        d: u64,
        u: usize,
        v: usize,
        fn lt(_: void, a: @This(), b: @This()) std.math.Order {
            return std.math.order(a.d, b.d);
        }
    };

    var pq = std.PriorityQueue(Data, void, Data.lt).init(ga, {});
    defer pq.deinit();

    for (0..N) |i| {
        for (i + 1..N) |j| {
            const d = dist(lines[i], lines[j]);
            try pq.add(.{ .d = d, .u = i, .v = j });
        }
    }

    var dsu = try DSU(usize).init(ga, N);
    defer dsu.deinit();

    for (0..N) |_| {
        const t = pq.remove();
        dsu.join(t.u, t.v);
    }

    var size_pq = std.PriorityQueue(usize, void, struct {
        fn lt(_: void, a: usize, b: usize) std.math.Order {
            return std.math.order(b, a);
        }
    }.lt).init(ga, {});
    defer size_pq.deinit();

    for (dsu.size) |x| try size_pq.add(x);

    var p1: u64 = 1;
    for (0..3) |_| p1 *= size_pq.remove();

    var p2: u64 = 0;
    while (pq.items.len != 0) {
        const t = pq.remove();
        dsu.join(t.u, t.v);
        if (dsu.ncomps == 1) {
            const x1 = lines[t.u].x;
            const x2 = lines[t.v].x;
            p2 = x1 * x2;
            break;
        }
    }

    var std_w = std.fs.File.stdout().writer(&.{});
    var stdout = &std_w.interface;

    try stdout.print("p1: {d}\np2: {d}\n", .{ p1, p2 });
    try stdout.flush();
}

fn dist(p1: Point, p2: Point) u64 {
    const x1, const y1, const z1 = .{ p1.x, p1.y, p1.z };
    const x2, const y2, const z2 = .{ p2.x, p2.y, p2.z };

    const dx = @as(i64, x1) - @as(i64, x2);
    const dy = @as(i64, y1) - @as(i64, y2);
    const dz = @as(i64, z1) - @as(i64, z2);

    var sum: u64 = @intCast(dx * dx);
    sum += @intCast(dy * dy);
    sum += @intCast(dz * dz);
    return sum;
}
