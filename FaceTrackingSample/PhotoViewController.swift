//
//  PhotoViewController.swift
//  FaceTrackingSample
//
//  Created by Fabiola Ramirez on 3/12/17.
//  Copyright © 2017 Fabiola Ramirez. All rights reserved.
//

import UIKit
import GoogleMobileVision
import MobileCoreServices

class PhotoViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
    
    var faceDetector : GMVDetector = GMVDetector()
    var newMedia: Bool?
    @IBOutlet weak var photoImageView: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.photoImageView.image = UIImage(named:"widget")
        // Instantiate a face detector that searches for all landmarks and classifications.
        let options: [AnyHashable: Any] =
            [GMVDetectorFaceLandmarkType: GMVDetectorFaceLandmark.all.rawValue,
             GMVDetectorFaceClassificationType: GMVDetectorFaceClassification.all.rawValue,
             GMVDetectorFaceMinSize: 0.3,
             GMVDetectorFaceTrackingEnabled: false
        ]
        faceDetector = GMVDetector(ofType: GMVDetectorTypeFace, options: options)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initScanning(){
        print("init pressed")
        
        print(self.photoImageView.image)
        print("> \(self.photoImageView.image)")
        
        self.photoImageView.image = UIImage(named:"people")
        
        // Invoke features detection.
        let faces = self.faceDetector.features(in: self.photoImageView.image, options: nil) as? [GMVFaceFeature]
        print("faces count: \(faces?.count)")
        
        
        for face in faces! {
            print("face")
            let rect : CGRect = face.bounds
            if face.hasMouthPosition {
                print("hasMouthPosition")
                print("Mouth \(face.mouthPosition.x), \(face.mouthPosition.y)")
                
            } else {
                print("has no MouthPosition")
            }
            
            if face.hasSmilingProbability {
                print("Smiling probability : \(face.smilingProbability)")
            }
        }
        
    }
    
    
    
    @IBAction func filterPicture(_ sender: UIBarButtonItem) {
        initScanning()
        
    }
    
    
    @IBAction func selectImageOfGallery(_ sender: UIBarButtonItem) {
        
        if UIImagePickerController.isSourceTypeAvailable(
            UIImagePickerControllerSourceType.savedPhotosAlbum) {
            let imagePicker = UIImagePickerController()
            
            imagePicker.delegate = self
            imagePicker.sourceType =
                UIImagePickerControllerSourceType.photoLibrary
            imagePicker.mediaTypes = [kUTTypeImage as String]
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true,
                         completion: nil)
            //newMedia = false
        } else {
            print("Unable to open!")
        }
        
    }
    
    //Delegate Methods
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        print("didFinishPickingMediaWithInfo")
        let mediaType = info[UIImagePickerControllerMediaType] as! NSString
        
        if mediaType.isEqual(to: kUTTypeImage as String) {
            
            
            if let image = info[UIImagePickerControllerOriginalImage]  as? UIImage {
                photoImageView.image = image
            } else {
                print("something wrong happened")
            }
            
            self.dismiss(animated: true, completion: nil)
            
            //keep the image
            /*if (newMedia == true) {
             UIImageWriteToSavedPhotosAlbum(image, self,
             #selector(PhotoViewController.image(image:didFinishSavingWithError:contextInfo:)), nil)
             } else if mediaType.isEqual(to: kUTTypeImage as String) {
             // Code to support video here
             }*/
            
        }
    }
    
    /*func image(image: UIImage, didFinishSavingWithError error: NSErrorPointer, contextInfo:UnsafeRawPointer) {
     
     if error != nil {
     let alert = UIAlertController(title: "Save Failed",
     message: "Failed to save image",
     preferredStyle: UIAlertControllerStyle.alert)
     
     let cancelAction = UIAlertAction(title: "OK",
     style: .cancel, handler: nil)
     
     alert.addAction(cancelAction)
     self.present(alert, animated: true,
     completion: nil)
     }
     }*/
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
