// 以 @ 开头的函数是内置函数 它们是由编译器提供的而不是标准库提供的
const std = @import("std");

test "init user info" {
    // 需要指定类型 User 否则无法推导出, 普通结构体可以使用匿名赋值
    const user: User = .{ .name = "张三", .age = 18 };
    // print 会根据传入的参数编译时生成不同的函数, 编译时生成
    std.debug.print("name: {s}, age: {d}\n", .{ user.name, user.age });

    // 调用方法也是支持两种方式 user.get_name(); 无需传入参数 user 编译器自动把 user 当作第一个参数, 而且这种写法是语法糖
    // 编译器会替换为 User.get_name(user) 都方式, 一般来说保持一种即可
    std.debug.print("get name: {s}\n", .{user.get_name()});
    // 也可以 User.get_name(user)
    std.debug.print("get name: {s}\n", .{User.get_name(user)});
}

// struct 的概念实现了类似 oop 都概念和行为, 没有隐式概念, 内部可以有方法
pub const User = struct {
    // zig 没有字符串的概念, 实际上其他语言的字符串类型低层也是 u8 的字节数组
    name: []const u8,
    age: i16,

    // * 传入指针, 值可以被修改
    // 传入副本只读
    // 两种方式小结构体基本无差异, 大结构推荐 *const User 的可读方式
    pub fn get_name(user: *User) []const u8 {
        return user.name;
    }
};

test "read arr" {
    const a = [5]i32{ 1, 2, 3, 4, 5 };
    // 打印数组需要 {any} 格式
    // {} 要求类型自己实现 format 方法, 或者在 std.fmt 里有对应的默认格式化分支, 数组类型没有这个默认分支
    //
    // {any} 主要能格式化的类型
    // 数组, 切片与结构体
    // 这是最常见的用法
    // 对于数组如 [5]i32 或切片, 它会自动遍历元素并打印出来, 格式类似 { 1, 2, 3 }
    // 对于普通的结构体, 它会直接打印出所有字段的名称和值
    //
    // 枚举与联合体
    // 对于枚举 Enum, 它会打印出该枚举值的名称 例如 .active
    // 对于联合体 Union, 它会打印出当前活跃的字段和对应的值
    //
    // 自定义类型
    // 如果你为自己的类型实现了 pub fn format(...) 方法, {any} 会自动调用它, 从而输出你想要的任何自定义格式
    //
    // 基本类型 作为兜底
    // 虽然格式化基本类型时通常推荐用 {d} 十进制, {s} 字符串等专用说明符
    // 但 {any} 也能起到兜底作用, 例如, 对于数字, 它的默认输出行为与 {d} 类似
    std.debug.print("arr: {any}\n", .{a});
}

// 悬空指针
// https://ziglang.cc/learn/coding-in-zig/
// 实战 部分
// 版本差异比较大, zig 的东西一直在更新, 请留意版本
test "show point" {
    // 测试分配器
    const allocator = std.testing.allocator;
    var lookup = std.StringHashMap(User).init(allocator);
    defer lookup.deinit();

    const user = User{
        .name = "张三",
        .age = 20,
    };

    const key = "zhangsan";
    try lookup.put(key, user);

    const entry = lookup.getPtr(key).?;

    std.debug.print("User name: {s}, age: {d}\n", .{ entry.name, entry.age });

    // 此时删除是编译不通过的, 跟例子不一定完全一致, 但道理是相通的
    //_ = lookup.remove(key);

    std.debug.print("User name: {s}, age: {d}\n", .{ entry.name, entry.age });
}
