
import Foundation
import PlaygroundSupport
import XCPlayground
import CoreGraphics
import CoreML
import CreateML
import Vision
import Cocoa


public class QCMethod
{
    public class func reverseAnimation(anim : CAAnimation, totalDuration : CFTimeInterval) -> CAAnimation{
        var duration :CFTimeInterval = anim.duration + (anim.autoreverses ? anim.duration : 0)
        if anim.repeatCount > 1 {
            duration *= CFTimeInterval(anim.repeatCount)
        }
        let endTime = anim.beginTime + duration
        let reverseStartTime = totalDuration - endTime
        
        var newAnim : CAAnimation!
        
        //Reverse timing function closure
        let reverseTimingFunction =
        {
            (theAnim:CAAnimation) -> Void  in
            let timingFunction = theAnim.timingFunction;
            if timingFunction != nil{
                var first : [Float] = [0,0]
                var second : [Float] = [0,0]
                timingFunction?.getControlPoint(at: 1, values: &first)
                timingFunction?.getControlPoint(at: 2, values: &second)
                
                theAnim.timingFunction = CAMediaTimingFunction(controlPoints: 1-second[0], 1-second[1], 1-first[0], 1-first[1])
            }
        }
        
        //Reverse animation values appropriately
        if let basicAnim = anim as? CABasicAnimation{
            if !anim.autoreverses{
                let fromValue: Any! = basicAnim.toValue
                basicAnim.toValue = basicAnim.fromValue
                basicAnim.fromValue = fromValue
                reverseTimingFunction(basicAnim)
            }
            basicAnim.beginTime = CFTimeInterval(reverseStartTime)
            
            
            if reverseStartTime > 0 {
                let groupAnim = CAAnimationGroup()
                groupAnim.animations = [basicAnim]
                groupAnim.duration = maxDuration(ofAnimations: groupAnim.animations! as [CAAnimation])
                for anim in groupAnim.animations!{
                    anim.fillMode = CAMediaTimingFillMode.both
                }
                newAnim = groupAnim
            }
            else{
                newAnim = basicAnim
            }
            
        }
        else if let keyAnim = anim as? CAKeyframeAnimation{
            if !anim.autoreverses{
                let values : [Any] = (keyAnim.values?.reversed())!
                keyAnim.values = values;
                reverseTimingFunction(keyAnim)
            }
            keyAnim.beginTime = CFTimeInterval(reverseStartTime)
            
            if reverseStartTime > 0 {
                let groupAnim = CAAnimationGroup()
                groupAnim.animations = [keyAnim]
                groupAnim.duration = maxDuration(ofAnimations: groupAnim.animations! as [CAAnimation])
                for anim in groupAnim.animations!{
                    anim.fillMode = CAMediaTimingFillMode.both
                }
                newAnim = groupAnim
            }else{
                newAnim = keyAnim
            }
        }
        else if let groupAnim = anim as? CAAnimationGroup{
            var newSubAnims : [CAAnimation] = []
            for subAnim in groupAnim.animations! as [CAAnimation] {
                let newSubAnim = reverseAnimation(anim: subAnim, totalDuration: totalDuration)
                newSubAnims.append(newSubAnim)
            }
            
            groupAnim.animations = newSubAnims
            for anim in groupAnim.animations!{
                anim.fillMode = CAMediaTimingFillMode.both
            }
            groupAnim.duration = maxDuration(ofAnimations: newSubAnims)
            newAnim = groupAnim
        }else{
            newAnim = anim
        }
        return newAnim
    }
    
    public class func group(animations : [CAAnimation], fillMode : String!, forEffectLayer : Bool = false, sublayersCount : NSInteger = 0) -> CAAnimationGroup!{
        let groupAnimation = CAAnimationGroup()
        groupAnimation.animations = animations
        
        if (fillMode != nil){
            if let animations = groupAnimation.animations {
                for anim in animations {
                    anim.fillMode = CAMediaTimingFillMode(rawValue: fillMode)
                }
            }
            groupAnimation.fillMode = CAMediaTimingFillMode(rawValue: fillMode)
            groupAnimation.isRemovedOnCompletion = false
        }
        
