//
//  ImagePicker.swift
//  Lightie
//
//  Created by Amir Yalchi on 2022-09-07.
//

import SwiftUI
import UIKit
import AVFoundation

struct ImagePicker: UIViewControllerRepresentable {
    
    
    @Binding var selectedImage: UIImage
    @Binding var eV: Double
    @Environment(\.presentationMode) private var presentationMode
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) ->  UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .camera
        imagePicker.delegate = context.coordinator
        return imagePicker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        //code
    }
    
    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        
        var parent: ImagePicker
        private var pickedImage: Bool = true
        var session: AVCaptureSession?
        let output = AVCapturePhotoOutput()
        let previewLayer = AVCaptureVideoPreviewLayer()
        
        init(_ parent: ImagePicker) {
            self.parent = parent   
        }
        
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            
            if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                parent.selectedImage = image
                let dictionary = info[.mediaMetadata] as! NSDictionary
                guard let exif = dictionary["{Exif}"] as? NSDictionary else {return}
                guard let brg = exif["BrightnessValue"] as? Double? else {return}
//                print("BRIGHTNESS: ", dictionary)
                print("BRIGHTNESS EV: ", brg!)
                parent.eV = Double(brg!)
                pickedImage = false
            }
            
            parent.presentationMode.wrappedValue.dismiss()   
        }
        
        func reTakePhoto() {
            
            pickedImage = false
            if UIImagePickerController.isSourceTypeAvailable(.camera) && !pickedImage {
                let ImagePickerController = UIImagePickerController()
                ImagePickerController.sourceType = .camera
//                parent.selectedImage = image
                pickedImage = true
            }
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
        

    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
}
