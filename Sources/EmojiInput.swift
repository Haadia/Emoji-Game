import Cocoa
import Foundation
import PlaygroundSupport
import XCPlayground
import CoreGraphics
import CoreML
import CreateML
import Vision

public class EmojiInput : MLFeatureProvider {
    
    /// input as color (kCVPixelFormatType_32BGRA) image buffer, 720 pixels wide by 720 pixels high
    public var input: CVPixelBuffer
    
    public var featureNames: Set<String> {
        get {
            return ["input"]
        }
    }
    
    public func featureValue(for featureName: String) -> MLFeatureValue? {
        if (featureName == "input") {
            return MLFeatureValue(pixelBuffer: input)
        }
        return nil
    }
    
    public init(input: CVPixelBuffer) {
        self.input = input
    }
}
