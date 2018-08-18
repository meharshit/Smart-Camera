//
//  ViewController.swift
//  Smart Camera
//
//  Created by Harshit Satyaseel on 07/08/18.
//  Copyright © 2018 Harshit Satyaseel. All rights reserved.
//

import UIKit
import ARKit // The library for the audio visual to start the camera session for us
import Vision
import CoreML

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    @IBOutlet weak var displayLabel: UILabel!
    
    @IBOutlet weak var confidenceLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // code for strating up the camera..........
        let captureSession = AVCaptureSession()
        captureSession.sessionPreset = .photo
        guard let captureDevice = AVCaptureDevice.default(for: .video) else {
            return
        }
        guard let input = try? AVCaptureDeviceInput(device: captureDevice) else { // try? is used if we dont want to use do catch statements.
            return
        }
        captureSession.addInput(input)
        let addPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        view.layer.addSublayer(addPreviewLayer)
        addPreviewLayer.frame = view.frame
        captureSession.startRunning()
         // ended camera code........
        
        // code for getting access to the frame of the camera layer for CGImage
        let cameraData = AVCaptureVideoDataOutput()
        // Now, we need to monitor the data of the camera everytime the frame is being camputred by the camera.
        cameraData.setSampleBufferDelegate(self, queue: DispatchQueue(label: "myVideolayer"))
        captureSession.addOutput(cameraData)
       
    }
    
    // function is called every times the camera captures a frame
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
       
      //  print("camera is comming here",Date())
       
        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { // guard let it since it is an optional type varialble
            return
        }
        // creating a request to use the coreML model
        guard let model = try? VNCoreMLModel(for: Resnet50().model) else{
            return
        }
        let request = VNCoreMLRequest(model: model) { (finishedRequest, err) in
            // checking for the error and then print out that error
           
            guard let results = finishedRequest.results as? [VNClassificationObservation] else {
                return
            }
            
            guard let observations = results.first else {
                return
            }
            
            
            DispatchQueue.main.async {
                self.displayLabel.text = observations.identifier
                self.confidenceLabel.text = String(observations.confidence)
               // self.displayLabel.text = observations.confidence as? String
            }
            
            
        }
       try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
        
    }

    
}

