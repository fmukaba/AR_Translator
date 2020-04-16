//
//  ScaledElementProcessor.swift
//  ARTranslator
//
//  Created by Reina S on 2/18/20.
//  Copyright © 2020 Francois Mukaba. All rights reserved.
//

import Foundation
import Firebase

struct ScaledElement {
    let frame: CGRect
    let shapeLayer: CALayer
    let textLayer: CATextLayer //add text to the rect
}

class ScaledElementProcessor {
    
    
    
    let vision = Vision.vision()
    var textRecognizer: VisionTextRecognizer!
    
    //translated text
    var transText = ""
    
    //translator
    var translator: Translator!
    var englishGermanTranslator : Translator?
    
    init() {
        textRecognizer = vision.onDeviceTextRecognizer()
        let options = TranslatorOptions(sourceLanguage: .en, targetLanguage: .de)
        englishGermanTranslator = NaturalLanguage.naturalLanguage().translator(options: options)
    }
    
    func process(in imageView: UIImageView, callback: @escaping (_ text: String, _ scaledElements: [ScaledElement]) -> Void) {
        
        guard let image = imageView.image else { return }
        let visionImage = VisionImage(image: image)
        
        //instance of avgColorGrabber class
        let colorGrabber = avgColorGrabber.init(image: image)
        
        textRecognizer.process(visionImage) { result, error in
            guard error == nil, let result = result, !result.text.isEmpty else {
                callback("", [])
                return
            }
            
            var scaledElements: [ScaledElement] = []
            for block in result.blocks {
                for line in block.lines {
                    for element in line.elements {
                        
                        //the CGrect
                        let frame = self.createScaledFrame(featureFrame: element.frame, imageSize: image.size, viewFrame: imageView.frame)
                        
                        //get the avg color of cgrect
                        let backgroundColor = colorGrabber.getAvgRectColor(rect: frame).cgColor
                        
                        //create the actual shapelayer
                        let shapeLayer = self.createShapeLayer(frame: frame)
                        
                        //get the text
                        let detectedText = element.text
                        
                        //translate the text
                        self.transText = self.translateString(text: detectedText)
                        print(self.transText, "2")
                        
                        //set textlayer
                        let textLayer = self.createTextLayer(frame: frame, text: self.transText, background: backgroundColor)
                        
                        //create scaled Element
                        let scaledElement = ScaledElement(frame: frame, shapeLayer: shapeLayer, textLayer: textLayer)
                        // let scaledElement = ScaledElement(frame: frame, textLayer: textLayer)
                        
                        scaledElements.append(scaledElement)
                        
                        //print out detected text
                        print(element.text, " ")
                        
                    }
                }
            }
            
            callback(result.text, scaledElements)
        }
    }
    
    //translate text
    private func translateString(text: String) -> String{
        var transText = ""
        
        let conditions = ModelDownloadConditions(
            allowsCellularAccess: false,
            allowsBackgroundDownloading: true
        )
        englishGermanTranslator?.downloadModelIfNeeded(with: conditions) { error in
            guard error == nil else { return }
            
            // Model downloaded successfully. Okay to start translating.
        }
        
        englishGermanTranslator?.translate(text) {
            translatedText, error in
            guard error == nil, let translatedText = translatedText else { return }
            
            print(translatedText)
            transText = translatedText
            print(self.transText, "1")
            // Translation succeeded.
        }
        print(transText, "2")
        return transText
        
    }
    
    //create text layer 
    private func createTextLayer(frame: CGRect, text: String, background: CGColor) -> CATextLayer{
        let textLayer = CATextLayer()
        textLayer.frame = frame
        textLayer.string = text
        textLayer.font = UIFont(name: "TrebuchetMS-Bold", size: 50)
        textLayer.fontSize = frame.height
        
        //rectangle background color
        textLayer.backgroundColor = background
        
        //text color
        textLayer.foregroundColor = UIColor.black.cgColor
        textLayer.isWrapped = true
        textLayer.alignmentMode = CATextLayerAlignmentMode.center
        textLayer.contentsScale = UIScreen.main.scale
        return textLayer
    }
<<<<<<< Updated upstream
=======

  private func createShapeLayer(frame: CGRect) -> CAShapeLayer {
    let bpath = UIBezierPath(rect: frame)
    let shapeLayer = CAShapeLayer()
    shapeLayer.path = bpath.cgPath
    shapeLayer.strokeColor = Constants.lineColor
    shapeLayer.fillColor = Constants.fillColor
    shapeLayer.lineWidth = Constants.lineWidth
    return shapeLayer
  }
  
  
  private func createScaledFrame(featureFrame: CGRect, imageSize: CGSize, viewFrame: CGRect) -> CGRect {
    let viewSize = viewFrame.size
    
    let resolutionView = viewSize.width / viewSize.height
    let resolutionImage = imageSize.width / imageSize.height
>>>>>>> Stashed changes
    
    private func createShapeLayer(frame: CGRect) -> CAShapeLayer {
        let bpath = UIBezierPath(rect: frame)
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = bpath.cgPath
        shapeLayer.strokeColor = Constants.lineColor
        shapeLayer.fillColor = Constants.fillColor
        shapeLayer.lineWidth = Constants.lineWidth
        return shapeLayer
    }
    
    private func createScaledFrame(featureFrame: CGRect, imageSize: CGSize, viewFrame: CGRect) -> CGRect {
        let viewSize = viewFrame.size
        
        let resolutionView = viewSize.width / viewSize.height
        let resolutionImage = imageSize.width / imageSize.height
        
        var scale: CGFloat
        if resolutionView > resolutionImage {
            scale = viewSize.height / imageSize.height
        } else {
            scale = viewSize.width / imageSize.width
        }
        
        let featureWidthScaled = featureFrame.size.width * scale
        let featureHeightScaled = featureFrame.size.height * scale
        
        let imageWidthScaled = imageSize.width * scale
        let imageHeightScaled = imageSize.height * scale
        let imagePointXScaled = (viewSize.width - imageWidthScaled) / 2
        let imagePointYScaled = (viewSize.height - imageHeightScaled) / 2
        
        let featurePointXScaled = imagePointXScaled + featureFrame.origin.x * scale
        let featurePointYScaled = imagePointYScaled + featureFrame.origin.y * scale
        
        return CGRect(x: featurePointXScaled, y: featurePointYScaled, width: featureWidthScaled, height: featureHeightScaled)
    }
    
    // MARK: - private
    
    private enum Constants {
        static let lineWidth: CGFloat = 3.0
        static let lineColor = UIColor.green.cgColor
        static let fillColor = UIColor.clear.cgColor
    }
}

