const std = @import("std");

pub fn DSU(comptime T: type) type {
    return struct {
        const Self = @This();
        parent: []T,
        size: []T,
        alloc: std.mem.Allocator,
        ncomps: usize,

        pub fn init(alloc: std.mem.Allocator, n: T) !Self {
            if (n <= 0) @panic("size for DSU.init should be positive.");

            const parent = try alloc.alloc(T, n);
            const size = try alloc.alloc(T, n);

            for (parent, 0..) |*p, i| p.* = @intCast(i);
            for (size) |*s| s.* = 1;

            return .{ .parent = parent, .size = size, .alloc = alloc, .ncomps = n };
        }

        pub fn deinit(self: *Self) void {
            self.alloc.free(self.parent);
            self.alloc.free(self.size);
        }

        pub fn find(self: *Self, x: T) T {
            var r = x;
            while (self.parent[r] != r) {
                self.parent[r] = self.parent[self.parent[r]];
                r = self.parent[r];
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
}
