//
//  ViewController.swift
//  FaceTrackingSample
//
//  Created by Fabiola Ramirez on 3/10/17.
//  Copyright © 2017 Fabiola Ramirez. All rights reserved.
//

import UIKit

import GoogleMVDataOutput

class ViewController: UIViewController, GMVMultiDataOutputDelegate, GMVOutputTrackerDelegate, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    let session : AVCaptureSession = AVCaptureSession()
    var dataOutput : GMVDataOutput = GMVDataOutput()
    var previewLayer : AVCaptureVideoPreviewLayer = AVCaptureVideoPreviewLayer()
    var videoDataOutput : AVCaptureVideoDataOutput!
    var videoDataOutQueue = DispatchQueue(label: "fabiola")
    var faceDetector : GMVDetector?
    var devicePosition : AVCaptureDevicePosition! = AVCaptureDevicePosition.front
    var lastKnownDeviceOrientation : UIDeviceOrientation = .unknown
    
    @IBOutlet weak var placeholder: UIView!
    @IBOutlet weak var overLayerView: UIView!
    
   
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       
        self.session.sessionPreset = AVCaptureSessionPresetMedium
        self.updatyeCameraSelection()
        self.setupVideoProcessing()
        self.setupCameraPreview()
        
        
        
        let options: Dictionary<AnyHashable, Any> = [
            GMVDetectorFaceMinSize: 0.3,
            GMVDetectorFaceTrackingEnabled: true,
            GMVDetectorFaceLandmarkType: GMVDetectorFaceLandmark.all.rawValue
        ]
        self.faceDetector = GMVDetector(ofType: GMVDetectorTypeFace, options: options)
        
        
        
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func dataOutput(_ dataOutput: GMVDataOutput!, trackerFor feature: GMVFeature!) -> GMVOutputTrackerDelegate! {
        
        return nil
        
        
    }
    
    
    //tracker
    
    func dataOutput(_ dataOutput: GMVDataOutput!, detectedFeature feature: GMVFeature!) {
        
    }
    
    func dataOutput(_ dataOutput: GMVDataOutput!, updateFocusing feature: GMVFeature!, forResultSet features: [GMVFeature]!) {
        
    }
    
    
    func dataOutputCompleted(withFocusingFeature dataOutput: GMVDataOutput!) {
        
    }
    
    func dataOutput(_ dataOutput: GMVDataOutput!, updateMissing features: [GMVFeature]!) {
        
    }
    
    //session
    
    func updatyeCameraSelection(){
        
        self.session.beginConfiguration()
        
        //remove all imputs
        let oldInputs : [AVCaptureInput] = self.session.inputs as! [AVCaptureInput]
        for oldInput in oldInputs {
            
            self.session.removeInput(oldInput)
            
        }
        
        let desiredPosition : AVCaptureDevicePosition = AVCaptureDevicePosition.front
        let input : AVCaptureInput = self.cameraForPosition(desiredPosition: desiredPosition)
        if input == nil {
            for oldinput : AVCaptureInput in oldInputs{
                self.session.addInput(oldinput)
            }
        } else {
            self.session.addInput(input)
        }
        
        self.session.commitConfiguration()
    }
    
    
    func cameraForPosition(desiredPosition : AVCaptureDevicePosition) -> AVCaptureDeviceInput! {
        
        for  device : AVCaptureDevice in AVCaptureDevice.devices(withMediaType: AVMediaTypeVideo) as! [AVCaptureDevice] {
            if device.position == desiredPosition {
                
                var error: Error? = nil
                var input = try? AVCaptureDeviceInput(device: device)
                if self.session.canAddInput(input) {
                    return input!
                }
                
            }
        }
        
        return nil
    }
    
    func setupVideoProcessing(){
        
        self.videoDataOutput = AVCaptureVideoDataOutput()
        var rgbOutputSettings: [AnyHashable: Any]? = [(kCVPixelBufferPixelFormatTypeKey as? String)!: (kCVPixelFormatType_32BGRA)]
        self.videoDataOutput.videoSettings = rgbOutputSettings
        if !self.session.canAddOutput(self.videoDataOutput) {
            self.cleanupVideoProcessing()
            print("Failed to setup video output")
            return
        }
        self.videoDataOutput.alwaysDiscardsLateVideoFrames = true
        self.videoDataOutput.setSampleBufferDelegate(self, queue: videoDataOutQueue)
        self.session.addOutput(self.videoDataOutput)
        
        
        
    }
    
    
    func cleanupVideoProcessing() {
        if self.videoDataOutput != nil {
            self.session.removeOutput(self.videoDataOutput)
        }
        self.videoDataOutput = nil
    }
    
    
    func setupCameraPreview() {
        self.previewLayer = AVCaptureVideoPreviewLayer(session: self.session)
        self.previewLayer.backgroundColor = UIColor.white.cgColor
        self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspect
        let rootLayer = self.placeholder.layer
        rootLayer.masksToBounds = true
        self.previewLayer.frame = rootLayer.bounds
        rootLayer.addSublayer(self.previewLayer)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.session.startRunning()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.session.stopRunning()
    }
    
    
    
    func scaledRect(rect: CGRect, xScale: CGFloat, yScale: CGFloat, offset: CGPoint) -> CGRect {
        let resultRect = CGRect(x: rect.origin.x * xScale, y: rect.origin.y * yScale, width: rect.size.width * xScale, height: rect.size.height * yScale)
        return resultRect
    }
    
    func scaledPoint(point: CGPoint, xScale: CGFloat, yScale: CGFloat, offset: CGPoint) -> CGPoint {
        let resultPoint = CGPoint(x: point.x * xScale + offset.x, y: point.y * yScale + offset.y)
        return resultPoint
    }
    
    func scaledPointForScene(point: CGPoint, xScale: CGFloat, yScale: CGFloat, offset: CGPoint) -> CGPoint {
        let resultPoint = CGPoint(x: point.x * xScale + offset.x, y: UIScreen.main.bounds.size.height - (point.y * yScale + offset.y))
        return resultPoint
    }
    
    private func scalePoint(_ point: CGPoint, xScale xscale: CGFloat, yScale yscale: CGFloat, offset: CGPoint) -> CGPoint {
        let resultPoint = CGPoint(x: point.x * xscale + offset.x, y: point.y * yscale + offset.y)
        return resultPoint
    }
    
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        guard let image = GMVUtility.sampleBufferTo32RGBA(sampleBuffer) else {
            print("No Image 😂")
            return
        }
        
        // Establish the image orientation.
        let deviceOrientation = UIDevice.current.orientation
        let orientation: GMVImageOrientation = GMVUtility.imageOrientation(from: deviceOrientation, with: devicePosition, defaultDeviceOrientation: self.lastKnownDeviceOrientation)
        let options = [GMVDetectorImageOrientation: orientation.rawValue] // rawValue
        
        // Detect features using GMVDetector.
        guard let faces = self.faceDetector?.features(in: image, options: options) as? [GMVFaceFeature] else {
            print("No Faces 😂")
            return
        }
        print("Detected faces: \(faces.count)")
        
        // The video frames captured by the camera are a different size than the video preview.
        // Calculates the scale factors and offset to properly display the features.
        let fdesc = CMSampleBufferGetFormatDescription(sampleBuffer)
        let clap = CMVideoFormatDescriptionGetCleanAperture(fdesc!, false)
        let parentFrameSize = self.previewLayer.frame.size
        
        // Assume AVLayerVideoGravityResizeAspect
        let cameraRatio = clap.size.height / clap.size.width
        let viewRatio = parentFrameSize.width / parentFrameSize.height
        var xScale: CGFloat = 1, yScale: CGFloat = 1
        var videoBox = CGRect.zero
        
        if (viewRatio > cameraRatio) {
            videoBox.size.width = parentFrameSize.height * clap.size.width / clap.size.height
            videoBox.size.height = parentFrameSize.height
            videoBox.origin.x = (parentFrameSize.width - videoBox.size.width) / 2
            videoBox.origin.y = (videoBox.size.height - parentFrameSize.height) / 2
            
            xScale = videoBox.size.width / clap.size.width
            yScale = videoBox.size.height / clap.size.height
        } else {
            videoBox.size.width = parentFrameSize.width
            videoBox.size.height = clap.size.width * (parentFrameSize.width / clap.size.height);
            videoBox.origin.x = (videoBox.size.width - parentFrameSize.width) / 2
            videoBox.origin.y = (parentFrameSize.height - videoBox.size.height) / 2
            
            xScale = videoBox.size.width / clap.size.height
            yScale = videoBox.size.height / clap.size.width
        }
        
        DispatchQueue.main.sync {
            // Remove previously added feature views.
            for featureView in self.overLayerView.subviews {
                featureView.removeFromSuperview()
            }
            
            // Display detected features in overlay.
            for face in faces {
                let faceRect = self.scaledRect(rect: face.bounds, xScale: xScale, yScale: yScale, offset: videoBox.origin)
                DrawingUtility.addRectangle(faceRect, to: overLayerView, with: .red)
                
                // Mouth
                
                if face.hasBottomMouthPosition {
                    let point = self.scalePoint(face.bottomMouthPosition, xScale: xScale, yScale: yScale, offset: videoBox.origin)
                    DrawingUtility.addCircle(at: point, to: overLayerView, with: .green, withRadius: 5)
                }
                if face.hasMouthPosition {
                    let point = self.scalePoint(face.mouthPosition, xScale: xScale, yScale: yScale, offset: videoBox.origin)
                    DrawingUtility.addCircle(at: point, to: overLayerView, with: .green, withRadius: 10)
                }
                if face.hasRightMouthPosition {
                    let point = self.scalePoint(face.rightMouthPosition, xScale: xScale, yScale: yScale, offset: videoBox.origin)
                    DrawingUtility.addCircle(at: point, to: overLayerView, with: .green, withRadius: 5)
                }
                if face.hasLeftMouthPosition {
                    let point = self.scalePoint(face.leftMouthPosition, xScale: xScale, yScale: yScale, offset: videoBox.origin)
                    DrawingUtility.addCircle(at: point, to: overLayerView, with: .green, withRadius: 5)
                }
                
                // nose
                if face.hasNoseBasePosition {
                    let point = self.scalePoint(face.noseBasePosition, xScale: xScale, yScale: yScale, offset: videoBox.origin)
                    DrawingUtility.addCircle(at: point, to: self.overLayerView, with: .darkGray, withRadius: 10)
                
                   DrawingUtility.addMostacho(at: point, to: self.overLayerView, withRadius: 178)
                
                }
                
                // eyes
                if face.hasLeftEyePosition {
                    let point = self.scalePoint(face.leftEyePosition, xScale: xScale, yScale: yScale, offset: videoBox.origin)
                    DrawingUtility.addCircle(at: point, to: self.overLayerView, with: .blue, withRadius: 10)
                }
                
                if face.hasRightEyePosition {
                    let point = self.scalePoint(face.rightEyePosition, xScale: xScale, yScale: yScale, offset: videoBox.origin)
                    DrawingUtility.addCircle(at: point, to: self.overLayerView, with: .blue, withRadius: 10)
                }
                
                // ears
                if face.hasLeftEarPosition {
                    let point = self.scalePoint(face.leftEarPosition, xScale: xScale, yScale: yScale, offset: videoBox.origin)
                    DrawingUtility.addCircle(at: point, to: self.overLayerView, with: .purple, withRadius: 10)
                }
                
                if face.hasRightEarPosition {
                    let point = self.scalePoint(face.rightEarPosition, xScale: xScale, yScale: yScale, offset: videoBox.origin)
                    DrawingUtility.addCircle(at: point, to: self.overLayerView, with: .purple, withRadius: 10)
                }
                
                // cheeks
                if face.hasLeftCheekPosition {
                    let point = self.scalePoint(face.leftCheekPosition, xScale: xScale, yScale: yScale, offset: videoBox.origin)
                    DrawingUtility.addCircle(at: point, to: self.overLayerView, with: .magenta, withRadius: 10)
                }
                
                if face.hasRightCheekPosition {
                    let point = self.scalePoint(face.rightCheekPosition, xScale: xScale, yScale: yScale, offset: videoBox.origin)
                    DrawingUtility.addCircle(at: point, to: self.overLayerView, with: .magenta, withRadius: 10)
                }
                
                // Tracking Id.
                if face.hasTrackingID {
                    let point = self.scalePoint(face.bounds.origin, xScale: xScale, yScale: yScale, offset: videoBox.origin)
                    let label = UILabel(frame: CGRect(x: CGFloat(point.x), y: CGFloat(point.y), width: CGFloat(100), height: CGFloat(20)))
                    label.text = "id: \(UInt(face.trackingID))"
                    self.overLayerView.addSubview(label)
                }
                
            }
        }
        
    }
    
    
    
    
    
    
    
}

