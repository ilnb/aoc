const std = @import("std");
const DLL = std.DoublyLinkedList;

pub fn Queue(comptime T: type) type {
    const Data = struct {
        val: T,
        node: DLL.Node = undefined,
    };

    const Unmanaged = struct {
        list: DLL = DLL{},
        aa: std.mem.Allocator,
        len: usize = 0,

        const Self = @This();

        pub fn init(ga: std.mem.Allocator) Self {
            return Self{ .aa = ga };
        }

        pub fn push(self: *Self, val: T) !void {
            const new_node = try self.aa.create(Data);
            new_node.val = val;
            self.list.append(&new_node.node);
            self.len += 1;
        }

        pub fn pop(self: *Self) ?T {
            const head = self.list.popFirst();
            if (head == null) return null;
            const ptr: *Data = @fieldParentPtr("node", head.?);
            const ret = ptr.val;
            self.aa.destroy(ptr);
            self.len -= 1;
            return ret;
        }

        pub fn empty(self: *Self) bool {
            return self.len == 0;
        }

        pub fn deinit(self: *Self) void {
            while (self.list.popFirst()) |head| {
                const ptr: *Data = @fieldParentPtr("node", head);
                self.aa.destroy(ptr);
            }
        }
    };

    return Unmanaged;
}
