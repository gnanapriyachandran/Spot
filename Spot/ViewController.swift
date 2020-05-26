//
//  ViewController.swift
//  Spot
//
//  Created by Gnanapriya C on 26/05/20.
//  Copyright © 2020 Gnanapriya C. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    
    let imagePicker = UIImagePickerController()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        imagePicker.delegate = self
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        //Get the selected image
        if let userSelectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            imageView.image = userSelectedImage
            //Core Image
            guard let ciimage = CIImage(image: userSelectedImage) else {
                fatalError("Couldn't convert to CIImage")
            }
            
            //Process image
            detectImage(image: ciimage)
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func detectImage(image: CIImage) {
        //get model
        
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else {
            fatalError()
        }
        //get request
        let request = VNCoreMLRequest(model: model) { request, error in
            //get result
            guard let result = request.results as? [VNClassificationObservation] else {
                print("Error in result \(String(describing: error))")
                return
            }
            print(result)
            if let topResult = result.first
            {
                let firstPart = topResult.identifier.components(separatedBy: ",")
                //display title and confidence
                self.title = firstPart[0] + " Confidence:" + String(Int(topResult.confidence * 100))
            }
            
        }
        let handler = VNImageRequestHandler(ciImage: image, options: [:])
        do {
            try handler.perform([request])
        } catch {
            print(error)
        }
        
    }
    
    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
    
}

