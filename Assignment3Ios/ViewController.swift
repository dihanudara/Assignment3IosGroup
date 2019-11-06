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
    let cognitiveServiceAPIKey = "24c5e23bb1784a7793c0d6c66d4e6f22"
    
    
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
                            } else {
                                self.labelEngligh.text = "No captions available"
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
    
    
    

    @IBAction func chooseImage(_ sender: UIButton) {
        imagePicker?.present()
    }
    
    @IBAction func speakEnglish(_ sender: UIButton) {
        self.readMe(myText:labelEngligh.text!)
    }
    
    func readMe(myText:String){
        let speaker = AVSpeechUtterance(string: myText)
       
        speaker.rate = 0.5
        let synthesizer = AVSpeechSynthesizer()
        synthesizer.speak(speaker)
        
    }
    
    @IBAction func speakOther(_ sender: UIButton) {
    }
    
}
extension ViewController: ImagePickerDelegate{
    func didSelectImage(image: UIImage?) {
        self.imageView.image = image
        self.getTags(selectedImage: image)
    }
}

