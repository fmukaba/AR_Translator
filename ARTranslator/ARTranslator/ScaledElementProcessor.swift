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

typealias transCallback = (String) -> Void

var semaphore = DispatchSemaphore(value: 0)


class ScaledElementProcessor
{
    
    let vision = Vision.vision()
    var textRecognizer: VisionTextRecognizer!
    
    //translated text
    var transText = ""
    
    //translator
    var translator: Translator!
    var englishGermanTranslator : Translator?
    
    //initialize with the translator change later so that it initalize with user
    //picked language
    init()
    {
        textRecognizer = vision.onDeviceTextRecognizer()
        let options = TranslatorOptions(sourceLanguage: .en, targetLanguage: .de)
        englishGermanTranslator = NaturalLanguage.naturalLanguage().translator(options: options)
    }
    
    func process(in imageView: UIImageView, callback: @escaping (_ text: String, _ scaledElements: [ScaledElement]) -> Void)
    {
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
            for block in result.blocks
            {
                for line in block.lines
                {
                    
                    //the CGrect
                    let frame = self.createScaledFrame(featureFrame: line.frame, imageSize: image.size, viewFrame: imageView.frame)
                    
                    //get the avg color of cgrect
                    let backgroundColor = colorGrabber.getAvgRectColor(rect: line.frame).cgColor
                    
                    //create the actual shapelayer
                    let shapeLayer = self.createShapeLayer(frame: frame)
                    
                    //get the text
                    let detectedText = line.text
                    //print out detected text
                    print(line.text, ":detected text")
                    
                    //translated text
                    //need to change
                    //let translatedDetectedText = self.translateString(text: detectedText)
                    
                    
                    
//                    DispatchQueue.global().async {
//                        self.translateString_MK3(text: detectedText)
//                    }
                    
                    
                    

                    DispatchQueue.global().async {
                    self.translateString_MK3(text: detectedText)
                    // self.translateStringNEW(text: detectedText)
                    }
                    
                    semaphore.wait()
                    
                    print("--DEBUG: \(self.transText)")
                    
                    //test to see if func that translates text is working
                    //need to change
                    //print(translatedDetectedText, ":Translated Text in element loop")
                    print(self.transText, ":Translated Text in element loop")
                    
                    //actual UI changes here
                    //set textlayer
                    //need to change
                    
                    
                    let textLayer = self.createTextLayer(frame: frame, text: self.transText, background: backgroundColor)
                    
                    //create scaled Element
                    let scaledElement = ScaledElement(frame: frame, shapeLayer: shapeLayer, textLayer: textLayer)
                    
                    scaledElements.append(scaledElement)
                    
                }
            }
            
            callback(result.text, scaledElements)
        }
    }
    
    
    //new translate text function
    private func translateStringNEW(text: String)
    {
        let conditions = ModelDownloadConditions(allowsCellularAccess: false, allowsBackgroundDownloading: true)
        
         englishGermanTranslator?.downloadModelIfNeeded(with: conditions, completion: { error in
            guard error == nil else { return }
        })
        
        
        self.englishGermanTranslator?.translate(text, completion: { (result, error) in
            guard error == nil else { return }
            
            if let result = result {
                
                DispatchQueue.global().async { [unowned self] in
                    self.transText = result
                    semaphore.signal()
                    print("DEBUG TRANSLATION: \(result)" )
                }
            }
        })
        
    }
    
    private func translateString_MK3(text:String)
    {
        // input the text to be trainslated
        TranslationManager.shared.textToTranslate = text
        
        // input the languages to translate to/from
        TranslationManager.shared.sourceLanguageCode = "en"
        TranslationManager.shared.targetLanguageCode = "de"
        
        // send the translation request to GT and update the output field with the result
        TranslationManager.shared.translate(completion: { (translation) in
            
            if let translation = translation {
                
                DispatchQueue.global().async { [unowned self] in
                    self.transText = translation
                    semaphore.signal()
                    print("DEBUG TRANSLATION: \(translation)" )
                }
            }
        })

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
<<<<<<< HEAD
        print(transText, "2")
        return transText
=======
        
        return finalText
        
>>>>>>> fx_merge
    }
    
    //create text layer
     func createTextLayer(frame: CGRect, text: String, background: CGColor) -> CATextLayer{
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
     func createShapeLayer(frame: CGRect) -> CAShapeLayer {
        let bpath = UIBezierPath(rect: frame)
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = bpath.cgPath
        shapeLayer.strokeColor = Constants.lineColor
        shapeLayer.fillColor = Constants.fillColor
        shapeLayer.lineWidth = Constants.lineWidth
        return shapeLayer
    }
    
    
    
    //create and return the CGRect
     func createScaledFrame(featureFrame: CGRect, imageSize: CGSize, viewFrame: CGRect) -> CGRect {
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
