const std = @import("std");
const N = 4664;

pub fn main() !void {
    const in_file = try std.fs.cwd().openFile("input", .{ .mode = .read_only });
    var in_buf: [100]u8 = undefined;
    var in_r = in_file.reader(&in_buf);
    var reader = &in_r.interface;

    var dial: u32 = 50;
    var p1: u32, var p2: u32 = .{ 0, 0 };
    for (0..N) |_| {
        const l = try reader.takeDelimiterExclusive('\n');
        _ = try reader.takeByte();
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

    var stdout_buf: [30]u8 = undefined;
    var stdout_writer = std.fs.File.stdout().writer(&stdout_buf);
    const stdout = &stdout_writer.interface;

    try stdout.print("p1: {d}\np2: {d}\n", .{ p1, p2 });
    try stdout.flush();
}
