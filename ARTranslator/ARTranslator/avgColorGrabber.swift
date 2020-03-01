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

class avgColorGrabber: NSObject
{
    var image: CGImage
    var pixelData: CFData
    var data: UnsafePointer<UInt8>
    //    var context: CGContext // needed?


    // Initialize with an image, either a UIImage or CGImage will work
    public init(image: UIImage) // init with UIImage
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



    func getPixelColor(pos: CGPoint) -> UIColor
    {
        let pixelInfo: Int = ((Int(self.image.width) * Int(pos.y)) + Int(pos.x)) * 4

        let r = CGFloat(data[pixelInfo]) / CGFloat(255.0)
        let g = CGFloat(data[pixelInfo+1]) / CGFloat(255.0)
        let b = CGFloat(data[pixelInfo+2]) / CGFloat(255.0)
        let a = CGFloat(data[pixelInfo+3]) / CGFloat(255.0)

        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
}
