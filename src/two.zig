const std = @import("std");

// 将字符串输出到文件中
test "output str to file" {
    var buf: [4096]u8 = undefined;
    // .init() 在 main 和 test 中都可以调用, 但关键在于传入的 io 实例和输出目标不同
    // 新 API 要求使用 .init(file, io, &buffer) 或 .initStreaming(...) 来创建 std.Io.File.Writer
    var file_writer: std.Io.File.Writer = .init(.stdout(), std.testing.io, &buf);
    const output = &file_writer.interface;

    // 在 Zig 的 test 块中, stdout 通常被测试运行器占用, 直接写入可能会失败或产生意外行为
    // 如果目的是验证字符串输出, 更合适的做法是写入一个内存 Writer 或临时文件, 然后断言其内容
    try output.print("This is a String\n", .{});
    try output.flush();
}
