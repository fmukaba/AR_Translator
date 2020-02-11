//
//  ViewController.swift
//  ARTranslator
//
//  Created by Francois Mukaba on 1/22/20.
//  Copyright © 2020 Francois Mukaba. All rights reserved.

import UIKit
import FirebaseMLVision
import FirebaseMLNLTranslate


class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate  {

    @IBOutlet weak var imageview: UIImageView!
    var imagePicker: UIImagePickerController!
    let vision = Vision.vision()
    var textRecognizer: VisionTextRecognizer!
    var textDetected: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        textRecognizer = vision.onDeviceTextRecognizer()
    }


    @IBAction func takePhoto(_ sender: Any) {
        imagePicker =  UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func save(_ sender: Any) {
        guard let image = imageview.image else { return }

        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    //MARK: - Add image to Library
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
            let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        } else {
            let ac = UIAlertController(title: "Saved!", message: "Your altered image has been saved to your photos.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
    //MARK: - image capture
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
           imagePicker.dismiss(animated: true, completion: nil)
           imageview.image = info[.originalImage] as? UIImage
       }
    
    @IBAction func gallery(_ sender: Any) {
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    //MARK: - Text detection
    @IBAction func extractBtn(_ sender: Any) {
        launchExtraction()
    }
    
    func launchExtraction() {
        guard let image = imageview.image else { return } // raise an exception
        let visionImage = VisionImage(image: image)
        
        textRecognizer.process(visionImage) {(features, errors) in
             
            self.textDetected = features?.text ?? ""
            //print(self.textDetected!)
            
            for block in features!.blocks {
            // line by line
                for line in block.lines {
                    // word by word
                    for element in line.elements {
                        print(element.text, " " )
                    }
                }
            }
            
            // get translated text
            // self.translateToFrench(text: self.scanned)
            // overlay translation
                  
            // get block by block
                  
            }
    }
    
    @IBAction func shareBtn(_ sender: Any) {
        shareText()
    }
    
    
    func shareText() {
      let vc = UIActivityViewController(
        activityItems: [textDetected ?? ""],
        applicationActivities: [])

      present(vc, animated: true, completion: nil)
    }
}
