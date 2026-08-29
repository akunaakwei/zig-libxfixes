const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const linkage = b.option(std.builtin.LinkMode, "linkage", "Linkage type for the library") orelse .static;

    const xfixes_dep = b.dependency("xfixes", .{});
    const x11_dep = b.dependency("x11", .{
        .target = target,
        .optimize = optimize,
        .linkage = linkage,
    });
    const x11 = x11_dep.artifact("x11");
    const xorgproto_dep = b.dependency("xorgproto", .{
        .target = target,
        .optimize = optimize,
    });
    const xorgproto = xorgproto_dep.artifact("xorgproto");

    const mod = b.createModule(.{
        .target = target,
        .optimize = optimize,
        .link_libc = true,
        .pic = if (linkage == .dynamic) true else null,
    });
    mod.linkLibrary(x11);
    mod.linkLibrary(xorgproto);
    mod.addIncludePath(xfixes_dep.path("include/X11/extensions"));
    mod.addCSourceFiles(.{
        .root = xfixes_dep.path("src"),
        .files = &sources,
    });

    const lib = b.addLibrary(.{
        .name = "xfixes",
        .root_module = mod,
        .linkage = linkage,
    });
    lib.installHeadersDirectory(xfixes_dep.path("include"), ".", .{});
    b.installArtifact(lib);
}

const sources = .{
    "Cursor.c",
    "Disconnect.c",
    "Region.c",
    "SaveSet.c",
    "Selection.c",
    "Xfixes.c",
};
