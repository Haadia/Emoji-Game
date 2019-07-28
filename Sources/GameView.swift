import Cocoa
import Foundation
import PlaygroundSupport
import XCPlayground
import CoreGraphics
import CoreML
import CreateML
import Vision

var viewFlag = false

public class GameView: NSView {
    
    public var trainingView: TrainingView?
    public var testingView: TestingView?
    public var label: NSTextField?
    
    public let handler = MLHandler()
    
    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        
        let path = playgroundSharedDataDirectory.appendingPathComponent("Data")
        
        do
        {
            try FileManager.default.createDirectory(atPath: path.path, withIntermediateDirectories: true, attributes: nil)
        }
        catch let error as NSError
        {
            NSLog("Unable to create directory \(error.debugDescription)")
        }
        
        
        for i in 0..<emojisArray.count {
            let path = playgroundSharedDataDirectory.appendingPathComponent("Data/emoji\(i)")
            
            do
            {
                try FileManager.default.createDirectory(atPath: path.path, withIntermediateDirectories: true, attributes: nil)
            }
            catch let error as NSError
            {
                NSLog("Unable to create directory \(error.debugDescription)")
            }
        }

        let frame2 = NSRect(x: 18, y: 400, width: 444, height: 25)
        label = NSTextField(frame: frame2)
        label!.stringValue = "Please wait while ML model is being trained."
        label!.font = NSFont(name: label!.font!.fontName, size: 20)
        label!.backgroundColor = NSColor.clear
        label!.textColor = NSColor.white
        label!.isBezeled = false
        label!.isBordered = false
        label!.alignment = NSTextAlignment.center
        self.addSubview(label!)
        
        
        self.label!.isHidden = true
        
        

        
        trainingView = TrainingView(frame: frameRect)
        
        testingView = TestingView(frame: frameRect)
        
        self.addSubview(testingView!)
        
        testingView!.isHidden = true
        
        trainingView!.button!.target = self
        trainingView!.button!.action = #selector(self.nextPressed)
        
        trainingView!.button2!.target = self
        trainingView!.button2!.action = #selector(self.resetPressed(sender:))
        
        self.addSubview(trainingView!)

    }
    @objc public func resetPressed(sender: NSButton) {
//        print("Reset pressed")
        trainingView!.drawView!.path.removeAllPoints()
        trainingView!.drawView!.needsDisplay = true
    }
    
    public required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
    }
    
    public override func draw(_ dirtyRect: NSRect) {
    }
    
    @objc
    public func nextPressed() {
//        print("Next pressed")
//        print(count)
        initialFlag = true
        let image = trainingView!.drawView!.layer!.getBitmapImage()
        
        
        let myPath = playgroundSharedDataDirectory.appendingPathComponent("Data/emoji\(emojiCount)/\(count).jpeg")
        
        
        let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil)!
        let bitmapRep = NSBitmapImageRep(cgImage: cgImage)
        let jpegData = bitmapRep.representation(using: NSBitmapImageRep.FileType.jpeg, properties: [:])!
        
        do {
            try jpegData.write(to: myPath)
        }
        catch {
            print("Can't write \(error)")
        }
        
        trainingView!.drawView!.path.removeAllPoints()
        trainingView!.drawView!.needsDisplay = true

        
        if count == trainingSamplePerLabel-1 {
            
            if emojiCount == emojisArray.count-1 {
                viewFlag = true
//                print("End")
  
  //              print(self.subviews)
                
                CATransaction.begin()
                CATransaction.setAnimationDuration(2.0)
                self.trainingView!.isHidden = true
                CATransaction.commit()
                
//                let frame2 = NSRect(x: 121, y: 120, width: 222, height: 200)
                
                let view2 = CustomView(frame: frame)
                view2.addOldAnimation()
                self.addSubview(view2)
                self.label!.isHidden = false
                
                DispatchQueue.global(qos: .background).async {
//                    print("This is run on the background queue")
                    self.handler.buildModel()
                    
                    DispatchQueue.main.async {
                        CATransaction.begin()
                        CATransaction.setAnimationDuration(2.0)

                        self.testingView!.isHidden = false
                        self.label!.isHidden = true
                        view2.isHidden = true
                        CATransaction.commit()
                        
                    }
                }
            }
            else {
//                print("increment")
                emojiCount += 1
                count = 0
                self.trainingView!.needsDisplay = true
            }
        }
        else {
//            print("adding")
            count += 1
            self.trainingView!.needsDisplay = true
        }
        
       
        
    }
    
    
}

