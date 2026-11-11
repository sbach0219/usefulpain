import AppKit

let output = CommandLine.arguments[1]
try FileManager.default.createDirectory(atPath: output, withIntermediateDirectories: true)

func icon(pixels: Int) -> NSBitmapImageRep {
    let size = CGFloat(pixels)
    let bitmap = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: pixels, pixelsHigh: pixels,
                                 bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true,
                                 isPlanar: false, colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: bitmap)
    let context = NSGraphicsContext.current!.cgContext
    context.scaleBy(x: size / 1024, y: size / 1024)
    let outline = NSBezierPath(roundedRect: NSRect(x: 70, y: 70, width: 884, height: 884), xRadius: 205, yRadius: 205)
    NSColor(calibratedRed: 0.055, green: 0.12, blue: 0.18, alpha: 1).setFill()
    outline.fill()
    let left = NSBezierPath(roundedRect: NSRect(x: 196, y: 250, width: 282, height: 524), xRadius: 51, yRadius: 51)
    NSColor(calibratedRed: 0.28, green: 0.85, blue: 0.74, alpha: 1).setFill()
    left.fill()
    let right = NSBezierPath(roundedRect: NSRect(x: 546, y: 250, width: 282, height: 524), xRadius: 51, yRadius: 51)
    NSColor(calibratedRed: 0.60, green: 0.66, blue: 1, alpha: 1).setFill()
    right.fill()
    for x in [CGFloat(247), CGFloat(597)] {
        for (index, width) in [CGFloat(175), CGFloat(140), CGFloat(164)].enumerated() {
            let line = NSBezierPath(roundedRect: NSRect(x: x, y: 640 - CGFloat(index) * 66, width: width, height: 20), xRadius: 10, yRadius: 10)
            NSColor.white.withAlphaComponent(0.75).setFill()
            line.fill()
        }
    }
    NSGraphicsContext.restoreGraphicsState()
    return bitmap
}

for (name, size) in [("16x16", 16), ("16x16@2x", 32), ("32x32", 32), ("32x32@2x", 64),
                     ("128x128", 128), ("128x128@2x", 256), ("256x256", 256), ("256x256@2x", 512),
                     ("512x512", 512), ("512x512@2x", 1024)] {
    let data = icon(pixels: size).representation(using: .png, properties: [:])!
    try data.write(to: URL(fileURLWithPath: output).appendingPathComponent("icon_\(name).png"))
}
