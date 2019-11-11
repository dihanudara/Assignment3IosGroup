//
//  ViewController.swift
//  Assignment3Ios
//
//  Created by HEWA DEWAGE DIHAN UDARA SANDARUWAN on 5/11/2562 BE.
//  Copyright © 2562 HEWA DEWAGE DIHAN UDARA SANDARUWAN. All rights reserved.
//
import Foundation
import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var labelEngligh: UILabel!
    
    @IBOutlet weak var labelOther: UILabel!
    
    var imagePicker: ImagePicker?
    
    var translationsList = [[String]]()
    
    let jsonEncoder = JSONEncoder()
    
    let cognitiveServiceAPIKey = "24c5e23bb1784a7793c0d6c66d4e6f22"
    
    let translationServiceAPIKey = "840941453ecb404ba3de684b04c2d7a7"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.imagePicker = ImagePicker(presentationController: self, delegate: self)
    }
    
    private func getTags (selectedImage: UIImage?){
        guard let url = URL(string: "https://australiaeast.api.cognitive.microsoft.com/vision/v1.0/describe")
            
            else {return}
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
        request.setValue(cognitiveServiceAPIKey, forHTTPHeaderField: "Ocp-Apim-Subscription-Key")
        request.httpBody = selectedImage?.pngData()
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, let response = response as? HTTPURLResponse else { return }
            
            if response.statusCode == 200 {
                
                let describeImage = try? JSONDecoder().decode(DescribeImage.self, from: data)
                guard let captions = describeImage?.description?.captions else { return }
                DispatchQueue.main.async {
                    if captions.count > 0 {
                        self.labelEngligh.text = captions[0].text
                        
                        // take english text from label and parse it to the translator
                        self.translateText(text: (self.labelEngligh.text)!)
                    } else {
                        self.labelEngligh.text = "No captions available"
                        self.labelOther.text = "No captions avaliable"
                    }
                    
                }
            } else {
                DispatchQueue.main.async {
                    self.labelEngligh.text = error?.localizedDescription
                }
            }
        }
        
        task.resume()
    }
    
    private func translateText(text: String){
        // parse spi key to function
        let azureKey = translationServiceAPIKey
        // default language is english
        let selectedFromLangCode = "en"
        // translate to spanish, this can be changed
        let selectedToLangCode = "es"
        
        // debugging
        print("this is the selected language code ->", selectedToLangCode)
        
        // force the string to exist inside quotes?
        struct encodeText: Codable {
            var text = String()
        }
        
        // setup the api with variables
        let contentType = "application/json"
        let traceID = "A14C9DB9-0DED-48D7-8BBE-C517A1A8DBB0"
        let host = "dev.microsofttranslator.com"
        
        // main query
        let apiURL = "https://dev.microsofttranslator.com/translate?api-version=3.0&from=" + selectedFromLangCode + "&to=" + selectedToLangCode
        
        let text2Translate = self.labelEngligh.text
        var encodeTextSingle = encodeText()
        var toTranslate = [encodeText]()
        
        encodeTextSingle.text = text2Translate!
        toTranslate.append(encodeTextSingle)
        
        // use JSON to format the text
        let jsonToTranslate = try? jsonEncoder.encode(toTranslate)
        let url = URL(string: apiURL)
        var request = URLRequest(url: url!)
        
        // start building the post query
        request.httpMethod = "POST"
        request.addValue(azureKey, forHTTPHeaderField: "Ocp-Apim-Subscription-Key")
        request.addValue(contentType, forHTTPHeaderField: "Content-Type")
        request.addValue(traceID, forHTTPHeaderField: "X-ClientTraceID")
        request.addValue(host, forHTTPHeaderField: "Host")
        request.addValue(String(describing: jsonToTranslate?.count), forHTTPHeaderField: "Content-Length")
        request.httpBody = jsonToTranslate
        
        // unsure but this is a port of the example for swift and azure's API
        let config = URLSessionConfiguration.default
        let session =  URLSession(configuration: config)
        
        let task = session.dataTask(with: request) { (responseData, response, responseError) in
            
            // if there is an error, print it
            if responseError != nil {
                print("this is the error ", responseError!)
                
                // can't connect
                let alert = UIAlertController(title: "Could not connect to service", message: "Please check your network connection and try again", preferredStyle: .actionSheet)
                
                // show an alert
                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                
                self.present(alert, animated: true)
                
            }
            print("Translation was successful")
            self.parseJson(jsonData: responseData!)
        }
        task.resume()
    }
    
    
    func parseJson(jsonData: Data) {
        
        //*****TRANSLATION RETURNED DATA*****
        struct ReturnedJson: Codable {
            var translations: [TranslatedStrings]
        }
        struct TranslatedStrings: Codable {
            var text: String
            var to: String
        }
        
        let jsonDecoder = JSONDecoder()
        let langTranslations = try? jsonDecoder.decode(Array<ReturnedJson>.self, from: jsonData)
        let numberOfTranslations = langTranslations!.count - 1
        print(langTranslations!.count)
        
        //Put response on main thread to update UI
        DispatchQueue.main.async {
            self.labelOther.text = langTranslations![0].translations[numberOfTranslations].text
            self.saveArray(x: (self.labelEngligh.text)!, y: (self.labelOther.text)!)
        }
    }
    
    
    @IBAction func chooseImage(_ sender: UIButton) {
        imagePicker?.present()
    }
    
    @IBAction func speakEnglish(_ sender: UIButton) {
        self.readMe(myText:labelEngligh.text!)
    }
    
    func saveArray(x: String, y: String){
        var thing = [String]()
        thing.append(x)
        thing.append(y)
        translationsList.append(thing)
        print(thing)
    }
    
    func readMe(myText:String){
        let speaker = AVSpeechUtterance(string: myText)
        
        speaker.rate = 0.5
        let synthesizer = AVSpeechSynthesizer()
        synthesizer.speak(speaker)
        
    }
    
    @IBAction func speakOther(_ sender: UIButton) {
        self.readMe(myText:labelOther.text!)
        print("speaking translated text out loud")
    }
    
}
extension ViewController: ImagePickerDelegate{
    func didSelectImage(image: UIImage?) {
        self.imageView.image = image
        self.getTags(selectedImage: image)
    }
}

