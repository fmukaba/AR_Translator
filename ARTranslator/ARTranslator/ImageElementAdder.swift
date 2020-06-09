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
    var imageSize: CGSize
    let colorGrabber: avgColorGrabber
    
    init(image:UIImage)
    {
        self.image = image
        self.imageSize = self.image.size
        self.colorGrabber = avgColorGrabber(image: image)
    }
    
    func addElement(rect:CGRect, text:String) -> Void
    {
        // add CGRect with avgColorGrabber background color to image
        // add text
    }
    
    func getImage() -> UIImage
    {
        return self.image
    }
    
    private func drawRectangleOnImage(rect: CGRect) -> Void
    {
        let scale: CGFloat = 0
        UIGraphicsBeginImageContextWithOptions(self.imageSize, false, scale)
        
        self.image.draw(at: CGPoint.zero) // leave the draw(at) point at 0,0? verify with testing
        
        // let rectangle = CGRect(x: 0, y: (imageSize.height/2) - 30, width: imageSize.width, height: 60)
        
        self.colorGrabber.getAvgRectColor(rect: rect).setFill()
        UIRectFill(rect)
        
        self.image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
    }
    
    func textToImage(drawText text: String, inImage image: UIImage, atPoint point: CGPoint) -> Void
    {
        let textColor = UIColor.black
        let textFont = UIFont(name: "Helvetica Bold", size: 12)! // set dynamically ?
        
        let scale: CGFloat = 0
        UIGraphicsBeginImageContextWithOptions(self.imageSize, false, scale)
        
        let textFontAttributes = [
            NSAttributedString.Key.font: textFont,
            NSAttributedString.Key.foregroundColor: textColor,
            ] as [NSAttributedString.Key : Any]
        
        image.draw(in: CGRect(origin: CGPoint.zero, size: image.size))
        
        let rect = CGRect(origin: point, size: image.size)
        text.draw(in: rect, withAttributes: textFontAttributes)
        
        self.image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
    }
    
}

