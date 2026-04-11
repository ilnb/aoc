const std = @import("std");

pub fn DSU(comptime T: type) type {
    const dsu = struct {
        const Self = @This();
        parent: []T,
        size: []T,
        aa: std.mem.Allocator,
        ncomps: usize,

        pub fn init(aa: std.mem.Allocator, n: T) !Self {
            if (n <= 0) @panic("size for DSU.init should be positive.");

            const parent = try aa.alloc(T, n);
            const size = try aa.alloc(T, n);

            for (parent, 0..) |*p, i| p.* = @intCast(i);
            for (size) |*s| s.* = 1;

            return .{ .parent = parent, .size = size, .aa = aa, .ncomps = n };
        }

        pub fn deinit(self: *Self) void {
            self.aa.free(self.parent);
            self.aa.free(self.size);
            self.ncomps = 0;
        }

        pub fn find(self: *Self, x: T) T {
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

        pub fn join(self: *Self, a: T, b: T) void {
            var ra = self.find(a);
            var rb = self.find(b);
            if (ra == rb) return;

            if (self.size[ra] < self.size[rb])
                std.mem.swap(T, &ra, &rb);

            self.parent[rb] = ra;
            self.size[ra] += self.size[rb];
            self.ncomps -= 1;
        }

        pub fn same(self: *Self, a: T, b: T) bool {
            return self.find(a) == self.find(b);
        }
    };
    return dsu;
}
