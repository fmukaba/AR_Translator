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
    var imageView:UIImageView
    var image:UIImage
    
    let colorGrabber: avgColorGrabber
    
    init(imageView:UIImageView)
    {
        self.imageView = imageView
        self.image = self.imageView.image!
        self.colorGrabber = avgColorGrabber(image: self.image)
    }
    
    func addElement(rect:CGRect, text:String) -> Void
    {
        drawToImage(rect: rect, text: text)
        
        //drawRectangleOnImage(rect: rect) // add CGRect with avgColorGrabber background color to image
        //textToImage(drawText: text, inRect: rect) // add text
        
        self.imageView.image = self.image
        // TODO combine above later
    }
    private func drawRectangleOnImage(rect: CGRect) -> Void
    {
        let scale: CGFloat = 0
        UIGraphicsBeginImageContextWithOptions(self.image.size, false, scale)
        
        self.image.draw(at: CGPoint.zero) // leave the draw(at) point at 0,0? verify with testing
        // let rectangle = CGRect(x: 0, y: (imageSize.height/2) - 30, width: imageSize.width, height: 60)
        
        self.colorGrabber.getAvgRectColor(rect: rect).setFill()
        UIRectFill(rect)
        
        // DONE
        
        self.image = UIGraphicsGetImageFromCurrentImageContext()!
        print("++ DEBUG overwritten image with rect")
        UIGraphicsEndImageContext()
    }
    
    private func textToImage(drawText text: String, inRect rect: CGRect) -> Void
    {
        let scale: CGFloat = 0
        UIGraphicsBeginImageContextWithOptions(self.image.size, false, scale)
        
        let textFont = UIFont(name: "TrebuchetMS-Bold", size: 50)! // set dynamically ?
        let textColor = UIColor.black
        // let backgroundColor = self.colorGrabber.getAvgRectColor(rect: rect) // DO THIS LATER
        
        let textFontAttributes = [
            NSAttributedString.Key.font: textFont,
            NSAttributedString.Key.foregroundColor: textColor,
            ] as [NSAttributedString.Key : Any]
        
        self.image.draw(in: CGRect(origin: CGPoint.zero, size: self.image.size))
        
        // let rectOLD = CGRect(origin: point, size: self.image.size)
        
        text.draw(in: rect, withAttributes: textFontAttributes)
        
        // DONE
        
        self.image = UIGraphicsGetImageFromCurrentImageContext()!
        print("++ DEBUG overwritten image with text\n")
        UIGraphicsEndImageContext()
    }
    
    private func drawToImage(rect:CGRect, text:String)
    {
        print("++ DEBUG addElement text: \(text)")
        
        let scale: CGFloat = 0
        UIGraphicsBeginImageContextWithOptions(self.image.size, false, scale)
        
        let backgroundColor = self.colorGrabber.getAvgRectColor(rect: rect)
        
        let tempColor = backgroundColor.cgColor
        
        var textColor = UIColor.black
        if(max(tempColor.components![0], tempColor.components![1], tempColor.components![2]) < 0.65)
        {
            textColor = UIColor.white
        }
        
        let textFont = UIFont(name: "TrebuchetMS-Bold", size: rect.height * 0.9)! // set dynamically ?
        
        let textFontAttributes = [
            NSAttributedString.Key.font: textFont,
            NSAttributedString.Key.foregroundColor: textColor,
            ] as [NSAttributedString.Key : Any]
        
        self.image.draw(at: CGPoint.zero) // leave the draw(at) point at 0,0? verify with testing
        
        backgroundColor.setFill()
        UIRectFill(rect)
        
        text.draw(in: rect, withAttributes: textFontAttributes)
        
        self.image = UIGraphicsGetImageFromCurrentImageContext()!
        print("++ DEBUG image overwritten\n")
        UIGraphicsEndImageContext()
        
    }
    
    
}

