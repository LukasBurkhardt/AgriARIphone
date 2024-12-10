//
//  CameraManager.swift
//  AgriARIphone
//
//  Created by Lukas Burkhardt on 09.12.24.
//

import AVFoundation

class CameraManager: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    private let captureSession = AVCaptureSession()
    var onPixelBufferCaptured: ((CVPixelBuffer) -> Void)?

    func startCamera() {
        let captureSession = AVCaptureSession()
        guard let captureDevice = AVCaptureDevice.default(for: .video) else {
            print("No camera available.")
            return
        }

        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
            }
        } catch {
            print("Error configuring camera input: \(error)")
            return
        }

        let videoOutput = AVCaptureVideoDataOutput()
        let queue = DispatchQueue(label: "videoQueue")
        videoOutput.setSampleBufferDelegate(self, queue: queue)

        if captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
        }

        self.captureSession.beginConfiguration()
        self.captureSession.startRunning()
    }

    func stopCamera() {
        captureSession.stopRunning()
        //captureSession = nil
    }
    
    func startCameraSession() {
        captureSession.startRunning()
        //captureSession = nil
    }

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            print("Failed to get pixel buffer.")
            return
        }

        onPixelBufferCaptured?(pixelBuffer)
    }
}
