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
    //var transText = ""
    
    //translator
    var translator: Translator!
    var englishGermanTranslator : Translator?
    
    //initialize with the translator change later so that it initalize with user
    //picked language 
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
                        let backgroundColor = colorGrabber.getAvgRectColor(rect: element.frame).cgColor
                        
                        //create the actual shapelayer
                        let shapeLayer = self.createShapeLayer(frame: frame)
                        
                        //get the text
                        let detectedText = element.text
                        //print out detected text
                        print(element.text, ":detected text")
                        
                        //translated text
                        let translatedDetectedText = self.translateString(text: detectedText)
                        
                        //test to see if func that translates text is working
                        print(translatedDetectedText, ":Translated Text in element loop")
                        
                        //actual UI changes here
                        //set textlayer
                        let textLayer = self.createTextLayer(frame: frame, text: translatedDetectedText, background: backgroundColor)
                        
                        //create scaled Element
                        let scaledElement = ScaledElement(frame: frame, shapeLayer: shapeLayer, textLayer: textLayer)
                        
                        scaledElements.append(scaledElement)
                        
                    }
                }
            }
            
            callback(result.text, scaledElements)
        }
    }
    
    //translate text
    private func translateString(text: String) -> String{
        
        var finalText = "";
        
        let conditions = ModelDownloadConditions(
            allowsCellularAccess: false,
            allowsBackgroundDownloading: true
        )
        englishGermanTranslator?.downloadModelIfNeeded(with: conditions) { error in
            guard error == nil else { return }
            
        }
        
        englishGermanTranslator?.translate(text) {
            translatedText, error in
            guard error == nil, let translatedText = translatedText else { return }
            
            //set global variable "transText" to our translated text
            //self.transText = translatedText
            
            finalText = translatedText
        }
        
        return finalText
        
    }
    
    //create text layer 
    private func createTextLayer(frame: CGRect, text: String, background: CGColor) -> CATextLayer{
        let textLayer = CATextLayer()
        textLayer.frame = frame
        textLayer.string = text
        //change font size to dynamic
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

    
    //create the CAShapeLayer
    private func createShapeLayer(frame: CGRect) -> CAShapeLayer {
        let bpath = UIBezierPath(rect: frame)
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = bpath.cgPath
        shapeLayer.strokeColor = Constants.lineColor
        shapeLayer.fillColor = Constants.fillColor
        shapeLayer.lineWidth = Constants.lineWidth
        return shapeLayer
    }
    
    //create and return the CGRect
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
    
    //constants for the color of the cgrect border
    private enum Constants {
        static let lineWidth: CGFloat = 3.0
        static let lineColor = UIColor.green.cgColor
        static let fillColor = UIColor.clear.cgColor
    }
}

