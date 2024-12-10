//
//  ContentView.swift
//  AgriARIphone
//
//  Created by Lukas Burkhardt on 09.12.24.
//


import SwiftUI
import Vision
import AVFoundation
import UIKit

struct ContentView: View {
    @State private var detectedObject: String = "Suche nach Objekten..."

    var body: some View {
        ZStack {
            CameraManager3(detectedObject: $detectedObject, modelName: "ObjectDetector")

            VStack {
                Spacer()
                Text(detectedObject)
                    .font(.headline)
                    .padding()
                    .background(Color.black.opacity(0.7))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding()
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
}

#Preview {
    ContentView()
}

/*

struct CameraView: UIViewRepresentable {
    
    @State private var cameraManager = CameraManager()
    @State private var detectionResults: [VNRecognizedObjectObservation] = []
    @State private var isRunning = true
    
    // Vision parts
    @State private var requests = [VNRequest]()
    
    @State private var detectionOverlay: CALayer! = nil
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        
        let captureSession = AVCaptureSession()
        captureSession.sessionPreset = .high
        
        guard let captureDevice = AVCaptureDevice.default(for: .video) else {
            print("Keine Kamera verfügbar.")
            return view
        }
        
        guard let input = try? AVCaptureDeviceInput(device: captureDevice) else {
            print("Fehler beim Erstellen des Kamera-Inputs.")
            return view
        }
        
        if captureSession.canAddInput(input) {
            captureSession.addInput(input)
        }
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = view.layer.bounds
        view.layer.addSublayer(previewLayer)
        
        captureSession.startRunning()
        
        if !detectionResults.isEmpty {
            Text("Detected Objects:")
                .font(.headline)
                .padding(.top, 20)
            List(detectionResults, id: \.self) { result in
                VStack(alignment: .leading) {
                    Text("Object: \(result.labels.first?.identifier ?? "Unknown")")
                    Text(String(format: "Confidence: %.2f%%", (result.labels.first?.confidence ?? 0) * 100))
                }
            }
        } else {
            Text("No objects detected.")
                .foregroundColor(.gray)
                .padding(.top, 20)
        }
        
        return view
    }
    
    @discardableResult
    func setupVision() -> NSError? {
        // Setup Vision parts
        let error: NSError! = nil
        
        guard let modelURL = Bundle.main.url(forResource: "FruitsObjectDetectorVisionOS", withExtension: "mlmodelc") else {
            return NSError(domain: "VisionObjectRecognitionViewController", code: -1, userInfo: [NSLocalizedDescriptionKey: "Model file is missing"])
        }
        do {
            let visionModel = try VNCoreMLModel(for: MLModel(contentsOf: modelURL))
            let objectRecognition = VNCoreMLRequest(model: visionModel, completionHandler: { (request, error) in
                DispatchQueue.main.async(execute: {
                    // perform all the UI updates on the main queue
                    if let results = request.results {
                        self.drawVisionRequestResults(results)
                    }
                })
            })
            self.requests = [objectRecognition]
        } catch let error as NSError {
            print("Model loading went wrong: \(error)")
        }
        
        return error
    }
    
    func drawVisionRequestResults(_ results: [Any]) {
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        detectionOverlay.sublayers = nil // remove all the old recognized objects
        for observation in results where observation is VNRecognizedObjectObservation {
            guard let objectObservation = observation as? VNRecognizedObjectObservation else {
                continue
            }
            // Select only the label with the highest confidence.
            let topLabelObservation = objectObservation.labels[0]
            let objectBounds = VNImageRectForNormalizedRect(objectObservation.boundingBox, Int(bufferSize.width), Int(bufferSize.height))
            
            let shapeLayer = self.createRoundedRectLayerWithBounds(objectBounds)
            
            let textLayer = self.createTextSubLayerInBounds(objectBounds,
                                                            identifier: topLabelObservation.identifier,
                                                            confidence: topLabelObservation.confidence)
            shapeLayer.addSublayer(textLayer)
            detectionOverlay.addSublayer(shapeLayer)
        }
        self.updateLayerGeometry()
        CATransaction.commit()
    }
    
    override func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        
        let exifOrientation = exifOrientationFromDeviceOrientation()
        
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: exifOrientation, options: [:])
        do {
            try imageRequestHandler.perform(self.requests)
        } catch {
            print(error)
        }
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // Keine Aktualisierungen erforderlich
    }
    
    func processPixelBuffer(_ pixelBuffer: CVPixelBuffer) {
        guard let modelURL = Bundle.main.url(forResource: "FruitsObjectDetectoriOS", withExtension: "mlmodelc"),
              let compiledModel = try? MLModel(contentsOf: modelURL) else {
            print("Failed to load ML model.")
            return
        }
        
        do {
            let visionModel = try VNCoreMLModel(for: compiledModel)
            let request = VNCoreMLRequest(model: visionModel) { request, error in
                if let results = request.results as? [VNRecognizedObjectObservation] {
                    DispatchQueue.main.async {
                        self.detectionResults = results
                    }
                } else if let error = error {
                    print("Error during Vision request: \(error)")
                }
            }

            let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
            try handler.perform([request])

        } catch {
            print("Error creating Vision model or performing request: \(error)")
        }
    }
}
 */

/*
struct ContentView: View {
    @State private var cameraManager = CameraManager()
    @State private var detectionResults: [VNRecognizedObjectObservation] = []
    @State private var isRunning = true

    var body: some View {
        VStack {
            Text("iOS Object Detection")
                .font(.headline)
                .padding()
            
            

            Button(isRunning ? "Stop Detection" : "Start Detection") {
                if isRunning {
                    cameraManager.stopCamera()
                    isRunning = false
                } else {
                    cameraManager.startCamera()
                    isRunning = true
                }
            }
            .padding()

            if !detectionResults.isEmpty {
                Text("Detected Objects:")
                    .font(.headline)
                    .padding(.top, 20)
                List(detectionResults, id: \.self) { result in
                    VStack(alignment: .leading) {
                        Text("Object: \(result.labels.first?.identifier ?? "Unknown")")
                        Text(String(format: "Confidence: %.2f%%", (result.labels.first?.confidence ?? 0) * 100))
                    }
                }
            } else {
                Text("No objects detected.")
                    .foregroundColor(.gray)
                    .padding(.top, 20)
            }
        }
        .onAppear {
            cameraManager.onPixelBufferCaptured = { pixelBuffer in
                processPixelBuffer(pixelBuffer)
            }
        }
        .onDisappear {
            cameraManager.stopCamera()
        }
    }

    func processPixelBuffer(_ pixelBuffer: CVPixelBuffer) {
        guard let modelURL = Bundle.main.url(forResource: "FruitsObjectDetectoriOS", withExtension: "mlmodelc"),
              let compiledModel = try? MLModel(contentsOf: modelURL) else {
            print("Failed to load ML model.")
            return
        }
        
        do {
            let visionModel = try VNCoreMLModel(for: compiledModel)
            let request = VNCoreMLRequest(model: visionModel) { request, error in
                if let results = request.results as? [VNRecognizedObjectObservation] {
                    DispatchQueue.main.async {
                        self.detectionResults = results
                    }
                } else if let error = error {
                    print("Error during Vision request: \(error)")
                }
            }

            let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
            try handler.perform([request])

        } catch {
            print("Error creating Vision model or performing request: \(error)")
        }
    }
}

#Preview {
    ContentView()
}
*/

/*
 
 import SwiftUI
 
 struct ContentView: View {
 var body: some View {
 VStack {
 Image(systemName: "globe")
 .imageScale(.large)
 .foregroundStyle(.tint)
 Text("Hello, world!")
 }
 .padding()
 }
 }
 
 #Preview {
 ContentView()
 }
 */
