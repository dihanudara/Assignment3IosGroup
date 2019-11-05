//
//  ImagePicker.swift
//  Assignment3Ios
//
//  Created by HEWA DEWAGE DIHAN UDARA SANDARUWAN on 5/11/2562 BE.
//  Copyright © 2562 HEWA DEWAGE DIHAN UDARA SANDARUWAN. All rights reserved.
//

import UIKit

public protocol ImagePickerDelegate: class {
    func didSelectImage(image: UIImage?)
}

open class ImagePicker: NSObject, UINavigationControllerDelegate {
    
    private let pickerController: UIImagePickerController
    private weak var presentationController: UIViewController?
    private weak var delegate: ImagePickerDelegate?
    
    
    public init(presentationController: UIViewController, delegate: ImagePickerDelegate) {
        
        self.pickerController = UIImagePickerController()
        
        super.init()
        
        self.pickerController.delegate = self
        self.pickerController.allowsEditing = true
        
        self.presentationController = presentationController
        self.delegate = delegate
    }
    
    
    private func action(for type: UIImagePickerController.SourceType, title: String) -> UIAlertAction? {
        guard UIImagePickerController.isSourceTypeAvailable(type) else {
            return nil
        }
        
        return UIAlertAction(title: title, style: .default) { [unowned self] _ in
            self.pickerController.sourceType = type
            self.presentationController?.present(self.pickerController, animated: true)
        }
    }
    
    
    public func present() {
        
        let alertController = UIAlertController(title: "Choose Image Source", message: nil, preferredStyle: .actionSheet)
        
        if let action = self.action(for: .camera, title: "Camera") {
            alertController.addAction(action)
        }
        if let action = self.action(for: .photoLibrary, title: "Photo library") {
            alertController.addAction(action)
        }
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.presentationController?.present(alertController, animated: true)
    }
    
    private func pickerController(_ controller: UIImagePickerController, didSelect image: UIImage?) {
        controller.dismiss(animated: true, completion: nil)
        
        
        self.delegate?.didSelectImage(image: image)
    }
}

extension ImagePicker: UIImagePickerControllerDelegate {
    
    
    public func imagePickerController(_ picker: UIImagePickerController,
                                      didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let image = info[.editedImage] as? UIImage else {
            return self.pickerController(picker, didSelect: nil)
        }
        self.pickerController(picker, didSelect: image)
    }
    
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.pickerController(picker, didSelect: nil)
    }
}



