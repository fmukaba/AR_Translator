//
//  ImageElementAdder.swift
//  ARTranslator
//
//  Created by Evan Johnson on 08/6/20.
//  Copyright © 2020 Francois Mukaba. All rights reserved.
//

import Foundation
import UIKit
import CoreGraphics
import CoreImage


class ImageElementAdder
{
    var image: UIImage
    let colorGrabber: avgColorGrabber
    
    init(image:UIImage)
    {
        self.image = image
        self.colorGrabber = avgColorGrabber(image: image)
    }
    
    func addElement(rect:CGRect, text:String) -> Void
    {
        drawRectangleOnImage(rect: rect) // add CGRect with avgColorGrabber background color to image

        textToImage(drawText: text, inRect: rect) // add text
        
        // TODO combine above later
    }
    
    func getImage() -> UIImage
    {
        return self.image
    }
    
    private func drawRectangleOnImage(rect: CGRect) -> Void
    {
        let scale: CGFloat = 0
        UIGraphicsBeginImageContextWithOptions(self.image.size, false, scale)
        
        self.image.draw(at: CGPoint.zero) // leave the draw(at) point at 0,0? verify with testing
        
        // let rectangle = CGRect(x: 0, y: (imageSize.height/2) - 30, width: imageSize.width, height: 60)
        
        
        self.colorGrabber.getAvgRectColor(rect: rect).setFill()
        UIRectFill(rect)
        
        self.image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
    }
    
    func textToImage(drawText text: String, inRect rect: CGRect) -> Void
    {
        let textFont = UIFont(name: "TrebuchetMS-Bold", size: 50)! // set dynamically ?
        
        let scale: CGFloat = 0
        UIGraphicsBeginImageContextWithOptions(self.image.size, false, scale)
        
        
        let textColor = UIColor.black
        // let backgroundColor = self.colorGrabber.getAvgRectColor(rect: rect) // DO THIS LATER
        
        let textFontAttributes = [
            NSAttributedString.Key.font: textFont,
            NSAttributedString.Key.foregroundColor: textColor,
            ] as [NSAttributedString.Key : Any]
        
        self.image.draw(in: CGRect(origin: CGPoint.zero, size: self.image.size))
        
        // let rectOLD = CGRect(origin: point, size: self.image.size)
        
        text.draw(in: rect, withAttributes: textFontAttributes)
        
        self.image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
    }
    
}

