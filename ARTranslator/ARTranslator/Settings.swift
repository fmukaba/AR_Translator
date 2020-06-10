import Foundation
import UIKit
import Firebase


class Settings: UIViewController, UITextViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate {

    //@IBOutlet var detectLang: UILabel!

    lazy var languageId = NaturalLanguage.naturalLanguage().languageIdentification()
    var supportedLanguages = [TranslationLanguage]()
    var codeFrom=""
    var codeTo=""
    var output=""
    var pickerData1: [String] = [String]()
    var pickerData2: [String] = [String]()
    
    
    @IBOutlet var detectLang: UILabel!
    @IBOutlet var outputPicker: UIPickerView!
    @IBOutlet var inputPicker: UIPickerView!
    @IBOutlet var inputText: UILabel!

  lazy var allLanguages = TranslateLanguage.allLanguages().compactMap {
    TranslateLanguage(rawValue: $0.uintValue)
  }
    
//     TranslationManager.shared.fetchSupportedLanguages(completion: { (success) in if (success) {
//       // self.supportedLanguages=TranslationManager.shared.supportedLanguages
//        self.copyIntoArray()
//    } else {
//        } })
    
    
  override func viewDidLoad() {
   // super.viewDidLoad();
    inputPicker.delegate = self
    inputPicker.tag = 1
    outputPicker.tag = 2
    inputPicker.dataSource = self
    outputPicker.delegate = self
    outputPicker.dataSource = self
    pickerData1.append("Detect Language")
    for key in emptyDict.keys{
        pickerData1.append(key)
        pickerData2.append(key)
    }
//    TranslationManager.shared.fetchSupportedLanguages(completion: { (success) in if (success) {
//       // self.supportedLanguages=TranslationManager.shared.supportedLanguages
//        print("DEBUG")
//        self.copyIntoArray()
//        print("DEBUG")
//    } else {
//
//        } })

    //self.copyIntoArray()
    //self.inputText.text="Settings"
    //self.to.text="To"
    //self.from.text="From"
    //      setDownloadDeleteButtonLabels()
//    inputPicker.delegate = self
//    inputPicker.tag = 1
//    outputPicker.tag = 2
//    inputPicker.dataSource = self
//    outputPicker.delegate = self
//    outputPicker.dataSource = self
    
    }
    
