//
//  translationViewController.swift
//  ARTranslator
//
//  Created by Muluh Nkengla on 4/23/20.
//  Copyright © 2020 Francois Mukaba. All rights reserved.
//

import Foundation
//
//  ViewController.swift
//  Translation
//
//  Created by Muluh Nkengla on 1/27/20.
//  Copyright © 2020 Muluh Nkengla. All rights reserved.
//

import UIKit
import Firebase

class translationViewController: UIViewController, UITextViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate {

  //  @IBOutlet var detectLang: UITextField!
    @IBOutlet var detectLang: UILabel!
    
    lazy var languageId = NaturalLanguage.naturalLanguage().languageIdentification()
    //var str=""
    //var pickerData: [String] = [String]()
    
    var codeFrom=""
    var codeTo=""
    var output=""
    var pickerData1: [String] = [String]()

    var pickerData2: [String] = [String]()
    
    var text="I am going to school"
    
    @IBOutlet var to: UILabel!
    @IBOutlet var from: UILabel!
        
    //@IBOutlet var inputTextView: UITextView!
    var inputTextView=""
    @IBOutlet var outputTextView: UITextView!
    @IBOutlet var statusTextView: UITextView!
      
    @IBOutlet var inputPicker: UIPickerView!
    @IBOutlet var outputPicker: UIPickerView!
    @IBOutlet var inputText: UILabel!
    
    @IBOutlet  var sourceDownloadDeleteButton: UIButton!
    
    @IBOutlet var targetDownloadDeleteButton: UIButton!

  var translator: Translator!
    
  lazy var allLanguages = TranslateLanguage.allLanguages().compactMap {
    TranslateLanguage(rawValue: $0.uintValue)
  }

  override func viewDidLoad() {
      super.viewDidLoad()
       //inputTextView.text = "Type here"
      //print(allLanguages)
       pickerData1.append("Detect Language")
       for str in allLanguages{
           pickerData1.append(str.toLanguageCode())
           pickerData2.append(str.toLanguageCode())
       }
       inputPicker.delegate = self
       inputPicker.tag = 1
       outputPicker.tag = 2
       inputPicker.dataSource = self
       outputPicker.delegate = self
       outputPicker.dataSource = self
    self.inputText.text="Settings"
    self.to.text="To"
    self.from.text="From"
    //      setDownloadDeleteButtonLabels()
    
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
      return 1
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == 1 {
            
            if pickerData1[row] == "Detect Language" {
                languageID()
            }else{
                codeFrom = pickerData1[row]
            }
            //display()
            
            return pickerData1[row]
        } else {
            codeTo = pickerData2[row]
        }
        //display()
        return pickerData2[row]
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
      if pickerView.tag == 1 {
          return pickerData1.count;
      }
      return pickerData2.count
    }

    func languageID(){
        languageId.identifyLanguage(for: text) { (languageCode, error) in
          if let error = error {
            self.output = "Failed with error: \(error)"
            return
          }

          if let languageCode = languageCode {
            self.codeFrom=languageCode
            self.output = "Language Code From: \(self.codeFrom) \n Language Code To: \(self.codeTo)"
          } else {
            self.output = "No language was identified"
          }
        }
    }
    
    
    @IBAction func language() {
        languageId.identifyLanguage(for: text) { (languageCode, error) in
          if let error = error {
            self.codeFrom = "Failed with error: \(error)"
            return
          }
          if let languageCode = languageCode {
            self.codeFrom = languageCode
          } else {
            self.codeFrom = "No language was identified"
          }
            //self.setString()
            //self.detect()
//           _ sender: Any
        }
    }
}
