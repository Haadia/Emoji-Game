import Cocoa
import Foundation
import PlaygroundSupport
import XCPlayground
import CoreGraphics
import CoreML
import CreateML
import Vision

public class TestingView: NSView {
    public let handler = MLHandler()
    public var label: NSTextField?
    
    public var drawView: DrawView?
    public var emojiLabel: NSTextField?

    
    public override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        let frame = NSRect(x: 18, y: 450, width: 444, height: 25)
        label = NSTextField(frame: frame)
        label!.stringValue = "Model is trained. Let's play. draw any emoji here."
        label!.font = NSFont(name: label!.font!.fontName, size: 20)
        label!.backgroundColor = NSColor.clear
        label!.textColor = NSColor.white
        label!.isBezeled = false
        label!.isBordered = false
        label!.alignment = NSTextAlignment.center
        self.addSubview(label!)

        let frame2 = NSRect(x: 218, y: 380, width: 50, height: 50)
        emojiLabel = NSTextField(frame: frame2)
//        print(emojiCount)
        emojiLabel!.stringValue = "🙂"
        emojiLabel!.backgroundColor = NSColor.clear
        emojiLabel!.isBezeled = false
        emojiLabel!.isBordered = false
        emojiLabel!.font = NSFont(name: "Snell Roundhand", size: 40)
        emojiLabel!.alignment = NSTextAlignment.center
        self.addSubview(emojiLabel!)
        emojiLabel!.isHidden = true
        
        drawView = DrawView(frame: NSRect(x: 118, y: 150, width: 222, height: 200))
        drawView!.wantsLayer = true
        drawView!.layer?.backgroundColor = NSColor.gray.cgColor;
        self.addSubview(drawView!)
        
        
        let button = NSButton(frame: NSRect(x: 118, y: 60, width: 222, height: 40))
        button.attributedTitle = NSAttributedString(string: "Guess")
        
        button.set(textColor: NSColor.black)
        
        button.wantsLayer = true
        button.layer!.cornerRadius = 10
        button.layer!.backgroundColor = NSColor(red:0.48, green: 0.50, blue:1.00, alpha:1.0).cgColor

        button.target = self
        button.action = #selector(self.pressed(sender:))
        self.addSubview(button)
    }
    
    public func animateLabel() {
        emojiLabel!.isHidden = false
        
        NSAnimationContext.runAnimationGroup({_ in
            NSAnimationContext.current.duration = 0.5
            emojiLabel!.animator().alphaValue = 0.0  // Fade out
        }, completionHandler:{
            self.emojiLabel!.animator().alphaValue = 1.0  // Fade in
        })
    }
    
    @objc
    public func pressed(sender: NSButton) {
//        print("pressed")
        let image = self.drawView!.layer!.getBitmapImage()
        self.drawView!.path.removeAllPoints()
        self.drawView!.needsDisplay = true
        
        if let label = handler.predict(image: image) {
//            print(label)
            var index = Int(String(label.last!))
//            var index = Int(label.last!)
            emojiLabel!.stringValue = emojisArray[index!]
        }
        else {
            print("error")
        }
        animateLabel()
    }
}
