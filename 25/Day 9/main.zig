const std = @import("std");
const Point = struct {
    x: u32,
    y: u32,
};

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

    var points = try std.ArrayList(Point).initCapacity(ga, 10);
    defer points.deinit(ga);

    while (true) {
        const _l = try reader.takeDelimiter('\n');
        if (_l == null) break;

        const l = _l.?;
        var itr = std.mem.tokenizeScalar(u8, l, ',');
        const x = try std.fmt.parseInt(u32, (itr.next()).?, 10);
        const y = try std.fmt.parseInt(u32, (itr.next()).?, 10);
        try points.append(ga, .{ .x = x, .y = y });
    }

    var p1: u64 = 0;
    var p2: u64 = 0;
    for (points.items, 0..) |a, i| {
        for (points.items[i + 1 ..]) |b| {
            const xmin = @min(a.x, b.x);
            const xmax = @max(a.x, b.x);
            const ymin = @min(a.y, b.y);
            const ymax = @max(a.y, b.y);
            const dx: usize = xmax - xmin + 1;
            const dy: usize = ymax - ymin + 1;
            const ar = dx * dy;

            p1 = @max(ar, p1);

            if (checkRect(a, b, points.items))
                p2 = @max(ar, p2);
        }
    }
    std.debug.print("{d}\n", .{p1});
    std.debug.print("{d}\n", .{p2});
}

fn checkRect(a: Point, b: Point, arr: []Point) bool {
    const xmin = @min(a.x, b.x);
    const xmax = @max(a.x, b.x);
    const ymin = @min(a.y, b.y);
    const ymax = @max(a.y, b.y);

    const n = arr.len;
    for (arr, 0..) |p, i| {
        const q = arr[(i + 1) % n];

        if (p.x == q.x) {
            const ex = p.x;
            if (ex > xmin and ex < xmax) {
                const eymin = @min(p.y, q.y);
                const eymax = @max(p.y, q.y);
                if (@max(ymin, eymin) < @min(ymax, eymax)) {
                    return false;
                }
            }
        } else {
            const ey = p.y;
            if (ey > ymin and ey < ymax) {
                const exmin = @min(p.x, q.x);
                const exmax = @max(p.x, q.x);
                if (@max(xmin, exmin) < @min(xmax, exmax)) {
                    return false;
                }
            }
        }
    }

    return true;
}
