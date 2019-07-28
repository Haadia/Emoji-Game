import Foundation
import Cocoa


public class CustomView: NSView, CAAnimationDelegate {
    
    public var layers = [String: CALayer]()
    public var completionBlocks = [CAAnimation: (Bool) -> Void]()
    public var updateLayerValueForCompletedAnimation : Bool = true
    
    
    //MARK: - Life Cycle
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        /*
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
*/
        
        setupProperties()
        setupLayers()
    }
    
    public required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        setupProperties()
        setupLayers()
    }
    
    
    
    public func setupProperties(){
        
    }
    
    public func setupLayers(){
        self.wantsLayer = true
        
        self.layer!.backgroundColor = NSColor.clear.cgColor
        
        let horIndicator2 = CAReplicatorLayer()
        horIndicator2.frame             = CGRect(x: 200,y: 200,width: 174.42, height: 59.29)
        horIndicator2.instanceCount     = 3
        horIndicator2.instanceDelay     = 0.22
        horIndicator2.instanceColor     = NSColor.white.cgColor
        horIndicator2.instanceTransform = CATransform3DMakeTranslation(34, 0, 0)
        self.layer?.addSublayer(horIndicator2)
        layers["horIndicator2"] = horIndicator2
        let oval2 = CAShapeLayer()
        oval2.frame       = CGRect(x: -0.9,y: 28.01,width: 20,height: 20)
        oval2.fillColor   = NSColor(red:0.48, green: 0.50, blue:1.00, alpha:1.0).cgColor
        oval2.strokeColor = NSColor(red:0.404, green: 0.404, blue:0.404, alpha:1).cgColor
        oval2.lineWidth   = 0
        oval2.path        = oval2Path().quartzPath
        horIndicator2.addSublayer(oval2)
        layers["oval2"] = oval2
    }
    
    
    
    //MARK: - Animation Setup
    
    public func addOldAnimation(){
        let fillMode : String = CAMediaTimingFillMode.forwards.rawValue
        
        ////An infinity animation
        
        ////Oval2 animation
        let oval2TransformAnim            = CABasicAnimation(keyPath:"transform")
        oval2TransformAnim.fromValue      = NSValue(caTransform3D: CATransform3DMakeScale(0, 0, 1));
        oval2TransformAnim.toValue        = NSValue(caTransform3D: CATransform3DIdentity);
        oval2TransformAnim.duration       = 0.729
        oval2TransformAnim.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeInEaseOut)
        oval2TransformAnim.repeatCount    = Float.infinity
        oval2TransformAnim.autoreverses   = true
        
        let oval2OldAnim : CAAnimationGroup = QCMethod.group(animations: [oval2TransformAnim], fillMode:fillMode)
        layers["oval2"]?.add(oval2OldAnim, forKey:"oval2OldAnim")
    }
    
    //MARK: - Animation Cleanup
    
    public func animationDidStop(_ anim: CAAnimation, finished flag: Bool){
        if let completionBlock = completionBlocks[anim]{
            completionBlocks.removeValue(forKey: anim)
            if (flag && updateLayerValueForCompletedAnimation) || anim.value(forKey: "needEndAnim") as! Bool{
                updateLayerValues(forAnimationId: anim.value(forKey: "animId") as! String)
                removeAnimations(forAnimationId: anim.value(forKey: "animId") as! String)
            }
            completionBlock(flag)
        }
    }
    
    public func updateLayerValues(forAnimationId identifier: String){
        if identifier == "old"{
            QCMethod.updateValueFromPresentationLayer(forAnimation: layers["oval2"]!.animation(forKey: "oval2OldAnim"), theLayer:layers["oval2"]!)
        }
    }
    
    public func removeAnimations(forAnimationId identifier: String){
        if identifier == "old"{
            layers["oval2"]?.removeAnimation(forKey: "oval2OldAnim")
        }
    }
    
    public func removeAllAnimations(){
        for layer in layers.values{
            layer.removeAllAnimations()
        }
    }
    
    //MARK: - Bezier Path
    
    public func oval2Path() -> NSBezierPath{
        let oval2Path = NSBezierPath(ovalIn:CGRect(x:0,y: 0,width: 34,height: 34))
        return oval2Path
    }
    
    
}
