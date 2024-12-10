//
//  CameraManager2.swift
//  AgriARIphone
//
//  Created by Lukas Burkhardt on 09.12.24.
//

import SwiftUI
import Vision
import AVFoundation

struct CameraManager2: UIViewRepresentable {
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
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // Keine Aktualisierungen erforderlich
    }
}
