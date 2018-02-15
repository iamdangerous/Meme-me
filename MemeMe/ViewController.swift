//
//  ViewController.swift
//  MemeMe
//
//  Created by Rahul Lohra on 29/01/18.
//  Copyright © 2018 Rahul Lohra. All rights reserved.
//

import UIKit

class ViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextFieldDelegate {
    @IBOutlet weak var tvTop: UITextField!
    @IBOutlet weak var tvBottom: UITextField!
    
    @IBOutlet weak var imageCamera: UIBarButtonItem!
    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var btnShare: UIButton!
    var shouldHideKeyboard = false
    var meme:Meme!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let memeTextAttributes:[String:Any] = [
            NSAttributedStringKey.strokeColor.rawValue: UIColor.black,
            NSAttributedStringKey.foregroundColor.rawValue: UIColor.white,
            NSAttributedStringKey.font.rawValue: UIFont(name: "HelveticaNeue-CondensedBlack", size:40)!,
            NSAttributedStringKey.strokeWidth.rawValue:10]
        
        tvTop.defaultTextAttributes = memeTextAttributes
        tvBottom.defaultTextAttributes = memeTextAttributes
        tvTop.delegate = self
        tvTop.tag = 0
        tvBottom.delegate = self
        tvBottom.tag = 1
        
        toggleShareBtn()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        imageCamera.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
        toggleShareBtn()
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion: nil)
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imagePickerView.image = image
        }
        toggleShareBtn()
    }

    @IBAction func performShare(_ sender: Any) {
        
        let vc = UIActivityViewController(activityItems: [imagePickerView.image], applicationActivities: [])
        present(vc, animated: true)
    }
    @IBAction func openCamera(_ sender: Any) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = .camera
        present(pickerController, animated: true, completion: nil)
    }
    @IBAction func pickImage(_ sender: Any) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = .photoLibrary
        present(pickerController, animated: true, completion: nil)
 
    }
    
    func toggleShareBtn(){
        if let image = imagePickerView.image{
            btnShare.isEnabled = true
        }else
        {
            btnShare.isEnabled = false
        }
    }
    
    //delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    //subscribe keyboard notification
    func subscribeToKeyboardNotifications() {
        
        //show
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        
        //hide
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
    }
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }
    
    @objc func keyboardWillHide(_ notification:Notification) {
        view.frame.origin.y = 0
    }
    
    @objc func keyboardWillShow(_ notification:Notification) {
        if(shouldHideKeyboard){
        view.frame.origin.y = 0
        }else{
            view.frame.origin.y = 0 - getKeyboardHeight(notification)
        }
        
    }
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if(textField.tag == 0){
            shouldHideKeyboard = true
        }else{
            shouldHideKeyboard = false
        }
        return true
    }
    
    //create meme image
    func generateMemedImage() -> UIImage {
        
        self.navigationController?.setToolbarHidden(true, animated: true)
        
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        self.navigationController?.setToolbarHidden(false, animated: true)
        return memedImage
    }
    
    func save() {
        // Create the meme
        meme = Meme(topText: tvTop.text!, bottomText: tvBottom.text!, originalImage: imagePickerView.image!, memedImage: generateMemedImage())
    }
    
    struct Meme {
        let topText:String
        let bottomText:String
        let originalImage:UIImage
        let memedImage:UIImage
    }

    
    
}

