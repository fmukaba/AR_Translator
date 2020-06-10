//
//  avgColorGrabber.swift
//  ARTranslator
//
//  Created by Evan Johnson on 24/2/20.
//  Copyright © 2020 Francois Mukaba. All rights reserved.
//

import Foundation
import UIKit
import CoreGraphics
import CoreImage


// INTENDED USAGE:

// initialize an avgColorGrabber object with an image
// make repeated calls to instanciated object with getAvgRectColor(rect: CGRect)
// when finished with the image, free this object and create a new one OR:
// call changeImage() to change the image.  changeImage() and init() are both compatible
// with EITHER a UIImage or CGImage for convenience

class avgColorGrabber: NSObject
{
    var image: CGImage
    var pixelData: CFData
    var data: UnsafePointer<UInt8>
    //    var context: CGContext // needed?

    // Initialize with an image, either a UIImage or CGImage will work
    init(image: UIImage) // init with UIImage
    {
        self.image = image.cgImage!
        pixelData = self.image.dataProvider!.data!
        data = CFDataGetBytePtr(pixelData)
    }
    init(image: CGImage) // init with CGImage
    {
        self.image = image
        pixelData = self.image.dataProvider!.data!
        data = CFDataGetBytePtr(pixelData)
    }
    
    func changeImage(image: UIImage)
    {
        self.image = image.cgImage!
        pixelData = self.image.dataProvider!.data!
        data = CFDataGetBytePtr(pixelData)
    }
    func changeImage(image: CGImage)
    {
        self.image = image
        pixelData = self.image.dataProvider!.data!
        data = CFDataGetBytePtr(pixelData)
    }



    func getPixelColor(pos: CGPoint) -> UIColor
    {
        let pixelInfo: Int = ((Int(self.image.width) * Int(pos.y)) + Int(pos.x)) * 4

        let r = CGFloat(data[pixelInfo]) / CGFloat(255.0)
        let g = CGFloat(data[pixelInfo+1]) / CGFloat(255.0)
        let b = CGFloat(data[pixelInfo+2]) / CGFloat(255.0)
        let a = CGFloat(data[pixelInfo+3]) / CGFloat(255.0)

        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
    
    func getAvgRectColor(rect: CGRect) -> UIColor
    {
       
        let x0 = UInt32(rect.minX)
        let y0 = UInt32(rect.minY)
        let x1 = UInt32(rect.maxX)
        let y1 = UInt32(rect.maxY)

        
        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 0.0

        var count: UInt32 = 0
        var pixelInfo: Int
        
        
        for X in x0...x1
        {
            for Y in y0...y1
            {
                pixelInfo = ((Int(self.image.width) * Int(Y)) + Int(X)) * 4

                r += CGFloat(data[pixelInfo]) / CGFloat(255.0)
                g += CGFloat(data[pixelInfo+1]) / CGFloat(255.0)
                b += CGFloat(data[pixelInfo+2]) / CGFloat(255.0)
                a += CGFloat(data[pixelInfo+3]) / CGFloat(255.0)
                
                count += 1
            }
        }
        
        
        let color = UIColor(red: r/CGFloat(count), green: g/CGFloat(count), blue: b/CGFloat(count), alpha: a/CGFloat(count))
        
        return color
    }
    
}
