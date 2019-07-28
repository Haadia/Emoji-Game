import Cocoa
import Foundation
import PlaygroundSupport
import XCPlayground
import CoreGraphics
import CoreML
import CreateML
import Vision


public class DrawView: NSView {
    public var path: NSBezierPath = NSBezierPath()
    public var flag = false
    
    public override func mouseDown(with event: NSEvent) {
        path.move(to: convert(event.locationInWindow, from: nil))
        needsDisplay = true
    }
    
    public override func mouseDragged(with event: NSEvent) {
        path.line(to: convert(event.locationInWindow, from: nil))
        needsDisplay = true
    }
    
    public override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        //        print(flag)
        NSColor.black.set()
        
        if flag {
            path.removeAllPoints()
            
        }
        else {
            path.lineJoinStyle = .round
            path.lineCapStyle = .round
            path.lineWidth = 10.0
            path.stroke()
        }
    }
    
    public func clearView() {
//        self.flag = true
//        needsDisplay = true
 //       self.flag = false
        self.path.removeAllPoints()
    }
}
