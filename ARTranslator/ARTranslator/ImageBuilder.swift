//
//  ImageBuilder.swift
//  ARTranslator
//
//  Created by Evan Johnson on 08/6/20.
//  Copyright © 2020 Francois Mukaba. All rights reserved.
//

import Foundation
import Firebase

var ImageBuilderSemaphore = DispatchSemaphore(value: 0)

class ImageBuilder
{
    let vision = Vision.vision()
    
    var imageView:UIImageView
    var image:UIImage
    var textRecognizer: VisionTextRecognizer!
    
    //translated text
    var transText = ""
    
    init(imageView: UIImageView)
    {
        self.imageView = imageView
        self.image = imageView.image!
        
        textRecognizer = vision.onDeviceTextRecognizer()
    }
    
    
    func process()
    {
        let elementAdder = ImageElementAdder.init(imageView: imageView)
        
        let visionImage = VisionImage(image: image)
                
        textRecognizer.process(visionImage) { result, error in
            guard error == nil, let result = result, !result.text.isEmpty else {
                return
            }
            
            for block in result.blocks
            {
                for line in block.lines
                {
                    
                    // creates CGrect for use in CALayer [REMOVED FOR NEW IMAGE BUILDER]
                    // let frame = self.createScaledFrame(featureFrame: line.frame, imageSize: image.size, viewFrame: imageView.frame)
                    
                    // UNNEEDED, USED IN ImageElementAdder.swift
                    // let backgroundColor = colorGrabber.getAvgRectColor(rect: line.frame).cgColor
                    
                    //create the actual shapelayer
                    //let shapeLayer = self.createShapeLayer(frame: frame)
                    
                    let detectedText = line.text
                    print(">> DEBUG DETECTED TEXT: \(detectedText)")
                    
                    // HOLY CODE - DO NOT TOUCH
                    DispatchQueue.global().async {
                        self.translateString_MK3(text: detectedText)
                        // self.translateStringNEW(text: detectedText)
                    }
                    semaphore.wait()
                    // HOLY CODE - DO NOT TOUCH
                    
                    print(">> DEBUG TRANSLATED TEXT: \(self.transText)")
                    
                    // ADD RECTANGLE AND TEXT TO IMAGE
                    
                    // let textLayer = self.createTextLayer(frame: frame, text: self.transText, background: backgroundColor)
                    // let scaledElement = ScaledElement(frame: frame, shapeLayer: shapeLayer, textLayer: textLayer)
                    // scaledElements.append(scaledElement)
                    
                    elementAdder.addElement(rect: line.frame, text: self.transText)
                    
                }
            }
        }
        print("==DEBUG IMAGE RETURNED")
    }
    
    
    private func translateString_MK3(text:String)
    {
        // input the text to be trainslated
        TranslationManager.shared.textToTranslate = text
        
        // input the languages to translate to/from
        // TranslationManager.shared.sourceLanguageCode = "en" // DEPRECIATED REMOVE WHEN MULUH'S CODE WORKS
        // TranslationManager.shared.targetLanguageCode = "de" // DEPRECIATED REMOVE WHEN MULUH'S CODE WORKS
        
        print("FROM LANG: \(TranslationManager.shared.sourceLanguageCode!)")
        print("TO LANG: \(TranslationManager.shared.targetLanguageCode!)")
        
        
        
        // HOLY CODE - DO NOT TOUCH
        
        // send the translation request to GT and update the output field with the result
        TranslationManager.shared.translate(completion: { (translation) in
            
            if let translation = translation {
                DispatchQueue.global().async { [unowned self] in
                    self.transText = translation
                    semaphore.signal()
                    //print("DEBUG TRANSLATION: \(translation)" )
                }
            }
        })
        
        // HOLY CODE - DO NOT TOUCH
        
    }
    
    
}
