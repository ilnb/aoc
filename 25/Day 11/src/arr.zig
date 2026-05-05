const std = @import("std");
const AL = std.ArrayList;
const Queue = @import("queue").Queue;

const Bit = packed struct { s: u12, e: u12, d: u12, f: u12 };

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

    var node_map = std.StringHashMap(u12).init(ga);
    defer {
        var itr = node_map.keyIterator();
        while (itr.next()) |key| ga.free(key.*);
        node_map.deinit();
    }

    var graph = AL(AL(u12)).empty;
    try graph.appendNTimes(ga, AL(u12).empty, 10);
    defer {
        for (graph.items) |*l| l.deinit(ga);
        graph.deinit(ga);
    }

    var idx: u12 = 0;
    while (try reader.takeDelimiter('\n')) |l| {
        var itr = std.mem.tokenizeAny(u8, l, ": ");
        const p = itr.next().?;
        if (node_map.get(p) == null) {
            try node_map.put(try ga.dupe(u8, p), idx);
            idx += 1;
            if (idx == graph.items.len + 1) {
                try graph.append(ga, AL(u12).empty);
            }
        }

        const pidx = node_map.get(p).?;

        while (itr.next()) |node| {
            if (node_map.get(node) == null) {
                try node_map.put(try ga.dupe(u8, node), idx);
                idx += 1;
                if (idx == graph.items.len + 1) {
                    try graph.append(ga, AL(u12).empty);
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
    const bit = Bit{ .s = s, .e = e, .d = d, .f = f };
    const p2 = try surfIt(ga, &graph, bit);

    var std_w = std.Io.File.stdout().writer(io, &.{});
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

fn surfIt(ga: std.mem.Allocator, graph: *AL(AL(u12)), bit: Bit) !u64 {
    const s, const e, const d, const f = .{ bit.s, bit.e, bit.d, bit.f };

    var topo = try topoSort(ga, graph);
    defer topo.deinit(ga);

    const n = graph.items.len + 1;
    var dp = try AL([4]u64).initCapacity(ga, n);
    defer dp.deinit(ga);

    try dp.appendNTimes(ga, [4]u64{ 0, 0, 0, 0 }, n);
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
    try indeg.appendNTimes(ga, 0, n);

    for (graph.items) |u| {
        for (u.items) |v| indeg.items[v] += 1;
    }

    var q = Queue(u12).init(ga);
    defer q.deinit();
    for (indeg.items, 0..) |d, i| {
        if (d == 0) try q.push(@intCast(i));
    }

    var ret = try AL(u12).initCapacity(ga, n); // free in surfIt

    while (q.pop()) |u| {
        try ret.append(ga, u);
        if (u == graph.items.len) continue;

        for (graph.items[u].items) |v| {
            indeg.items[v] -= 1;
            if (indeg.items[v] == 0) try q.push(@intCast(v));
        }
    }

    return ret;
}
