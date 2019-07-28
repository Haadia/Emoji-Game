import Cocoa
import Foundation
import PlaygroundSupport
import XCPlayground
import CoreGraphics
import CoreML
import CreateML
import Vision


public class TrainingView: NSView {
    public var label: NSTextField?
    public var countLabel: NSTextField?
    public var emojiLabel: NSTextField?
    public var drawView: DrawView?
    public var button: NSButton?
    public var button2: NSButton?
    public let handler = MLHandler()
    public var progressbar: NSProgressIndicator?
    
    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupView()
    }
    
    public required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
   //     setupView()
    }
    
    public override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        drawView!.clearView()
        emojiLabel!.stringValue = emojisArray[emojiCount]
        if initialFlag {
        let multiplyFactor = Double(trainingSamplePerLabel) * Double(emojisArray.count)
       // print(1.0/multiplyFactor)
        let percentage: Double = Double((1.0/multiplyFactor)*10.0)
       // print(percentage)
        progressbar!.increment(by: percentage)
        }
        else {
            
        }
     //   setupView()
    }
    
    public func setupView() {
        
        progressbar = NSProgressIndicator()
        progressbar!.frame = NSRect(x: 18, y: 480, width: 444, height: 20)
        progressbar!.minValue = 0
        progressbar!.maxValue = 10
        progressbar!.isIndeterminate = false
        self.addSubview(progressbar!)
        
        
        let frame = NSRect(x: 18, y: 450, width: 444, height: 25)
        label = NSTextField(frame: frame)
        label!.stringValue = "Training. Draw the following emoji."
        label!.font = NSFont(name: label!.font!.fontName, size: 20)
        label!.backgroundColor = NSColor.clear
        label!.textColor = NSColor.white
        label!.isBezeled = false
        label!.isBordered = false
        label!.alignment = NSTextAlignment.center
        self.addSubview(label!)
        
        let frame2 = NSRect(x: 18, y: 380, width: 444, height: 57)
        emojiLabel = NSTextField(frame: frame2)
//        print(emojiCount)
        emojiLabel!.stringValue = emojisArray[emojiCount]
        emojiLabel!.backgroundColor = NSColor.clear
        emojiLabel!.isBezeled = false
        emojiLabel!.isBordered = false
        emojiLabel!.font = NSFont(name: "Snell Roundhand", size: 45)
        emojiLabel!.alignment = NSTextAlignment.center
        self.addSubview(emojiLabel!)
        
        
        let framecount = NSRect(x: 18, y: 330, width: 444, height: 20)
        countLabel = NSTextField(frame: framecount)
        countLabel!.stringValue = "\(count+1)/5"
        countLabel!.font = NSFont(name: label!.font!.fontName, size: 15)
        countLabel!.backgroundColor = NSColor.clear
        countLabel!.textColor = NSColor.white
        countLabel!.isBezeled = false
        countLabel!.isBordered = false
        countLabel!.alignment = NSTextAlignment.center
      //  self.addSubview(countLabel!)
        
        
        drawView = DrawView(frame: NSRect(x: 122, y: 120, width: 222, height: 200))
        drawView!.wantsLayer = true
        drawView!.layer?.backgroundColor = NSColor.gray.cgColor;
        self.addSubview(drawView!)
        
        
        button = NSButton(frame: NSRect(x: 270, y: 60, width: 194, height: 40))
        button!.wantsLayer = true
        button!.layer!.cornerRadius = 10
        button!.attributedTitle = NSAttributedString(string: "Next")

        button!.set(textColor: NSColor.black)
        button!.layer!.backgroundColor = NSColor(red:0.48, green: 0.50, blue:1.00, alpha:1.0).cgColor
        
//        button!.layer!.backgroundColor = NSColor.blue.cgColor
//        button!.title = "Next"
        self.addSubview(button!)
        
        button2 = NSButton(frame: NSRect(x: 18, y: 60, width: 194, height: 40))
        
        button2!.wantsLayer = true
        button2!.layer!.cornerRadius = 10
        button2!.layer!.backgroundColor = NSColor(red:0.48, green: 0.50, blue:1.00, alpha:1.0).cgColor
//        button2!.layer!.backgroundColor = NSColor.blue.cgColor
        button2!.attributedTitle = NSAttributedString(string: "Reset")
        
        button2!.set(textColor: NSColor.black)
        
                button2!.target = self
               button2!.action = #selector(resetPressed(sender:))
        
        self.addSubview(button2!)
        
    }
    
    @objc
    public func resetPressed(sender: NSButton) {
        drawView!.clearView()
        //        print("reset pressed")
    }
}
