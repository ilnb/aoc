const std = @import("std");
const N = 200;

pub fn main() !void {
    var in_file = try std.fs.cwd().openFile("input", .{ .mode = .read_only });
    var in_buf: [1024]u8 = undefined;
    var in_r = in_file.reader(&in_buf);
    var reader = &in_r.interface;

    var p1: u32 = 0;
    for (0..N) |_| {
        const l = (try reader.takeDelimiter('\n')).?;

        var prev: u8, var curr: u8 = .{0} ** 2;

        var i = l.len - 2;
        var save: usize = 0;
        while (i >= 0) {
            if (l[i] - '0' >= curr) {
                curr = l[i] - '0';
                save = i;
            }
            if (i > 0) {
                i -= 1;
            } else if (i == 0) {
                break;
            }
        }

        for (l[save + 1 ..]) |c| {
            prev = @max(prev, c - '0');
        }
        p1 += 10 * curr + prev;
    }

    in_file.close();
    in_file = try std.fs.cwd().openFile("input", .{ .mode = .read_only });
    in_r = in_file.reader(&in_buf);
    reader = &in_r.interface;
    defer in_file.close();

    var p2: u64 = 0;
    for (0..N) |_| {
        const l = (try reader.takeDelimiter('\n')).?;

        var gpa = std.heap.DebugAllocator(.{}){};
        defer {
            const status = gpa.deinit();
            if (status == .leak) std.testing.expect(false) catch @panic("FAILURE");
        }
        const ga = gpa.allocator();

        var r = l.len - 12;
        var st = try std.ArrayList(u8).initCapacity(ga, 5);
        defer st.deinit(ga);
        const len = &st.items.len;
        for (l) |c| {
            const d = c - '0';
            while (len.* != 0 and r > 0 and st.items[len.* - 1] < d) {
                st.shrinkRetainingCapacity(len.* - 1);
                r -= 1;
            }
            try st.append(ga, d);
        }
        var val: u64 = 0;
        for (st.items[0..12]) |n| {
            val = val * 10 + n;
        }
        p2 += val;
    }

    var stdout_buf: [40]u8 = undefined;
    var stdout_writer = std.fs.File.stdout().writer(&stdout_buf);
    const stdout = &stdout_writer.interface;

    try stdout.print("p1: {d}\np2: {d}\n", .{ p1, p2 });
    try stdout.flush();
}
