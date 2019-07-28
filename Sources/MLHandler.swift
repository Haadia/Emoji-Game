import Cocoa
import Foundation
import PlaygroundSupport
import XCPlayground
import CoreGraphics
import CoreML
import CreateML
import Vision


public class MLHandler {
    
    
    public init() {
        
    }

    public func predict(image: NSImage) -> String? {
        var label: String?
        do {
            let model = try MLModel(contentsOf: compiledURL!)
            //    try model.pred
            let buffer = image.pixelBuffer()
            do {
//                print(compiledURL)
                let result = try model.prediction(from: my_mnistInput(image__28x28_:buffer!))
                
             //   print(result.featureValue(for: "classLabel"))
                label = result.featureValue(for: "classLabel")!.stringValue
            }
            catch {
               // print("Error in prediction")
                print(error)
            }
        }
        catch {
//            print("Error in model generation")
            print(error)
        }
        return label
    }
    
    public func buildModel() {
        var trainingURL = playgroundSharedDataDirectory.appendingPathComponent("Data")
        var validationURL =  playgroundSharedDataDirectory.appendingPathComponent("Data")
        let trainingDataSource = MLImageClassifier.DataSource.labeledDirectories(at: trainingURL)
        let validationDataSource = MLImageClassifier.DataSource.labeledDirectories(at: validationURL)
        
        do {
            let classifier = try MLImageClassifier(trainingData: trainingDataSource)
            
            var modelMetadata = MLModelMetadata()
            
            modelMetadata.author = "Hadia Jalil"
            modelMetadata.shortDescription = "The runtime emoji classifier"
            modelMetadata.license = "MIT"
            modelMetadata.version = "1.0"
            
            modelMetadata.additional = [
                "data_description" : "5 images per classification class",
                "image_format" : "JPEG"
            ]
            
            let modelPath = playgroundSharedDataDirectory.appendingPathComponent("EmojiClassifier.mlmodel")
            do
            {
                try classifier.write(to: modelPath, metadata: modelMetadata)
                
                
                do {
                    compiledURL = try MLModel.compileModel(at: modelPath)
                   // print("Compiled")
                   // print(compiledURL!)
                }
                catch {
                    print("Error in compiling Model \(error)")
                }
                
                
            }
            catch
            {
                print(error)
            }
            
        }
        catch {
            print (error)
        }
        
        
    }
}

