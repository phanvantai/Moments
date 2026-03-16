import CoreGraphics
import Foundation
import ImageIO
import UniformTypeIdentifiers

let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)!

func makeContext(w: Int, h: Int) -> CGContext {
    CGContext(
        data: nil, width: w, height: h,
        bitsPerComponent: 8, bytesPerRow: 0,
        space: colorSpace,
        bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
    )!
}

func save(_ ctx: CGContext, to filename: String) {
    let cgImage = ctx.makeImage()!
    let url = URL(fileURLWithPath: filename)
    let dest = CGImageDestinationCreateWithURL(url as CFURL, UTType.png.identifier as CFString, 1, nil)!
    CGImageDestinationAddImage(dest, cgImage, nil)
    if CGImageDestinationFinalize(dest) {
        print("Saved: \(filename)")
    }
}

// ============================================================
// 1. Background — aged paper (1024x1024, full icon)
// ============================================================
do {
    let s = 1024
    let ctx = makeContext(w: s, h: s)
    let w = CGFloat(s)
    let h = CGFloat(s)

    ctx.setFillColor(red: 0.96, green: 0.93, blue: 0.88, alpha: 1.0)
    ctx.fill(CGRect(x: 0, y: 0, width: w, height: h))

    let colors = [
        CGColor(srgbRed: 0.94, green: 0.90, blue: 0.84, alpha: 0.0),
        CGColor(srgbRed: 0.92, green: 0.88, blue: 0.82, alpha: 0.3)
    ]
    let gradient = CGGradient(colorsSpace: colorSpace, colors: colors as CFArray, locations: [0.0, 1.0])!
    ctx.drawLinearGradient(gradient, start: CGPoint(x: 0, y: h), end: CGPoint(x: w, y: 0), options: [])
    save(ctx, to: "component_background.png")
}

// ============================================================
// 2. Image placeholder (landscape with mountains + sun)
// ============================================================
do {
    let cw = 380
    let ch = 320
    let ctx = makeContext(w: cw, h: ch)
    let w = CGFloat(cw)
    let h = CGFloat(ch)
    let r: CGFloat = 28

    // Card background
    ctx.setFillColor(red: 0.90, green: 0.86, blue: 0.81, alpha: 1.0)
    let bg = CGMutablePath()
    bg.addRoundedRect(in: CGRect(x: 0, y: 0, width: w, height: h), cornerWidth: r, cornerHeight: r)
    ctx.addPath(bg)
    ctx.fillPath()

    // Mountain 1
    ctx.setFillColor(red: 0.82, green: 0.78, blue: 0.73, alpha: 1.0)
    let mt1CX = w / 2 + 35
    let mt1BY: CGFloat = 55
    let mt1 = CGMutablePath()
    mt1.move(to: CGPoint(x: mt1CX - 105, y: mt1BY))
    mt1.addLine(to: CGPoint(x: mt1CX, y: mt1BY + 130))
    mt1.addLine(to: CGPoint(x: mt1CX + 105, y: mt1BY))
    mt1.closeSubpath()
    ctx.addPath(mt1)
    ctx.fillPath()

    // Mountain 2
    let mt2CX = w / 2 - 50
    let mt2 = CGMutablePath()
    mt2.move(to: CGPoint(x: mt2CX - 65, y: mt1BY))
    mt2.addLine(to: CGPoint(x: mt2CX, y: mt1BY + 90))
    mt2.addLine(to: CGPoint(x: mt2CX + 65, y: mt1BY))
    mt2.closeSubpath()
    ctx.addPath(mt2)
    ctx.fillPath()

    // Sun
    let sunR: CGFloat = 26
    ctx.fillEllipse(in: CGRect(x: 65, y: h - 100, width: sunR * 2, height: sunR * 2))

    save(ctx, to: "component_image.png")
}

