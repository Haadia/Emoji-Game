
/*:
 
 # Emoji Game
 
Train the playground and then play against it.
 */

/*:

 Emoji Game is a playground based game which uses both CoreML and CreateML for a more engaging user experience.
 
 You first train the playground on different emojis (default training sample count is 3, you have to draw each smiley three times). Training Sample count can be changed below.
 
 After the training, playground trains and compiles the machine learning model. You can then play and let the playground guess.
 */

/*:
 
 *Edit following array for custom emojis.*
 
 */
public var emojisArray = ["🙂","😛","😊","☹️"]

/*:
 
 *Edit number of training samples for each emoji.*
 
 */

public var trainingSamplePerLabel = 3




import Cocoa
import Foundation
import PlaygroundSupport
import XCPlayground
import CoreGraphics
import CoreML
import CreateML
import Vision



let frame = NSRect(x: 0, y: 0, width: 480, height: 500)



let anim = GameView(frame: frame)

PlaygroundPage.current.liveView = anim
PlaygroundPage.current.needsIndefiniteExecution = true


