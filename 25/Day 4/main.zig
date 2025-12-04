const std = @import("std");
const N = 138;

pub fn main() !void {
    const in_file = try std.fs.cwd().openFile("input", .{ .mode = .read_only });
    defer in_file.close();
    var in_buf: [150]u8 = undefined;
    var in_r = in_file.reader(&in_buf);
    const reader = &in_r.interface;

    var gpa = std.heap.DebugAllocator(.{}){};
    defer {
        const status = gpa.deinit();
        if (status == .leak) std.testing.expect(false) catch @panic("FAILURE");
    }
    const ga = gpa.allocator();

    var grid = try std.ArrayList([]u8).initCapacity(ga, N);
    defer {
        for (grid.items) |l| ga.free(l);
        grid.deinit(ga);
    }
    for (0..N) |_| {
        const l = (try reader.takeDelimiter('\n')).?;
        const str = try ga.alloc(u8, l.len);
        @memcpy(str, l);
        try grid.append(ga, str);
    }

    const Dir = packed struct {
        dx: i2,
        dy: i2,
    };

    const dirs = [8]Dir{
        .{ .dx = -1, .dy = -1 },
        .{ .dx = 0, .dy = -1 },
        .{ .dx = 1, .dy = -1 },
        .{ .dx = -1, .dy = 0 },
        .{ .dx = 1, .dy = 0 },
        .{ .dx = -1, .dy = 1 },
        .{ .dx = 0, .dy = 1 },
        .{ .dx = 1, .dy = 1 },
    };

    var p1: u32 = 0;
    for (0..N) |ui| {
        const i: i9 = @intCast(ui);
        for (0..N) |uj| {
            const j: i9 = @intCast(uj);
            if (grid.items[ui][uj] != '@') continue;

            var n: u4 = 0;
            for (dirs) |dir| {
                const x = i - dir.dx;
                const y = j - dir.dy;
                if (valid(x, y) and grid.items[@intCast(x)][@intCast(y)] == '@')
                    n += 1;
            }
            if (n < 4)
                p1 += 1;
        }
    }

    var p2: u32 = 0;
    while (true) {
        var sum: u32 = 0;
        for (0..N) |ui| {
            const i: i9 = @intCast(ui);
            for (0..N) |uj| {
                const j: i9 = @intCast(uj);
                if (grid.items[ui][uj] != '@') continue;

                var n: u4 = 0;
                for (dirs) |dir| {
                    const x = i - dir.dx;
                    const y = j - dir.dy;
                    if (valid(x, y) and grid.items[@intCast(x)][@intCast(y)] == '@')
                        n += 1;
                }
                if (n < 4) {
                    sum += 1;
                    grid.items[ui][uj] = '.';
                }
            }
        }
        if (sum == 0) break;
        p2 += sum;
    }

    var stdout_buf: [30]u8 = undefined;
    var stdout_writer = std.fs.File.stdout().writer(&stdout_buf);
    const stdout = &stdout_writer.interface;

    try stdout.print("p1: {d}\np2: {d}\n", .{ p1, p2 });
    try stdout.flush();
}

fn valid(x: i9, y: i9) bool {
    return x >= 0 and x < N and y >= 0 and y < N;
}
