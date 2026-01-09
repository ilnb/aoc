const std = @import("std");

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

    var dial: u32 = 50;
    var p1: u32, var p2: u32 = .{ 0, 0 };
    while (true) {
        const _l = try reader.takeDelimiter('\n');
        if (_l == null) break;

        const l = _l.?;

        const dir = l[0];
        var val = try std.fmt.parseInt(u32, l[1..], 10);

        if (val > 100) p2 += val / 100;
        val %= 100;

        const flag: bool = (dial != 0) and switch (dir) {
            'L' => val > dial,
            'R' => val > 100 - dial,
            else => @panic("parsing error in `dir`\n"),
        };
        if (flag)
            p2 += 1;

        dial = switch (dir) {
            'L' => (dial + 100 - val) % 100,
            'R' => (dial + val) % 100,
            else => unreachable,
        };

        if (dial == 0) p1 += 1;
        if (flag and dial == 0) p2 -= 1;
    }
    p2 += p1;

    var std_w = std.fs.File.stdout().writer(&.{});
    var stdout = &std_w.interface;

    try stdout.print("p1: {d}\np2: {d}\n", .{ p1, p2 });
    try stdout.flush();
}
