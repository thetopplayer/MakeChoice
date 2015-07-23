//
//  PostViewController.swift
//  MakeChoice
//
//  Created by 吴梦宇 on 7/8/15.
//  Copyright (c) 2015 ___mengyu wu___. All rights reserved.
//

import UIKit
import ActionSheetPicker_3_0
import BSImagePicker
import Photos

class PostViewController: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate,UIPopoverPresentationControllerDelegate  {
    
    var imagePickerController = UIImagePickerController()
    
    var imgAddButton:Int=0
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var img1: UIImageView!
    
    @IBOutlet weak var img2: UIImageView!
    
    @IBOutlet weak var addImg1Button: UIButton!
    
    @IBOutlet weak var addImg2Button: UIButton!
    
    @IBAction func addImg1ButtonPressed(sender: AnyObject) {
        imgAddButton=1;
        self.showPhotoSourceSelection()
    }
    
   let colors=CATEGORYCOLORS
   let categories=CATEGORIES_UPPERCASE
    

    @IBAction func addImg2ButtonPressed(sender: AnyObject) {
        imgAddButton=2;
        self.showPhotoSourceSelection()
    }
    
    
    @IBAction func PostPressed(sender: AnyObject) {
        println("post pressed")
        
        // Note: before post, must check title, image1, image2 is posted
        
        var post=Post()
        post.image1.value=img1.image
        post.image2.value=img2.image
        post.isPrivate=false //add action on it
        post.title=titleTextField.text // should not let it upload if no title?
        post.category="others"
        post.isPrivate=self.isPrivate
 
        var img1Data=UIImageJPEGRepresentation(img1.image, 0.8)
        var img2Data=UIImageJPEGRepresentation(img2.image, 0.8)
        
        
       
        if (titleTextField.text==""){
            var alert = UIAlertController(title: "Alert", message: "Please fill in the title", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }else if (pickerSelect.titleLabel?.text=="Select"){
            
            var alert = UIAlertController(title: "Alert", message: "Please choose a category", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            
        }else if (img1Data == nil || img2Data == nil){
            
            var alert = UIAlertController(title: "Alert", message: "Please upload two pictures", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            
        }else{
            
            post.category=pickerSelect.titleLabel?.text?.lowercaseString
            
            println("upload successfully")
            post.uploadPost()
            
            // ProcessHUD, pop up
            var alert = UIAlertController(title: "Alert", message: "Upload successfully", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)

       
            //after upload
            pickerSelect.setTitle("Select", forState: .Normal)
            titleTextField.text=""
            isPrivate=false
            self.isPublicButton.selected=false
            DesignHelper.blankImageShowButton(img1, button: addImg1Button)
            DesignHelper.blankImageShowButton(img2, button: addImg2Button)
            
         }

    
    }
    
    
    func showPhotoSourceSelection() {
        let alertController = UIAlertController(title: nil, message: "where do you want to get your picture from?", preferredStyle: .ActionSheet)
    
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        if (UIImagePickerController.isCameraDeviceAvailable(.Rear)){
            let cameraAction = UIAlertAction(title: "Photo from Camera", style: .Default){ (action) in
                self.showImagePickerController(.Camera)
            }
            
            alertController.addAction(cameraAction)
        }
        
        let photoLibrayAction = UIAlertAction(title: "Photo from Libray", style: .Default){ (action) in
            self.showBSImagePicker()
        }
        
        alertController.addAction(photoLibrayAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)
        
    }
    
    
    // MARK: BSImagePicker
    func showBSImagePicker(){
        //using external imagePicker
        println("BSImagePicker")
        let vc = BSImagePickerViewController()
        vc.maxNumberOfSelections = 2
        
        bs_presentImagePickerController(vc, animated: true,
            select: { [unowned self] (asset: PHAsset) -> Void in
                // println("Selected: \(asset)")
                println(" selected")
            }, deselect: { (asset: PHAsset) -> Void in
                // println("Deselected: \(asset)")
                println(" deselected")
            }, cancel: { (assets: [PHAsset]) -> Void in
                //  println("Cancel: \(assets)")
                println("cancel selected")
            }, finish: { (assets: [PHAsset]) -> Void in
               // println("Finish: \(assets)")
                println("finish select count: \(assets.count)")
                
                if(assets.count==2){
                    let first = assets[0]
                    let second = assets[1]
                    
                    
                    let options = PHImageRequestOptions()
                    options.deliveryMode = .FastFormat
                    options.synchronous=true
                    
                    PHImageManager.defaultManager().requestImageForAsset(first, targetSize: self.img1.bounds.size, contentMode: PHImageContentMode.AspectFill, options: options, resultHandler: { (result, info) -> Void in
                        // MARK: bring the thread to the main thread
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.img1.image = result
                            DesignHelper.showImageHideButton(self.img1, button: self.addImg1Button)
                            
                            self.imgAddButton=3
                        })
                    })
                    
                    
                    PHImageManager.defaultManager().requestImageForAsset(second, targetSize: self.img2.bounds.size, contentMode: PHImageContentMode.AspectFill, options: options, resultHandler: { (result, info) -> Void in
                        
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.img2.image = result
                            DesignHelper.showImageHideButton(self.img2, button: self.addImg2Button)
                            
                            self.imgAddButton=3
                        })
                    })
                    

                }else if(self.imgAddButton==1){
                    
                    let image=assets[0]
                    
                    let options = PHImageRequestOptions()
                    options.deliveryMode = .FastFormat
                    options.synchronous=true
                    
                    PHImageManager.defaultManager().requestImageForAsset(image, targetSize: self.img1.bounds.size, contentMode: PHImageContentMode.AspectFill, options: options, resultHandler: { (result, info) -> Void in
                        
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.img1.image = result
                            DesignHelper.showImageHideButton(self.img1, button: self.addImg1Button)
                            
                            self.imgAddButton=1
                        })
                    })

                    
                }else if(self.imgAddButton==2){
                    
                    let image=assets[0]
                    
                    let options = PHImageRequestOptions()
                    options.deliveryMode = .FastFormat
                    options.synchronous=true
                    
                    PHImageManager.defaultManager().requestImageForAsset(image, targetSize: self.img2.bounds.size, contentMode: PHImageContentMode.AspectFill, options: options, resultHandler: { (result, info) -> Void in
                        
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.img2.image = result
                            DesignHelper.showImageHideButton(self.img2, button: self.addImg2Button)
                            self.imgAddButton=2
                        })
                    })

                    
                }

                
                
                
                
            }, completion: nil)

    }
    
    
    
    func showImagePickerController(sourceType: UIImagePickerControllerSourceType){
        
            imagePickerController.sourceType=sourceType
            imagePickerController.delegate=self
            self.presentViewController(imagePickerController, animated: true, completion: nil)
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set title color
        titleTextField.setValue(UIColor.whiteColor(), forKeyPath: "_placeholderLabel.textColor")
        titleTextField.delegate=self
        
        // Do any additional setup after loading the view.
        imagePickerController.delegate = self
        
        var tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "DismissKeyboard")
        view.addGestureRecognizer(tap)
        //drop down
        createPicker()
    
        
        //add tap image gesture
        
        img1.userInteractionEnabled=true
        img2.userInteractionEnabled=true
  
        
        var img1tapped: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("img1tapped" ))
        img1.addGestureRecognizer(img1tapped)
        
        var img2tapped: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("img2tapped" ))
        img2.addGestureRecognizer(img2tapped)
        
        
    }
    
    
    func img1tapped(){
        imgAddButton=1;
        self.showPhotoSourceSelection()
    }
    
    func img2tapped(){
        imgAddButton=1;
        self.showPhotoSourceSelection()
    }

    
    
    //Calls this function when the tap is recognized.
    func DismissKeyboard(){
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
      
        DesignHelper.setImageCornerRadius(self.img1)
        DesignHelper.setImageCornerRadius(self.img2)
        if(self.imgAddButton==0){
        DesignHelper.blankImageShowButton(img1, button: addImg1Button)
        DesignHelper.blankImageShowButton(img2, button: addImg2Button)
        }else{
            // some pictures is choosen
            self.imgAddButton=0
        }
        
       
    }
    
   
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    
    
    // MARK: dropdown
    
    let picker = UIImageView(image: UIImage(named: "picker"))
    
    struct properties {
        
       //["Technology","Travelling","Fashion","Pet","Food","Music"]
        static let categories = [
            ["title" : "Technology", "color" : "#8647b7"],
            ["title" : "Travelling", "color": "#4870b7"],
            ["title" : "Fashion", "color" : "#45a85a"],
            ["title" : "Pet", "color" : "#a8a23f"],
            ["title" : "Food", "color" : "#c6802e"],
            ["title" : "Others", "color" : "#b05050"]
        ]
    }
    
    
    @IBOutlet weak var pickerSelect: UIButton!
    
    @IBAction func pickerSelect(sender: UIButton)
    {
        picker.hidden ? openPicker() : closePicker()
    }
    
    func createPicker()
    {
        picker.frame = CGRect(x: ((self.view.frame.width / 2) - 143), y: 150, width: 286, height: 291)
        picker.alpha = 0
        picker.hidden = true
        picker.userInteractionEnabled = true
        
        var offset = 21
        
        for (index, feeling) in enumerate(properties.categories)
        {
            let button = UIButton()
            button.frame = CGRect(x: 13, y: offset, width: 260, height: 43)
            button.setTitleColor(UIColor(rgba: feeling["color"]!), forState: .Normal)
            button.setTitle(feeling["title"], forState: .Normal)
            button.tag = index
            button.addTarget(self, action: Selector("ButtonTapped:" ), forControlEvents: UIControlEvents.TouchUpInside)
            button.backgroundColor=UIColor(netHex: colors[index])
            picker.addSubview(button)
            
            offset += 44
        }
        
        view.addSubview(picker)
    }
    
    func ButtonTapped(sender:UIButton!){
        
        println("button tag \(sender.tag)")
       
        var tag=sender.tag
        pickerSelect.setTitle(CATEGORIES[tag], forState: .Normal)
        closePicker()
        
    }

    
    func openPicker()
    {
        self.picker.hidden = false
        
        UIView.animateWithDuration(0.3,
            animations: {
                self.picker.frame = CGRect(x: ((self.view.frame.width / 2) - 143), y: 180, width: 286, height: 291)
                self.picker.alpha = 1
        })
    }
    
    func closePicker()
    {
        UIView.animateWithDuration(0.3,
            animations: {
                self.picker.frame = CGRect(x: ((self.view.frame.width / 2) - 143), y: 150, width: 286, height: 291)
                self.picker.alpha = 0
            },
            completion: { finished in
                self.picker.hidden = true
            }
        )
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if let popupView = segue.destinationViewController as? UIViewController
        {
            if let popup = popupView.popoverPresentationController
            {
                popup.delegate = self
            }
        }
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle
    {
        return UIModalPresentationStyle.None
    }

    
 // MARK: private
    var isPrivate=false
    
    @IBOutlet weak var isPublicButton: UIButton!
    
    @IBAction func isPublicButtonTapped(sender: AnyObject) {
        isPrivate = !isPrivate
        isPublicButton.selected = isPrivate
 
    }
    
    
}

// MARK: delegate
extension PostViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        // replace the img1 place holder
        if(self.imgAddButton==1){
            self.img1.image=image
            DesignHelper.showImageHideButton(img1, button: addImg1Button)
           
        }else if(self.imgAddButton==2){
            self.img2.image=image
            DesignHelper.showImageHideButton(img2, button: addImg2Button)
      
        }
    
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}


// MARK: textField delegate
extension PostViewController:UITextFieldDelegate{
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        if (range.length + range.location > count(textField.text) )
        {
            return false;
        }
        
        let newLength = count(textField.text) + count(string) - range.length
        return newLength <= 100
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
