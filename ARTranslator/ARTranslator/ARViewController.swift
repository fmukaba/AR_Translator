
//  ViewController.swift
//  test
//
//  Created by Francois Mukaba on 2/11/20.
//  Copyright © 2020 Francois Mukaba. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import Vision
import Firebase

class ARViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate{

    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var sceneView: ARSCNView!
    let vision = Vision.vision()
    var textRecognizer : VisionTextRecognizer?
    let framer = ScaledElementProcessor()
    
    var lastFrame : ARFrame?
    var currentImage : UIImage?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        sceneView.session.delegate = self
        
        //sceneView.preferredFramesPerSecond = 2
        
        // Show statistics such as fps and timing information
        //sceneView.showsStatistics = true
        
        // Create a new scene
        //let scene = SCNScene(named: "art.scnassets/ship.scn")!
        
        // Set the scene to the view
        //sceneView.scene = scene
        
        requestTextDetection()
    }
    
 
    
    func requestTextDetection() {
        textRecognizer = vision.onDeviceTextRecognizer()
  
    }
    
    
    
    
      func highlightWord(box: VNTextObservation, translation : String) {
            guard let boxes = box.characterBoxes else {
                return
            }
                
            var maxX: CGFloat = 9999.0
            var minX: CGFloat = 0.0
            var maxY: CGFloat = 9999.0
            var minY: CGFloat = 0.0
                
            for char in boxes {
                if char.bottomLeft.x < maxX {
                    maxX = char.bottomLeft.x
                }
                if char.bottomRight.x > minX {
                    minX = char.bottomRight.x
                }
                if char.bottomRight.y < maxY {
                    maxY = char.bottomRight.y
                }
                if char.topRight.y > minY {
                    minY = char.topRight.y
                }
            }
                
            let xCord = maxX * sceneView.frame.size.width
            let yCord = (1 - minY) * sceneView.frame.size.height
            let width = (minX - maxX) * sceneView.frame.size.width
            let height = (minY - maxY) * sceneView.frame.size.height
                
            let outline = CATextLayer()
            outline.frame = CGRect(x: xCord, y: yCord, width: width, height: height)
            outline.borderWidth = 2.0
            outline.backgroundColor = UIColor.darkGray.cgColor
            outline.string = translation
            // fix scaling of text
            outline.font = UIFont(name: "Helvetica", size: height*(1/3))
            outline.shadowOpacity = 0.1
            outline.alignmentMode = CATextLayerAlignmentMode.center
            outline.borderColor = UIColor.blue.cgColor
            
            sceneView.layer.addSublayer(outline)
        }
        
        fileprivate func presentAlert(title: String, message: String) {
            let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
            controller.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(controller, animated: true, completion: nil)
        }
    
        
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
       // scanFrame()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    private func createVisionImage() -> UIImage? {
        guard let pixbuff : CVPixelBuffer? = lastFrame?.capturedImage else {
         return nil
       }
        
       let ciImage = CIImage(cvPixelBuffer: pixbuff!)
       let context = CIContext.init(options: nil)

       guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else {
         return nil
       }
        
        let createdImage =
            UIImage.init(cgImage: cgImage, scale: 1.0, orientation: .right)

//        guard let rotatedCGImage = rotatedImage.cgImage else {
//         return nil
//       }

        imageView.image = createdImage.fixOrientation()
        return createdImage.fixOrientation()
     }
    
    func processImage() {
        guard let image = createVisionImage() else { return }
        let imageMetadata = VisionImageMetadata()
        imageMetadata.orientation = UIUtilities.visionImageOrientation(from: image.imageOrientation)
        
        // Initialize a VisionImage object with the given UIImage.
        let visionImage = VisionImage(image: image)
       
        visionImage.metadata = imageMetadata
        textRecognizer?.process(visionImage) { result, error in

            guard error == nil, let result = result else {
                return
            }
            for block in result.blocks {
                // line by line
                for line in block.lines {
                 print(line.text, " ")
                    for element in line.elements {

                    }
                }
            }
       }
    }

    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        if(lastFrame == nil){
            lastFrame = frame
        }
           
        // grabs frame every 4 seconds
        if (frame.timestamp - lastFrame!.timestamp >= 4) {
            lastFrame = frame
            if case .normal = frame.camera.trackingState {
//                if ( UIDevice.currentDevice.orientation == UIDeviceOrientation.landscapeLeft || UIDevice.currentDevice().orientation == UIDeviceOrientation.landscapeLeft){
//
                
                do {
                    processImage()
                    
                   } catch {
                           print(error)
                   }
               }
           }
       }
}
