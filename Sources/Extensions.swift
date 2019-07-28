import Cocoa
import Foundation
import PlaygroundSupport
import XCPlayground
import CoreGraphics
import CoreML
import CreateML
import Vision

public extension NSImage {
    public func pixelBuffer() -> CVPixelBuffer? {
        let width = self.size.width
        let height = self.size.height
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
                     kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault,
                                         Int(width),
                                         Int(height),
                                         kCVPixelFormatType_32ARGB,
                                         attrs,
                                         &pixelBuffer)
        
        guard let resultPixelBuffer = pixelBuffer, status == kCVReturnSuccess else {
            return nil
        }
        
        CVPixelBufferLockBaseAddress(resultPixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
        let pixelData = CVPixelBufferGetBaseAddress(resultPixelBuffer)
        
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        guard let context = CGContext(data: pixelData,
                                      width: Int(width),
                                      height: Int(height),
                                      bitsPerComponent: 8,
                                      bytesPerRow: CVPixelBufferGetBytesPerRow(resultPixelBuffer),
                                      space: rgbColorSpace,
                                      bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue) else {return nil}
        
        context.translateBy(x: 0, y: height)
        context.scaleBy(x: 1.0, y: -1.0)
        
        let graphicsContext = NSGraphicsContext(cgContext: context, flipped: false)
        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = graphicsContext
        draw(in: CGRect(x: 0, y: 0, width: width, height: height))
        NSGraphicsContext.restoreGraphicsState()
        
        CVPixelBufferUnlockBaseAddress(resultPixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
        
        return resultPixelBuffer
    }
}

public extension CALayer {
    
    public func getBitmapImage() -> NSImage {
        
        let btmpImgRep =
            NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: Int(self.frame.width), pixelsHigh: Int(self.frame.height), bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: NSColorSpaceName.deviceRGB, bytesPerRow: 0, bitsPerPixel: 32)
        
        let ctx = NSGraphicsContext(bitmapImageRep: btmpImgRep!)
        let cgContext = ctx!.cgContext
        
        self.render(in: cgContext)
        
        let cgImage = cgContext.makeImage()
        
        let nsimage = NSImage(cgImage: cgImage!, size: CGSize(width: self.frame.width, height: self.frame.height))
        
        return nsimage
    }
}



public extension NSBezierPath {
    
    var quartzPath: CGPath {
        
        get {
            return self.transformToCGPath()
        }
    }
    
    /// Transforms the NSBezierPath into a CGPathRef
    ///
    /// :returns: The transformed NSBezierPath
    private func transformToCGPath() -> CGPath {
        
        // Create path
        let path = CGMutablePath()
        let points = UnsafeMutablePointer<NSPoint>.allocate(capacity: 3)
        let numElements = self.elementCount
        
        if numElements > 0 {
            for index in 0..<numElements {
                
                let pathType = self.element(at: index, associatedPoints: points)
                
                switch pathType {
                    
                case .moveTo:
                    path.move(to: points[0])
                case .lineTo:
                    path.addLine(to: points[0])
                case .curveTo:
                    path.addCurve(to: points[2], control1: points[0], control2: points[1])
                case .closePath:
                    path.closeSubpath()
                }
            }
        }
        points.deallocate(capacity: 3)
        return path
    }
}


public extension NSImage{
    
    func cgImage() -> CGImage{
        let data = self.tiffRepresentation
        var imageRef : CGImage!
        var sourceRef : CGImageSource!
        
        sourceRef = CGImageSourceCreateWithData(data! as CFData, nil)
        if (sourceRef != nil) {
            imageRef = CGImageSourceCreateImageAtIndex(sourceRef, 0, nil)
        }
        return imageRef
    }
}


public extension NSButton {
    func set(textColor color: NSColor) {
        let newAttributedTitle = NSMutableAttributedString(attributedString: attributedTitle)
        let range = NSRange(location: 0, length: attributedTitle.length)
        newAttributedTitle.addAttributes([
            .foregroundColor: color,
            ], range: range)
        attributedTitle = newAttributedTitle
    }
}
