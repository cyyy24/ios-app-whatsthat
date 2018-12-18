//
//  MenuViewController.swift
//  WhatsThat
//
//  Created by Yuan Cheng on 2017/11/19.
//  Copyright © 2017年 Yuan Cheng. All rights reserved.
//

import UIKit


class MenuViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var imageToPass: UIImage!

    @IBOutlet weak var menuScreenImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        menuScreenImage.image = #imageLiteral(resourceName: "icon")
        
        print("menu view did load")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        print("menu view did appear")
    }
    
    
    // When camera button is pressed..
    @IBAction func cameraButtonPressed(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        // Enables an action sheet where user can choose either camera or photo library
        let actionSheet = UIAlertController(title: "Photo Source", message: "Choose a source", preferredStyle: .actionSheet)
        
        // Add camera option on the action sheet
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action: UIAlertAction) in
            if UIImagePickerController.isSourceTypeAvailable( .camera){
                imagePicker.sourceType = .camera
                self.present(imagePicker, animated: true, completion: nil)
            } else {
                print("Camera not available")
            }
        }))
        
        // Add photo library option on the action sheet
        actionSheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { (action: UIAlertAction) in
            imagePicker.sourceType = .photoLibrary
            self.present(imagePicker, animated: true, completion: nil)
        }))
        
        // Add Cancel option on the action sheet
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    
    // Function implementation for: UIImagePickerControllerDelegate & UINavigationControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        // Capture the image we get
        let originalImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        imageToPass = originalImage
        
        picker.dismiss(animated: true, completion: nil)
        
        performSegue(withIdentifier: "photoIDSegue" , sender: self)
    }
    
    
    // Function implementation for: UIImagePickerControllerDelegate & UINavigationControllerDelegate
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "photoIDSegue" {
            let destinationViewController = segue.destination as? PhotoIdentificationViewController
            
            // pass the image to the PhotoIdentificationVC
            destinationViewController?.chosenImage = imageToPass
        }
    }
}
// -------------------------------------------- OUTSIDE OF THIS CLASS -----------------------------------------------
