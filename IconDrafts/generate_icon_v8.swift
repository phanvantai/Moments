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

// === Background: aged paper ===
context.setFillColor(red: 0.96, green: 0.93, blue: 0.88, alpha: 1.0)
context.fill(CGRect(x: 0, y: 0, width: w, height: h))

let paperGradientColors = [
    CGColor(srgbRed: 0.94, green: 0.90, blue: 0.84, alpha: 0.0),
    CGColor(srgbRed: 0.92, green: 0.88, blue: 0.82, alpha: 0.3)
]
let paperGradient = CGGradient(
    colorsSpace: colorSpace,
    colors: paperGradientColors as CFArray,
    locations: [0.0, 1.0]
)!
context.drawLinearGradient(
    paperGradient,
    start: CGPoint(x: 0, y: h),
    end: CGPoint(x: w, y: 0),
    options: []
)

// === Calculate content block to center vertically ===
let imgHeight: CGFloat = 320
let waveHeight: CGFloat = 110
let gapBetween: CGFloat = 40
let totalContentHeight = imgHeight + gapBetween + waveHeight
let contentTopY = (h + totalContentHeight) / 2  // top edge in CG coords (y up)
let contentLeftX: CGFloat = 80
let lineHeight: CGFloat = 26
let lineColor = CGColor(srgbRed: 0.82, green: 0.78, blue: 0.73, alpha: 1.0)

// --- Row 1: Image placeholder (centered) ---
let imgWidth: CGFloat = 380
let imgY = contentTopY - imgHeight
let imgRadius: CGFloat = 28

context.setFillColor(red: 0.90, green: 0.86, blue: 0.81, alpha: 1.0)
let imgPath = CGMutablePath()
imgPath.addRoundedRect(in: CGRect(x: contentLeftX, y: imgY, width: imgWidth, height: imgHeight),
                       cornerWidth: imgRadius, cornerHeight: imgRadius)
context.addPath(imgPath)
context.fillPath()

// Mountain 1
context.setFillColor(red: 0.82, green: 0.78, blue: 0.73, alpha: 1.0)
let mt1CenterX = contentLeftX + imgWidth / 2 + 35
let mt1BaseY = imgY + 55
let mt1Path = CGMutablePath()
mt1Path.move(to: CGPoint(x: mt1CenterX - 105, y: mt1BaseY))
mt1Path.addLine(to: CGPoint(x: mt1CenterX, y: mt1BaseY + 130))
mt1Path.addLine(to: CGPoint(x: mt1CenterX + 105, y: mt1BaseY))
mt1Path.closeSubpath()
context.addPath(mt1Path)
context.fillPath()

// Mountain 2
let mt2CenterX = contentLeftX + imgWidth / 2 - 50
let mt2BaseY = imgY + 55
let mt2Path = CGMutablePath()
mt2Path.move(to: CGPoint(x: mt2CenterX - 65, y: mt2BaseY))
mt2Path.addLine(to: CGPoint(x: mt2CenterX, y: mt2BaseY + 90))
mt2Path.addLine(to: CGPoint(x: mt2CenterX + 65, y: mt2BaseY))
mt2Path.closeSubpath()
context.addPath(mt2Path)
context.fillPath()

// Sun
let sunR: CGFloat = 26
context.fillEllipse(in: CGRect(
    x: contentLeftX + 65, y: imgY + imgHeight - 100,
    width: sunR * 2, height: sunR * 2
))

// Text lines next to image
context.setFillColor(lineColor)
let textNextX = contentLeftX + imgWidth + 40

let tnLine1 = CGMutablePath()
tnLine1.addRoundedRect(in: CGRect(x: textNextX, y: imgY + imgHeight - 55, width: 280, height: lineHeight),
                       cornerWidth: 13, cornerHeight: 13)
context.addPath(tnLine1)
context.fillPath()

let tnLine2 = CGMutablePath()
tnLine2.addRoundedRect(in: CGRect(x: textNextX, y: imgY + imgHeight - 105, width: 210, height: lineHeight),
                       cornerWidth: 13, cornerHeight: 13)