        if forEffectLayer{
            groupAnimation.duration = QCMethod.maxDuration(ofEffectAnimation: groupAnimation, sublayersCount: sublayersCount)
        }else{
            groupAnimation.duration = QCMethod.maxDuration(ofAnimations: animations)
        }
        
        return groupAnimation
    }
    
    public class func maxDuration(ofAnimations anims: [CAAnimation]) -> CFTimeInterval{
        var maxDuration: CGFloat = 0;
        for anim in anims {
            maxDuration = max(CGFloat(anim.beginTime + anim.duration) * CGFloat(anim.repeatCount == 0 ? 1.0 : anim.repeatCount) * (anim.autoreverses ? 2.0 : 1.0), maxDuration);
        }
        
        if maxDuration.isInfinite {
            return TimeInterval(NSIntegerMax)
        }
        
        return CFTimeInterval(maxDuration);
    }
    
    public class func maxDuration(ofEffectAnimation anim: CAAnimation, sublayersCount : NSInteger) -> CFTimeInterval{
        var maxDuration : CGFloat = 0
        if let groupAnim = anim as? CAAnimationGroup{
            for subAnim in groupAnim.animations! as [CAAnimation]{
                
                var delay : CGFloat = 0
                if let instDelay = (subAnim.value(forKey: "instanceDelay") as? NSNumber)?.floatValue{
                    delay = CGFloat(instDelay) * CGFloat(sublayersCount - 1);
                }
                var repeatCountDuration : CGFloat = 0;
                if subAnim.repeatCount > 1 {
                    repeatCountDuration = CGFloat(subAnim.duration) * CGFloat(subAnim.repeatCount-1);
                }
                var duration : CGFloat = 0;
                
                duration = CGFloat(subAnim.beginTime) + (subAnim.autoreverses ? CGFloat(subAnim.duration) : CGFloat(0)) + delay + CGFloat(subAnim.duration) + CGFloat(repeatCountDuration);
                maxDuration = max(duration, maxDuration);
            }
        }
        
        if maxDuration.isInfinite {
            maxDuration = 1000
        }
        
        return CFTimeInterval(maxDuration);
    }
    
    public class func updateValueFromAnimations(forLayers layers: [CALayer]){
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        for aLayer in layers{
            if let keys = aLayer.animationKeys() as [String]!{
                for animKey in keys{
                    let anim = aLayer.animation(forKey: animKey)
                    updateValue(forAnimation: anim!, theLayer: aLayer);
                }
            }
            
        }
        
        CATransaction.commit()
    }
    
    public class func updateValue(forAnimation anim: CAAnimation, theLayer : CALayer){
        if let basicAnim = anim as? CABasicAnimation{
            if (!basicAnim.autoreverses) {
                theLayer.setValue(basicAnim.toValue, forKeyPath: basicAnim.keyPath!)
            }
        }else if let keyAnim = anim as? CAKeyframeAnimation{
            if (!keyAnim.autoreverses) {
                theLayer.setValue(keyAnim.values?.last, forKeyPath: keyAnim.keyPath!)
            }
        }else if let groupAnim = anim as? CAAnimationGroup{
            for subAnim in groupAnim.animations! as [CAAnimation]{
                updateValue(forAnimation: subAnim, theLayer: theLayer);
                
            }
        }
    }
    
    public class func updateValueFromPresentationLayer(forAnimation anim: CAAnimation!, theLayer : CALayer){
        if let basicAnim = anim as? CABasicAnimation{
            theLayer.setValue(theLayer.presentation()?.value(forKeyPath: basicAnim.keyPath!), forKeyPath: basicAnim.keyPath!)
        }else if let keyAnim = anim as? CAKeyframeAnimation{
            theLayer.setValue(theLayer.presentation()?.value(forKeyPath: keyAnim.keyPath!), forKeyPath: keyAnim.keyPath!)
        }else if let groupAnim = anim as? CAAnimationGroup{
            for subAnim in groupAnim.animations! as [CAAnimation]{
                updateValueFromPresentationLayer(forAnimation: subAnim, theLayer: theLayer)
            }
        }
    }
    
