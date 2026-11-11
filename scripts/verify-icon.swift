import AppKit

// Keep generated icons monochrome, correctly sized, and free of an opaque square.
guard CommandLine.arguments.count == 2 else {
    fputs("Usage: swift scripts/verify-icon.swift INPUT.iconset\n", stderr)
    exit(1)
}
let directory = URL(fileURLWithPath: CommandLine.arguments[1], isDirectory: true)
let sizes = [("16x16", 16), ("16x16@2x", 32), ("32x32", 32), ("32x32@2x", 64),
             ("128x128", 128), ("128x128@2x", 256), ("256x256", 256), ("256x256@2x", 512),
             ("512x512", 512), ("512x512@2x", 1024)]
func require(_ condition: Bool, _ message: String) {
    if !condition {
        fputs("Icon validation failed: \(message)\n", stderr)
        exit(1)
    }
}
for (name, size) in sizes {
    let url = directory.appendingPathComponent("icon_\(name).png")
    guard let bitmap = NSBitmapImageRep(data: try Data(contentsOf: url)) else {
        fputs("Cannot decode \(url.lastPathComponent)\n", stderr)
        exit(1)
    }
    require(bitmap.pixelsWide == size && bitmap.pixelsHigh == size, "\(name): dimensions")
    require(bitmap.hasAlpha, "\(name): missing transparency")
    var darkPixels = 0
    var whitePixels = 0
    for y in 0..<size {
        for x in 0..<size {
            guard let color = bitmap.colorAt(x: x, y: y)?.usingColorSpace(.deviceRGB) else {
                fatalError("Cannot inspect icon pixel")
            }
            require(abs(color.redComponent - color.greenComponent) < 0.005 &&
                    abs(color.greenComponent - color.blueComponent) < 0.005, "\(name): colored pixel")
            if color.alphaComponent > 0.99 {
                if color.redComponent < 0.4 { darkPixels += 1 }
                if color.redComponent > 0.99 { whitePixels += 1 }
            }
        }
    }
    for (x, y) in [(0, 0), (size - 1, 0), (0, size - 1), (size - 1, size - 1)] {
        require(bitmap.colorAt(x: x, y: y)!.alphaComponent == 0, "\(name): opaque corner")
    }
    require(darkPixels > 0 && whitePixels > 0, "\(name): missing artwork or white background")
}
print("Verified \(sizes.count) monochrome icon sizes (16–1024 px).")
