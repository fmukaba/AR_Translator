//
//  ViewController.swift
//  ImagePickerTutorial
//
//  Created by Reina S on 11/12/19.
//  Copyright © 2019 com.test. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //the UI image view
    @IBOutlet var imageView: UIImageView!
    
    //view controller that manages system interfaces for taking pictures, recording movies, and choosing items from the user's media library.
    let imagePicker = UIImagePickerController()

    
    //action when the load image button is tapped
    @IBAction func loadImageButtonTapped(_ sender: UIButton) {
        
        imagePicker.allowsEditing = false
        
        //getting photo from photo library
        imagePicker.sourceType = .photoLibrary
        
        //present the image that is picked onto the UIimageview
        present(imagePicker, animated: true, completion: nil)
    }
    
    
    //Called after the controller's view is loaded into memory
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        // Do any additional setup after loading the view.
    }
    
    
    
    //Tells the delegate that the user picked a still image or movie.
    //picker will manage the image picker interface
    //info A dictionary containing the original image and the edited image
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            //fitting the image to the image view UI
            imageView.contentMode = .scaleAspectFit
            
            //setting the selected image as the image view UI
            imageView.image = pickedImage
            
        }
        
        //Dismisses view controller that was presented modally by the view controller
        dismiss(animated: true, completion: nil)
    }
    
    //if the user cancels picking an image 
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }


}

