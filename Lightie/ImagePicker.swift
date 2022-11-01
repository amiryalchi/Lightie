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
        imagePicker.cameraFlashMode = .off
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
        
    // with this method the photo optain from the camera and from the exif file iso, aperture value and shutter extracts
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            
            if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                parent.selectedImage = image
                let dictionary = info[.mediaMetadata] as! NSDictionary
                guard let exif = dictionary["{Exif}"] as? NSDictionary else {return}
                guard let brg = exif["BrightnessValue"] as? Double? else {return}
                
                guard let apertureValue = exif["ApertureValue"] as? Double? else {return}
                guard let iSOSpeedRatings = exif["ISOSpeedRatings"] as? [Double]? else {return}
                guard let exposureTime = exif["ExposureTime"] as? Double? else {return}
                print("BRIGHTNESS VALUE: ", brg!)
                parent.eV = EVCalculator(apValue: apertureValue!, isoValue: iSOSpeedRatings![0], expoValue: exposureTime!)
                print("EXPOSURE VALUE: ", parent.eV)
                pickedImage = false
            }
            
            parent.presentationMode.wrappedValue.dismiss()   
        }
        
    // this function calculates the EV value from the exif file from the camera
        
        func EVCalculator(apValue: Double, isoValue: Double, expoValue: Double) -> Double {
            return log2((100 * pow(apValue,2)) / (isoValue * expoValue))
        }
        
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
        

    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
}
