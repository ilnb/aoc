const std = @import("std");

pub const DSU = struct {
    const Self = @This();
    parent: []usize,
    size: []usize,
    aa: std.mem.Allocator,
    ncomps: usize,

    pub fn init(aa: std.mem.Allocator, n: usize) !Self {
        const parent = try aa.alloc(usize, n);
        const size = try aa.alloc(usize, n);

        for (parent, 0..) |*p, i| p.* = i;
        @memset(size, 1);

        return .{ .parent = parent, .size = size, .aa = aa, .ncomps = n };
    }

    pub fn deinit(self: *Self) void {
        self.aa.free(self.parent);
        self.aa.free(self.size);
        self.ncomps = 0;
    }

    pub fn find(self: *Self, x: usize) usize {
        var r = x;
        while (self.parent[r] != r) {
            self.parent[r] = self.parent[self.parent[r]];
            r = self.parent[r];
        }
        var t = x;
        while (t != r) {
            const next = self.parent[t];
            self.parent[t] = r;
            t = next;
        }
        return r;
    }

    pub fn join(self: *Self, a: usize, b: usize) void {
        var ra = self.find(a);
        var rb = self.find(b);
        if (ra == rb) return;

        if (self.size[ra] < self.size[rb])
            std.mem.swap(usize, &ra, &rb);

        self.parent[rb] = ra;
        self.size[ra] += self.size[rb];
        self.ncomps -= 1;
    }

    pub fn same(self: *Self, a: usize, b: usize) bool {
        return self.find(a) == self.find(b);
    }
};
