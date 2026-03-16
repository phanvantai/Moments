import CoreGraphics
import Foundation
import ImageIO
import UniformTypeIdentifiers

let size = 1024
let width = size
let height = size

let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)!
let context = CGContext(
    data: nil,
    width: width,
    height: height,
    bitsPerComponent: 8,
    bytesPerRow: 0,
    space: colorSpace,
    bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
)!

let w = CGFloat(width)
let h = CGFloat(height)

// === Background is the "content" itself — warm white/cream ===
context.setFillColor(red: 1.0, green: 0.99, blue: 0.97, alpha: 1.0)
context.fill(CGRect(x: 0, y: 0, width: w, height: h))

// === Content lines in the center area ===
let lineStartX: CGFloat = 160
let lineHeight: CGFloat = 20
let lineGap: CGFloat = 50
let lineColor = CGColor(srgbRed: 0.88, green: 0.85, blue: 0.82, alpha: 1.0)

context.setFillColor(lineColor)

let centerY = h / 2

// Line 1
let line1Y = centerY + 40
let line1Path = CGMutablePath()
line1Path.addRoundedRect(in: CGRect(x: lineStartX, y: line1Y, width: 500, height: lineHeight),
                         cornerWidth: 10, cornerHeight: 10)
context.addPath(line1Path)
context.fillPath()

// Line 2
let line2Y = line1Y - lineGap
let line2Path = CGMutablePath()
line2Path.addRoundedRect(in: CGRect(x: lineStartX, y: line2Y, width: 380, height: lineHeight),
                         cornerWidth: 10, cornerHeight: 10)
context.addPath(line2Path)
context.fillPath()

// Line 3
let line3Y = line2Y - lineGap
let line3Path = CGMutablePath()
line3Path.addRoundedRect(in: CGRect(x: lineStartX, y: line3Y, width: 440, height: lineHeight),
                         cornerWidth: 10, cornerHeight: 10)
context.addPath(line3Path)
context.fillPath()

// Line 4
let line4Y = line3Y - lineGap
let line4Path = CGMutablePath()
line4Path.addRoundedRect(in: CGRect(x: lineStartX, y: line4Y, width: 300, height: lineHeight),
                         cornerWidth: 10, cornerHeight: 10)
context.addPath(line4Path)
context.fillPath()

// === Bookmark ribbon at top-right corner ===
let ribbonWidth: CGFloat = 140
let ribbonHeight: CGFloat = 340
let ribbonX = w - ribbonWidth - 150  // near right edge
let ribbonTop = h  // flush with top edge of icon
let ribbonBottom = ribbonTop - ribbonHeight
let notchDepth: CGFloat = 55

// Ribbon shadow
context.saveGState()
context.setShadow(offset: CGSize(width: 0, height: -6), blur: 16,
                  color: CGColor(srgbRed: 0.0, green: 0.0, blue: 0.0, alpha: 0.12))

// Coral ribbon
context.setFillColor(red: 0.96, green: 0.52, blue: 0.39, alpha: 1.0)

let ribbonPath = CGMutablePath()
ribbonPath.move(to: CGPoint(x: ribbonX, y: ribbonTop))
ribbonPath.addLine(to: CGPoint(x: ribbonX + ribbonWidth, y: ribbonTop))
ribbonPath.addLine(to: CGPoint(x: ribbonX + ribbonWidth, y: ribbonBottom))
ribbonPath.addLine(to: CGPoint(x: ribbonX + ribbonWidth / 2, y: ribbonBottom + notchDepth))
ribbonPath.addLine(to: CGPoint(x: ribbonX, y: ribbonBottom))
ribbonPath.closeSubpath()

context.addPath(ribbonPath)
context.fillPath()
context.restoreGState()

// White dot on ribbon
let dotRadius: CGFloat = 18
let dotCenterX = ribbonX + ribbonWidth / 2
let dotCenterY = ribbonTop - 80

context.setFillColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.9)
context.fillEllipse(in: CGRect(
    x: dotCenterX - dotRadius,
    y: dotCenterY - dotRadius,
    width: dotRadius * 2,
    height: dotRadius * 2
))

// Generate image
let cgImage = context.makeImage()!

let outputPath = "\(CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "icon_1024.png")"
let url = URL(fileURLWithPath: outputPath)
let dest = CGImageDestinationCreateWithURL(url as CFURL, UTType.png.identifier as CFString, 1, nil)!
CGImageDestinationAddImage(dest, cgImage, nil)

if CGImageDestinationFinalize(dest) {
    print("Icon saved to: \(outputPath)")
} else {
    print("Failed to save icon")
}
