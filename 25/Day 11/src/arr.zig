const std = @import("std");
const AL = std.ArrayList;

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

    var node_map = std.StringHashMap(u12).init(ga);
    defer {
        var itr = node_map.keyIterator();
        while (itr.next()) |key| ga.free(key.*);
        node_map.deinit();
    }

    var graph = try AL(AL(u12)).initCapacity(ga, 10);
    for (0..10) |_| try graph.append(ga, AL(u12).empty);
    defer {
        for (graph.items) |*l| l.deinit(ga);
        graph.deinit(ga);
    }

    var idx: u12 = 0;
    while (true) {
        const _l = try reader.takeDelimiter('\n');
        if (_l == null) break;

        var itr = std.mem.tokenizeAny(u8, _l.?, ": ");
        const p = itr.next().?;
        if (node_map.get(p) == null) {
            try node_map.put(try ga.dupe(u8, p), idx);
            idx += 1;
            if (idx == graph.items.len + 1) {
                try graph.append(ga, try AL(u12).initCapacity(ga, 10));
            }
        }

        const pidx = node_map.get(p).?;

        while (itr.next()) |node| {
            if (node_map.get(node) == null) {
                try node_map.put(try ga.dupe(u8, node), idx);
                idx += 1;
                if (idx == graph.items.len + 1) {
                    try graph.append(ga, try AL(u12).initCapacity(ga, 10));
                }
            }
            const nidx = node_map.get(node).?;
            try graph.items[pidx].append(ga, nidx);
        }
    }

    const e = node_map.get("out").?;
    const p1 = getOut(node_map.get("you").?, e, &graph);

    const s = node_map.get("svr").?;
    const d = node_map.get("dac").?;
    const f = node_map.get("fft").?;
    var bits: u64 = 0;
    bits |= s;
    bits |= @as(u64, e) << 12;
    bits |= @as(u64, d) << 24;
    bits |= @as(u64, f) << 36;
    const p2 = try surfIt(ga, &graph, bits);

    var std_w = std.fs.File.stdout().writer(&.{});
    var stdout = &std_w.interface;

    try stdout.print("p1: {d}\np2: {d}\n", .{ p1, p2 });
    try stdout.flush();
}

fn getOut(u: u12, e: u12, graph: *AL(AL(u12))) u32 {
    if (u == e) return 1;

    var ret: u32 = 0;
    for (graph.items[u].items) |v| {
        ret += getOut(v, e, graph);
    }
    return ret;
}

fn surfIt(ga: std.mem.Allocator, graph: *AL(AL(u12)), bits: u64) !u64 {
    const clr: u12 = 0xFFF;
    const s: u12 = @intCast(bits & clr);
    const e: u12 = @intCast((bits >> 12) & clr);
    const d: u12 = @intCast((bits >> 24) & clr);
    const f: u12 = @intCast((bits >> 36) & clr);

    var topo = try topoSort(ga, graph);
    defer topo.deinit(ga);

    const n = graph.items.len + 1;
    var dp = try AL([4]u64).initCapacity(ga, n);
    defer dp.deinit(ga);

    for (0..n) |_| try dp.append(ga, [4]u64{ 0, 0, 0, 0 });
    dp.items[s][0] = 1;

    for (topo.items) |u| {
        if (u == graph.items.len) continue;
        for (graph.items[u].items) |v| {
            for (0..4) |mask| {
                var nm = mask;
                if (v == d) nm |= 0b10;
                if (v == f) nm |= 0b01;
                dp.items[v][nm] += dp.items[u][mask];
            }
        }
    }

    return dp.items[e][0b11];
}

fn topoSort(ga: std.mem.Allocator, graph: *AL(AL(u12))) !AL(u12) {
    const n = graph.items.len + 1;

    var indeg = try AL(u12).initCapacity(ga, n);
    defer indeg.deinit(ga);
    for (0..n) |_| try indeg.append(ga, 0);

    for (graph.items) |u| {
        for (u.items) |v| indeg.items[v] += 1;
    }

    var q = try AL(u12).initCapacity(ga, 5);
    defer q.deinit(ga);
    for (indeg.items, 0..) |d, i| {
        if (d == 0) try q.append(ga, @intCast(i));
    }

    var ret = try AL(u12).initCapacity(ga, n); // free in surfIt

    var h: usize = 0;
    while (h < q.items.len) {
        const u = q.items[h];
        h += 1;
        try ret.append(ga, u);
        if (u == graph.items.len) continue;

        for (graph.items[u].items) |v| {
            indeg.items[v] -= 1;
            if (indeg.items[v] == 0) try q.append(ga, v);
        }
    }

    return ret;
}