    func copyIntoArray(){
        for str in TranslationManager.shared.supportedLanguages{
            let name=str.name ?? "Empty"
            print("\(str.name!)\t\(str.code!)")
            self.pickerData1.append(name)
           // self.pickerData2.append(str.name ?? "")
        }
        
        for eng in self.pickerData1{
            print(eng)
        }
       // pickerData1.append("Detect Language")
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
      return 1
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == 1 {
            if pickerData1[row] == "Detect Language" {
                languageID()
            }else{
                self.detectLang.text = "Identified Language: "
                codeFrom = pickerData1[row]
                TranslationManager.shared.sourceLanguageCode=emptyDict[codeFrom]
            }
            //display()
            return pickerData1[row]
        } else {
            codeTo = pickerData2[row]
     TranslationManager.shared.targetLanguageCode=emptyDict[codeTo]
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
        var text = "Love"
        languageId.identifyLanguage(for: text) { (languageCode, error) in
          if let error = error {
            self.output = "Failed with error: \(error)"
            return
          }
          if let languageCode = languageCode {
            TranslationManager.shared.sourceLanguageCode=languageCode
            var language=""
            for key in self.emptyDict.keys{
                if self.emptyDict[key] == languageCode {
                    language=key
                    break
                }
            }
            self.detectLang.text = "Identified Language: \(language)"
          } else {
            self.detectLang.text = "No language was identified"
          }
        }
    }
    
    
    var emptyDict: [String: String]  = ["Afrikaans" : "af",
    "Albanian" : "sq",
    "Amharic" : "am",
    "Arabic" : "ar",
    "Armenian" : "hy",
    "Azerbaijani" : "az",
    "Basque" : "eu",
    "Belarusian" :  "be",
    "Bengali"  :  "bn",
    "Bosnian"   : "bs",
    "Bulgarian"  :  "bg",
    "Catalan"   : "ca",
    "Cebuano"  :  "ceb",
    "Chichewa"   : "ny",
    "Chinese(Simplified)"  :  "zh-CN",
    "Chinese(Traditional)"  :  "zh-TW",
    "Corsican"  :  "co",
    "Croatian"  : "hr",
    "Czech"  :  "cs",
    "Danish"  :  "da",
    "Dutch"  :  "nl",
    "English"  :  "en",
    "Esperanto"  :  "eo",
    "Estonian"   : "et",
    "Filipino"  :  "tl",
    "Finnish"  :  "fi",
    "French"  :  "fr",
    "Frisian"   : "fy",
    "Galician"  :  "gl",
    "Georgian"  :  "ka",
    "German"  :  "de",
    "Greek"  :  "el",
    "Gujarati"  :  "gu",
    "Haitian Creole"  :  "ht",
    "Hausa"  :  "ha",
    "Hawaiian"  :  "haw",
    "Hebrew"  :  "iw",
    "Hindi"  :  "hi",
    "Hmong"  :  "hmn",
    "Hungarian"  :  "hu",
    "Icelandic"  :  "is",
    "Igbo"  :  "ig",
    "Indonesian"  :  "id",
    "Irish"  :  "ga",
    "Italian"  :  "it",
    "Japanese"  :  "ja",
    "Javanese"  :  "jw",
    "Kannada"  :  "kn",
    "Kazakh"  :  "kk",
    "Khmer"  :  "km",
    "Kinyarwanda" :  "rw",
    "Korean"  :  "ko",
    "Kurdish (Kurmanji)" : "ku",
    "Kyrgyz"  : "ky",
    "Lao"  :  "lo",
    "Latin"  :  "la",
    "Latvian"  :  "lv",
    "Lithuanian"  :"lt",
    "Luxembourgish"  :  "lb",
    "Macedonian"  :   "mk",
    "Malagasy"  :  "mg",
    "Malay"  :  "ms",
    "Malayalam"  :  "ml",
    "Maltese"  :  "mt",
    "Maori"  :  "mi",
    "Marathi" :  "mr",
    "Mongolian"  :  "mn",
    "Myanmar : (Burmese)"  :  "my",
    "Nepali"  :  "ne",
    "Norwegian"  :  "no",
    "Odia (Oriya)"  :  "or",
    "Pashto"  :  "ps",
    "Persian"  :  "fa",
    "Polish"  :  "pl",
    "Portuguese"  :  "pt",
    "Punjabi"  :  "pa",
    "Romanian"  :  "ro",
    "Russian"  :  "ru",
    "Samoan"  :  "sm",
    "Scots Gaelic"  :  "gd",
    "Serbian"  :  "sr",
    "Sesotho"  :  "st",
    "Shona"  :  "sn",
    "Sindhi"  :  "sd",
    "Sinhala"  :  "si",
    "Slovak"  :  "sk",
    "Slovenian"  :  "sl",
    "Somali"  :  "so",
    "Spanish"  :  "es",
    "Sundanese"  :  "su",
    "Swahili"  :  "sw",
    "Swedish"  :  "sv",
    "Tajik"  :  "tg",
    "Tamil"  :  "ta",
    "Tatar"  :  "tt",
    "Telugu"  :  "te",
    "Thai"  :  "th",
    "Turkish"  :  "tr",
    "Turkmen"  :  "tk",
    "Ukrainian"  :  "uk",
    "Urdu"  :  "ur",
    "Uyghur"  :  "ug",
    "Uzbek"  :  "uz",
    "Vietnamese" : "vi",
    "Welsh"  :  "cy",
    "Xhosa"  :  "xh",
    "Yiddish"  :  "yi",
    "Yoruba" :  "yo",
    "Zulu"  :  "zu"]
}
