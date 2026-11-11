import AppKit

// Vector artwork: two gently curved sheets, inspired by the supplied sketch.
// Keep the reference image out of the source tree and app bundle.
guard CommandLine.arguments.count == 2 else {
    fputs("Usage: swift scripts/make-icon.swift OUTPUT.iconset\n", stderr)
    exit(1)
}
let output = URL(fileURLWithPath: CommandLine.arguments[1], isDirectory: true)
try FileManager.default.createDirectory(at: output, withIntermediateDirectories: true)

func icon(pixels: Int) -> NSBitmapImageRep {
    let bitmap = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: pixels, pixelsHigh: pixels,
                                 bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true,
                                 isPlanar: false, colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
    NSGraphicsContext.saveGraphicsState()
    defer { NSGraphicsContext.restoreGraphicsState() }
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: bitmap)
    let context = NSGraphicsContext.current!.cgContext
    context.clear(CGRect(x: 0, y: 0, width: pixels, height: pixels))
    context.scaleBy(x: CGFloat(pixels) / 1024, y: CGFloat(pixels) / 1024)
    context.translateBy(x: 0, y: 1024)
    context.scaleBy(x: 1, y: -1)

    // A plain white macOS tile keeps the black drawing legible on any wallpaper.
    NSColor.white.setFill()
    NSBezierPath(roundedRect: NSRect(x: 70, y: 70, width: 884, height: 884),
                 xRadius: 205, yRadius: 205).fill()
    NSColor.black.setStroke()
    let lineWidth = max(14, 1024 / CGFloat(pixels) * 0.85)

    func stroke(_ path: NSBezierPath) {
        path.lineWidth = lineWidth
        path.lineCapStyle = .round
        path.lineJoinStyle = .round
        path.stroke()
    }

    let left = NSBezierPath()
    left.move(to: NSPoint(x: 205, y: 235))
    left.curve(to: NSPoint(x: 469, y: 275), controlPoint1: NSPoint(x: 295, y: 245), controlPoint2: NSPoint(x: 394, y: 260))
    left.curve(to: NSPoint(x: 476, y: 768), controlPoint1: NSPoint(x: 450, y: 436), controlPoint2: NSPoint(x: 460, y: 611))
    left.curve(to: NSPoint(x: 207, y: 760), controlPoint1: NSPoint(x: 389, y: 742), controlPoint2: NSPoint(x: 293, y: 747))
    left.curve(to: NSPoint(x: 205, y: 235), controlPoint1: NSPoint(x: 180, y: 586), controlPoint2: NSPoint(x: 189, y: 389))
    left.close()
    stroke(left)

    let right = NSBezierPath()
    right.move(to: NSPoint(x: 550, y: 270))
    right.curve(to: NSPoint(x: 766, y: 255), controlPoint1: NSPoint(x: 611, y: 291), controlPoint2: NSPoint(x: 725, y: 299))
    right.curve(to: NSPoint(x: 810, y: 772), controlPoint1: NSPoint(x: 780, y: 419), controlPoint2: NSPoint(x: 790, y: 608))
    right.curve(to: NSPoint(x: 553, y: 781), controlPoint1: NSPoint(x: 724, y: 741), controlPoint2: NSPoint(x: 629, y: 747))
    right.curve(to: NSPoint(x: 550, y: 270), controlPoint1: NSPoint(x: 539, y: 611), controlPoint2: NSPoint(x: 538, y: 427))
    right.close()
    stroke(right)

    // Fewer, heavier lines at Finder's smallest sizes avoid a muddy thumbnail.
    let rows: [CGFloat] = pixels <= 32 ? [430, 625] : [355, 460, 565, 670]
    for (index, y) in rows.enumerated() {
        let leftWave = NSBezierPath()
        leftWave.move(to: NSPoint(x: 248, y: y + 18))
        leftWave.curve(to: NSPoint(x: 327, y: y - 12),
                       controlPoint1: NSPoint(x: 278, y: y - 27), controlPoint2: NSPoint(x: 302, y: y - 36))
        leftWave.curve(to: NSPoint(x: 414, y: y + 18),
                       controlPoint1: NSPoint(x: 360, y: y + 43), controlPoint2: NSPoint(x: 390, y: y + 45))
        stroke(leftWave)

        let rightWave = NSBezierPath()
        let offset: CGFloat = index.isMultiple(of: 2) ? 4 : 12
        rightWave.move(to: NSPoint(x: 590 + offset, y: y + 26))
        rightWave.curve(to: NSPoint(x: 652 + offset, y: y - 8),
                        controlPoint1: NSPoint(x: 617 + offset, y: y - 21), controlPoint2: NSPoint(x: 628 + offset, y: y - 45))
        rightWave.curve(to: NSPoint(x: 731 + offset, y: y + 17),
                        controlPoint1: NSPoint(x: 691 + offset, y: y + 47), controlPoint2: NSPoint(x: 705 + offset, y: y + 48))
        stroke(rightWave)
    }
    return bitmap
}

for (name, size) in [("16x16", 16), ("16x16@2x", 32), ("32x32", 32), ("32x32@2x", 64),
                     ("128x128", 128), ("128x128@2x", 256), ("256x256", 256), ("256x256@2x", 512),
                     ("512x512", 512), ("512x512@2x", 1024)] {
    let data = icon(pixels: size).representation(using: .png, properties: [:])!
    try data.write(to: output.appendingPathComponent("icon_\(name).png"))
}