context.addPath(tnLine2)
context.fillPath()

let tnLine3 = CGMutablePath()
tnLine3.addRoundedRect(in: CGRect(x: textNextX, y: imgY + imgHeight - 155, width: 250, height: lineHeight),
                       cornerWidth: 13, cornerHeight: 13)
context.addPath(tnLine3)
context.fillPath()

let tnLine4 = CGMutablePath()
tnLine4.addRoundedRect(in: CGRect(x: textNextX, y: imgY + imgHeight - 205, width: 180, height: lineHeight),
                       cornerWidth: 13, cornerHeight: 13)
context.addPath(tnLine4)
context.fillPath()

// --- Row 2: Voice note waveform (right below image, centered) ---
let waveY = imgY - gapBetween - waveHeight
let waveStartX = contentLeftX
let waveWidth: CGFloat = 700
let waveRadius: CGFloat = 24

context.setFillColor(red: 0.90, green: 0.86, blue: 0.81, alpha: 0.7)
let waveBgPath = CGMutablePath()
waveBgPath.addRoundedRect(in: CGRect(x: waveStartX, y: waveY, width: waveWidth, height: waveHeight),
                          cornerWidth: waveRadius, cornerHeight: waveRadius)
context.addPath(waveBgPath)
context.fillPath()

// Play button
let playR: CGFloat = 32
let playCX = waveStartX + 55
let playCY = waveY + waveHeight / 2
context.setFillColor(red: 0.96, green: 0.52, blue: 0.39, alpha: 0.8)
context.fillEllipse(in: CGRect(
    x: playCX - playR, y: playCY - playR,
    width: playR * 2, height: playR * 2
))

// Play triangle
context.setFillColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.9)
let playTriPath = CGMutablePath()
playTriPath.move(to: CGPoint(x: playCX - 10, y: playCY - 18))
playTriPath.addLine(to: CGPoint(x: playCX + 18, y: playCY))
playTriPath.addLine(to: CGPoint(x: playCX - 10, y: playCY + 18))
playTriPath.closeSubpath()
context.addPath(playTriPath)
context.fillPath()

// Waveform bars
context.setFillColor(red: 0.96, green: 0.52, blue: 0.39, alpha: 0.5)
let barWidth: CGFloat = 7
let barGap: CGFloat = 9
let barStartX = playCX + playR + 30
let barHeights: [CGFloat] = [18, 40, 28, 55, 22, 45, 32, 58, 24, 42, 30, 50, 18, 36, 48, 26, 52, 38, 20, 44, 32, 18, 42, 24, 36, 48, 28, 40, 20, 30, 50, 18, 32, 42, 24, 52, 36, 20, 44]

for (i, bh) in barHeights.enumerated() {
    let bx = barStartX + CGFloat(i) * (barWidth + barGap)
    if bx + barWidth > waveStartX + waveWidth - 25 { break }
    let by = playCY - bh / 2
    let barPath = CGMutablePath()
    barPath.addRoundedRect(in: CGRect(x: bx, y: by, width: barWidth, height: bh),
                           cornerWidth: 3.5, cornerHeight: 3.5)
    context.addPath(barPath)
    context.fillPath()
}

// === Bookmark ribbon — top right ===
let ribbonWidth: CGFloat = 220
let ribbonHeight: CGFloat = h / 2
let ribbonX = w - ribbonWidth - 80
let ribbonTop = h
let ribbonBottom = ribbonTop - ribbonHeight
let notchDepth: CGFloat = 80

context.saveGState()
context.setShadow(offset: CGSize(width: -3, height: -6), blur: 20,
                  color: CGColor(srgbRed: 0.0, green: 0.0, blue: 0.0, alpha: 0.15))

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

// Dot on ribbon
let dotRadius: CGFloat = 24
let dotCenterX = ribbonX + ribbonWidth / 2
let dotCenterY = ribbonTop - 100

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