    public class func addSublayersAnimation(anim : CAAnimation, key : String, layer : CALayer){
        return addSublayersAnimationNeedReverse(anim: anim, key: key, layer: layer, reverseAnimation: false, totalDuration: 0)
    }
    
   public  class func addSublayersAnimationNeedReverse(anim : CAAnimation, key : String, layer : CALayer, reverseAnimation : Bool, totalDuration : CFTimeInterval){
        let sublayers = layer.sublayers
        let sublayersCount = sublayers!.count
        
        let setBeginTime =
        {
            (subAnim:CAAnimation, sublayerIdx:NSInteger) -> Void  in
            
            if let instDelay = (subAnim.value(forKey: "instanceDelay") as? NSNumber)?.floatValue{
                if (instDelay != 0) {
                    let instanceDelay = CGFloat(instDelay)
                    let orderType : NSInteger = ((subAnim.value(forKey: "instanceOrder")!) as AnyObject).integerValue
                    switch (orderType) {
                    case 0: subAnim.beginTime = CFTimeInterval(CGFloat(subAnim.beginTime) + CGFloat(sublayerIdx) * instanceDelay)
                    case 1: subAnim.beginTime = CFTimeInterval(CGFloat(subAnim.beginTime) + CGFloat(sublayersCount - sublayerIdx - 1) * instanceDelay)
                    case 2:
                        let middleIdx     = sublayersCount/2
                        let begin         = CGFloat(abs(middleIdx - sublayerIdx)) * instanceDelay
                        subAnim.beginTime += CFTimeInterval(begin)
                        
                    case 3:
                        let middleIdx     = sublayersCount/2
                        let begin         = CGFloat(middleIdx - abs((middleIdx - sublayerIdx))) * instanceDelay
                        subAnim.beginTime     += CFTimeInterval(begin)
                        
                    default:
                        break
                    }
                }
            }
        }
        
        for (idx, sublayer) in sublayers!.enumerated() {
            
            if let groupAnim = anim.copy() as? CAAnimationGroup{
                var newSubAnimations : [CAAnimation] = []
                for subAnim in groupAnim.animations!{
                    newSubAnimations.append(subAnim.copy() as! CAAnimation)
                }
                groupAnim.animations = newSubAnimations
                let animations = groupAnim.animations
                for sub in animations! as [CAAnimation]{
                    setBeginTime(sub, idx)
                    //Reverse animation if needed
                    if reverseAnimation {
                        _ = self.reverseAnimation(anim: sub, totalDuration: totalDuration)
                    }
                    
                }
                sublayer.add(groupAnim, forKey: key)
            }
            else{
                let copiedAnim = anim.copy() as! CAAnimation
                setBeginTime(copiedAnim, idx)
                sublayer.add(copiedAnim, forKey: key)
            }
            
        }
    }
    
    
    #if os(iOS)
    public class func alignToBottomPath(path : UIBezierPath, layer: CALayer) -> UIBezierPath{
        let diff = layer.bounds.maxY - path.bounds.maxY
        let transform = CGAffineTransform.identity.translatedBy(x: 0, y: diff)
        path.apply(transform)
        return path;
    }
    
    public class func offsetPath(path : UIBezierPath, offset : CGPoint) -> UIBezierPath{
        let affineTransform = CGAffineTransform.identity.translatedBy(x: offset.x, y: offset.y)
        path.apply(affineTransform)
        return path
    }
    
    
    #else
    public class func offsetPath(path : NSBezierPath, offset : CGPoint) -> NSBezierPath{
        let xfm = NSAffineTransform()
        xfm.translateX(by: offset.x, yBy:offset.y)
        path.transform(using: xfm as AffineTransform)
        return path
    }
    
    
    #endif
}
