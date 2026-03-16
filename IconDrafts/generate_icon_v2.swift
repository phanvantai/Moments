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

// Background: warm coral (BrandColors.accent)
context.setFillColor(red: 0.96, green: 0.52, blue: 0.39, alpha: 1.0)
context.fill(CGRect(x: 0, y: 0, width: w, height: h))

// Subtle gradient overlay: slightly darker at bottom
let gradientColors = [
    CGColor(srgbRed: 0.91, green: 0.38, blue: 0.35, alpha: 0.0),
    CGColor(srgbRed: 0.91, green: 0.38, blue: 0.35, alpha: 0.35)
]
let gradient = CGGradient(
    colorsSpace: colorSpace,
    colors: gradientColors as CFArray,
    locations: [0.0, 1.0]
)!
context.drawLinearGradient(
    gradient,
    start: CGPoint(x: w / 2, y: h),
    end: CGPoint(x: w / 2, y: 0),
    options: []
)

// Bookmark ribbon shape - centered, white
let ribbonWidth: CGFloat = 440
let ribbonHeight: CGFloat = 650
let ribbonX = (w - ribbonWidth) / 2
let ribbonY = (h - ribbonHeight) / 2 + 30  // slightly higher visually
let notchDepth: CGFloat = 115  // the V-cut at the bottom

// Corner radius for top of bookmark
let cornerRadius: CGFloat = 50

context.setFillColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.95)

let path = CGMutablePath()

let top = ribbonY + ribbonHeight
let bottom = ribbonY
let left = ribbonX
let right = ribbonX + ribbonWidth

// Top-left corner
path.move(to: CGPoint(x: left, y: top - cornerRadius))
path.addArc(
    tangent1End: CGPoint(x: left, y: top),
    tangent2End: CGPoint(x: left + cornerRadius, y: top),
    radius: cornerRadius
)

// Top-right corner
path.addLine(to: CGPoint(x: right - cornerRadius, y: top))
path.addArc(
    tangent1End: CGPoint(x: right, y: top),
    tangent2End: CGPoint(x: right, y: top - cornerRadius),
    radius: cornerRadius
)

// Right side down
path.addLine(to: CGPoint(x: right, y: bottom))

// V-notch at bottom center
path.addLine(to: CGPoint(x: left + ribbonWidth / 2, y: bottom + notchDepth))
path.addLine(to: CGPoint(x: left, y: bottom))

// Close back to start
path.closeSubpath()

context.addPath(path)
context.fillPath()

// Small circle accent near top of bookmark (like a "little mark" dot)
let dotRadius: CGFloat = 40
let dotCenterX = w / 2
let dotCenterY = top - 185

context.setFillColor(red: 0.96, green: 0.52, blue: 0.39, alpha: 1.0)
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