// ============================================================
// 3. Text lines
// ============================================================
do {
    let cw = 280
    let ch = 200
    let ctx = makeContext(w: cw, h: ch)
    let lineHeight: CGFloat = 26

    ctx.setFillColor(red: 0.82, green: 0.78, blue: 0.73, alpha: 1.0)

    let lines: [(CGFloat, CGFloat)] = [
        (CGFloat(ch) - 30, 280),
        (CGFloat(ch) - 80, 210),
        (CGFloat(ch) - 130, 250),
        (CGFloat(ch) - 180, 180),
    ]
    for (ly, lw) in lines {
        let p = CGMutablePath()
        p.addRoundedRect(in: CGRect(x: 0, y: ly, width: lw, height: lineHeight),
                         cornerWidth: 13, cornerHeight: 13)
        ctx.addPath(p)
        ctx.fillPath()
    }

    save(ctx, to: "component_textlines.png")
}

// ============================================================
// 4. Voice waveform (taller, narrower)
// ============================================================
do {
    let cw = 500
    let ch = 140
    let ctx = makeContext(w: cw, h: ch)
    let w = CGFloat(cw)
    let h = CGFloat(ch)
    let r: CGFloat = 28

    // Background bar
    ctx.setFillColor(red: 0.90, green: 0.86, blue: 0.81, alpha: 0.7)
    let waveBg = CGMutablePath()
    waveBg.addRoundedRect(in: CGRect(x: 0, y: 0, width: w, height: h), cornerWidth: r, cornerHeight: r)
    ctx.addPath(waveBg)
    ctx.fillPath()

    // Play button
    let playR: CGFloat = 38
    let playCX: CGFloat = 50
    let playCY = h / 2
    ctx.setFillColor(red: 0.96, green: 0.52, blue: 0.39, alpha: 0.8)
    ctx.fillEllipse(in: CGRect(x: playCX - playR, y: playCY - playR, width: playR * 2, height: playR * 2))

    // Play triangle
    ctx.setFillColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.9)
    let tri = CGMutablePath()
    tri.move(to: CGPoint(x: playCX - 12, y: playCY - 20))
    tri.addLine(to: CGPoint(x: playCX + 20, y: playCY))
    tri.addLine(to: CGPoint(x: playCX - 12, y: playCY + 20))
    tri.closeSubpath()
    ctx.addPath(tri)
    ctx.fillPath()

    // Waveform bars (taller)
    ctx.setFillColor(red: 0.96, green: 0.52, blue: 0.39, alpha: 0.5)
    let barW: CGFloat = 7
    let barG: CGFloat = 9
    let barSX = playCX + playR + 25
    let barH: [CGFloat] = [22, 50, 34, 70, 26, 55, 40, 74, 30, 52, 36, 62, 22, 44, 60, 32, 66, 46, 24, 54, 38, 22, 52, 30, 44, 60, 34, 50, 24, 36, 62, 22, 38, 52, 28]

    for (i, bh) in barH.enumerated() {
        let bx = barSX + CGFloat(i) * (barW + barG)
        if bx + barW > w - 20 { break }
        let by = playCY - bh / 2
        let bp = CGMutablePath()
        bp.addRoundedRect(in: CGRect(x: bx, y: by, width: barW, height: bh), cornerWidth: 3.5, cornerHeight: 3.5)
        ctx.addPath(bp)
        ctx.fillPath()
    }

    save(ctx, to: "component_voice.png")
}

// ============================================================
// 5. Bookmark ribbon
// ============================================================
do {
    let cw = 280
    let ch = 512  // half of 1024
    let ctx = makeContext(w: cw, h: ch)
    let w = CGFloat(cw)
    let h = CGFloat(ch)
    let notchDepth: CGFloat = 80

    ctx.setFillColor(red: 0.96, green: 0.52, blue: 0.39, alpha: 1.0)

    let rp = CGMutablePath()
    rp.move(to: CGPoint(x: 0, y: h))
    rp.addLine(to: CGPoint(x: w, y: h))
    rp.addLine(to: CGPoint(x: w, y: 0))
    rp.addLine(to: CGPoint(x: w / 2, y: notchDepth))
    rp.addLine(to: CGPoint(x: 0, y: 0))
    rp.closeSubpath()

    ctx.addPath(rp)
    ctx.fillPath()

    // Dot
    let dotR: CGFloat = 24
    let dotCX = w / 2
    let dotCY = h - 100
    ctx.setFillColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.9)
    ctx.fillEllipse(in: CGRect(x: dotCX - dotR, y: dotCY - dotR, width: dotR * 2, height: dotR * 2))

    save(ctx, to: "component_ribbon.png")
}

print("\nAll components generated!")
