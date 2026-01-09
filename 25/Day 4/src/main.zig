const std = @import("std");
const N = 138;

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
    var file_buf: [140]u8 = undefined;
    var file_r = file.reader(&file_buf);
    const reader = &file_r.interface;

    var grid = try std.ArrayList([]u8).initCapacity(ga, N);
    defer {
        for (grid.items) |l| ga.free(l);
        grid.deinit(ga);
    }
    for (0..N) |_| {
        const l = (try reader.takeDelimiter('\n')).?;
        try grid.append(ga, try ga.dupe(u8, l));
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

    var std_w = std.fs.File.stdout().writer(&.{});
    var stdout = &std_w.interface;

    try stdout.print("p1: {d}\np2: {d}\n", .{ p1, p2 });
    try stdout.flush();
}

fn valid(x: i9, y: i9) bool {
    return x >= 0 and x < N and y >= 0 and y < N;
}
