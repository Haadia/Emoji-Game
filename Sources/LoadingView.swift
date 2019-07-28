import Foundation
import Cocoa

public class LoadingView: NSView {
    
    
    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
    }
    
    public required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
    }
    
    public override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        let frame2 = NSRect(x: 18, y: 450, width: 444, height: 25)
        let label = NSTextField(frame: frame2)
        label.stringValue = "Training. Draw the following emoji."
        label.font = NSFont(name: label.font!.fontName, size: 20)
        label.backgroundColor = NSColor.clear
        label.textColor = NSColor.white
        label.isBezeled = false
        label.isBordered = false
        label.alignment = NSTextAlignment.center
        self.addSubview(label)

        let frame = NSRect(x: 18, y: 380, width: 444, height: 57)
        let anim = CustomView(frame: frame)
        anim.addOldAnimation()
        self.addSubview(anim)

        
        
    }
}
