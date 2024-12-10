//
//  CameraManager3.swift
//  AgriARIphone
//
//  Created by Lukas Burkhardt on 10.12.24.
//
import SwiftUI
import AVFoundation
import Vision

struct CameraManager3: UIViewRepresentable {
    @Binding var detectedObject: String

    class Coordinator: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
        var parent: CameraManager3

        init(_ parent: CameraManager3) {
            self.parent = parent
        }

        func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
            guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
                return
            }

            let request = VNCoreMLRequest(model: parent.visionModel) { request, error in
                guard let results = request.results as? [VNRecognizedObjectObservation],
                      let firstResult = results.first else {
                    DispatchQueue.main.async {
                        self.parent.detectedObject = "Kein Objekt erkannt"
                    }
                    return
                }

                let topLabel = firstResult.labels.first?.identifier ?? "Unbekannt"
                DispatchQueue.main.async {
                    self.parent.detectedObject = "Erkanntes Objekt: \(topLabel)"
                }
            }

            let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
            try? handler.perform([request])
        }
    }

    let captureSession = AVCaptureSession()
    let visionModel: VNCoreMLModel

    init(detectedObject: Binding<String>, modelName: String) {
        self._detectedObject = detectedObject

        // Lade das ML-Modell
        guard let modelURL = Bundle.main.url(forResource: modelName, withExtension: "mlmodelc"),
              let mlModel = try? MLModel(contentsOf: modelURL),
              let visionModel = try? VNCoreMLModel(for: mlModel) else {
            fatalError("Fehler beim Laden des ML-Modells.")
        }

        self.visionModel = visionModel
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)

        guard let captureDevice = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: captureDevice) else {
            return view
        }

        captureSession.addInput(input)

        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(context.coordinator, queue: DispatchQueue(label: "videoQueue"))

        captureSession.addOutput(videoOutput)

        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = view.layer.bounds
        view.layer.addSublayer(previewLayer)

        captureSession.startRunning()

        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}
