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
    var langcode=""
    var str=""
    var data="AUTO DETECT"
    //var pickerData: [String] = [String]()
    var yourArray = [String]()
    var languages=Set<String>()
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
      inputPicker.dataSource = self
      yourArray.append(data);
    for langCode in allLanguages{
        yourArray.append(langCode.toLanguageCode())
    }
   ///Change here to set Default
    inputPicker.selectRow(yourArray.firstIndex(of: "AUTO DETECT") ?? 0, inComponent: 0, animated: false)
    outputPicker.selectRow(allLanguages.firstIndex(of: TranslateLanguage.en) ?? 0, inComponent: 0, animated: false)
    
      inputPicker.delegate = self
      outputPicker.delegate = self
      //inputTextView.delegate = self
      //inputTextView.returnKeyType = .done
      pickerView(inputPicker, didSelectRow: 0, inComponent: 0)
    self.inputText.text="Settings"
    self.to.text="To"
    self.from.text="From"
    //      setDownloadDeleteButtonLabels()
    
      NotificationCenter.default.addObserver(self, selector:#selector(remoteModelDownloadDidComplete(notification:)), name:.firebaseMLModelDownloadDidSucceed, object:nil)
      NotificationCenter.default.addObserver(self, selector:#selector(remoteModelDownloadDidComplete(notification:)), name:.firebaseMLModelDownloadDidFail, object:nil)
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
      return 1
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return allLanguages[row].toLanguageCode()
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
      return allLanguages.count
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange,
                  replacementText text: String) -> Bool {
      // Hide the keyboard when "Done" is pressed.
      // See: https://stackoverflow.com/questions/26600359/dismiss-keyboard-with-a-uitextview
      if (text == "\n") {
        textView.resignFirstResponder()
        return false
      }
      return true
    }

    func textViewDidChange(_ textView: UITextView) {
//      translate()
//       language()
    }

    @IBAction func didTapSwap() {
      let inputSelectedRow = inputPicker.selectedRow(inComponent: 0)
      inputPicker.selectRow(outputPicker.selectedRow(inComponent: 0), inComponent: 0, animated: false)
      outputPicker.selectRow(inputSelectedRow, inComponent: 0, animated: false)
      inputTextView = outputTextView.text
      pickerView(inputPicker, didSelectRow: 0, inComponent: 0)
    }

    func model(forLanguage: TranslateLanguage) -> TranslateRemoteModel {
      return TranslateRemoteModel.translateRemoteModel(language: forLanguage)
    }

    func isLanguageDownloaded(_ language: TranslateLanguage) -> Bool {
      let model = self.model(forLanguage: language)
      let modelManager = ModelManager.modelManager()
      return modelManager.isModelDownloaded(model)
    }

    func handleDownloadDelete(picker: UIPickerView, button: UIButton) {
      let language = allLanguages[picker.selectedRow(inComponent: 0)]
      button.setTitle("working...", for: .normal)
      let model = self.model(forLanguage: language)
      let modelManager = ModelManager.modelManager()
      if modelManager.isModelDownloaded(model) {
        self.statusTextView.text = "Deleting " + language.toLanguageCode()
        modelManager.deleteDownloadedModel(model) { error in
          self.statusTextView.text = "Deleted " + language.toLanguageCode()
//          self.setDownloadDeleteButtonLabels()
        }
      } else {
        self.statusTextView.text = "Downloading " + language.toLanguageCode()
        let conditions = ModelDownloadConditions(
          allowsCellularAccess: true,
          allowsBackgroundDownloading: true
        )
        modelManager.download(model, conditions:conditions)
      }
    }

    @IBAction func didTapDownloadDeleteSourceLanguage() {
      self.handleDownloadDelete(picker: inputPicker, button: self.sourceDownloadDeleteButton)
    }
    
    @IBAction func translate(_ sender: Any) {
        language()
        translate()
    }
    
    @IBAction func didTapDownloadDeleteTargetLanguage() {
      self.handleDownloadDelete(picker: outputPicker, button: self.targetDownloadDeleteButton)
    }

    @IBAction func listDownloadedModels() {
      let msg = "Downloaded models:" + ModelManager.modelManager()
        .downloadedTranslateModels
        .map { model in model.language.toLanguageCode() }
        .joined(separator: ", ");
      self.statusTextView.text = msg
    }

    @objc
    func remoteModelDownloadDidComplete(notification: NSNotification) {
      let userInfo = notification.userInfo!
      guard let remoteModel =
        userInfo[ModelDownloadUserInfoKey.remoteModel.rawValue] as? TranslateRemoteModel else {
          return
      }
      DispatchQueue.main.async {
        if notification.name == .firebaseMLModelDownloadDidSucceed {
          self.statusTextView.text = "Download succeeded for " + remoteModel.language.toLanguageCode()
        } else {
          self.statusTextView.text = "Download failed for " + remoteModel.language.toLanguageCode()
        }
        //self.setDownloadDeleteButtonLabels()
      }
    }

//    func setDownloadDeleteButtonLabels() {
//      let inputLanguage = allLanguages[inputPicker.selectedRow(inComponent: 0)]
//      let outputLanguage = allLanguages[outputPicker.selectedRow(inComponent: 0)]
//      if self.isLanguageDownloaded(inputLanguage) {
//        self.sourceDownloadDeleteButton.setTitle("Delete", for: .normal)
//      } else {
//        self.sourceDownloadDeleteButton.setTitle("Download", for: .normal)
//      }
//      if self.isLanguageDownloaded(outputLanguage) {
//        self.targetDownloadDeleteButton.setTitle("Delete", for: .normal)
//      } else {
//        self.targetDownloadDeleteButton.setTitle("Download", for: .normal)
//      }
//    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        var inputLanguage = allLanguages[inputPicker.selectedRow(inComponent: 0)]
        if(inputLanguage.toLanguageCode()=="AUTO DETECT"){
            for item in allLanguages{
                if(item.toLanguageCode()==langcode){
                    inputLanguage=item
                    break
                }
            }
        }
      let outputLanguage = allLanguages[outputPicker.selectedRow(inComponent: 0)]
      //self.setDownloadDeleteButtonLabels()
      let options = TranslatorOptions(sourceLanguage: inputLanguage, targetLanguage: outputLanguage)
      translator = NaturalLanguage.naturalLanguage().translator(options: options)
      translate()
    }

    func translate() {
      let translatorForDownloading = self.translator!

      translatorForDownloading.downloadModelIfNeeded { error in
        guard error == nil else {
          self.outputTextView.text = "Failed to ensure model downloaded with error \(error!)"
          return
        }
//        self.setDownloadDeleteButtonLabels()
        if translatorForDownloading == self.translator {
         
           
            translatorForDownloading.translate(self.inputTextView ) { result, error in
            guard error == nil else {
              self.outputTextView.text = "Failed with error \(error!)"
              return
            }
            if translatorForDownloading == self.translator {
              self.outputTextView.text = result
                print(result!)
            }
          }
        }
      }
    }
    
    @IBAction func language() {
        languageId.identifyLanguage(for: inputTextView) { (languageCode, error) in
          if let error = error {
            self.langcode = "Failed with error: \(error)"
            return
          }
          if let languageCode = languageCode {
            self.langcode = languageCode
          } else {
            self.langcode = "No language was identified"
          }
            self.setString()
            self.detect()
//           _ sender: Any
        }
    }
    
    func setString(){
        if self.langcode=="en" {
            str="English"
        }else if self.langcode=="fr" {
            str="French"
        }else if self.langcode=="ar"{
            str="Arabic"
        }else if self.langcode=="de"{
            str="German"
        }else{
            str="Unknown"
        }
    }
    
    
    @IBAction func detect() {
        //var err="";
    languageId.identifyPossibleLanguages(for: inputTextView) {
        (identifiedLanguages, error) in
        if let error = error {
            self.detectLang.text = "Failed with error: \(error)"
          return
        }
        guard let identifiedLanguages = identifiedLanguages, !identifiedLanguages.isEmpty else {
            self.detectLang.text = "No language was identified"
          return
        }

        self.detectLang.text = "Identified Languages:\n" +
          identifiedLanguages.map {
            let code=$0.languageCode;
            let conf=Int($0.confidence*100);
            self.languages.insert(code)
            return String(format: "(%@, %d)", code, conf)
            }.joined(separator: "\t");
      }
        print(self.languages)
    }
  }
