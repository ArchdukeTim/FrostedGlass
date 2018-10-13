import UIKit
import AVFoundation

protocol FrameExtractorDelegate: class {
    func captured(image: UIImage)
}

class FrameExtractor: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    private let position = AVCaptureDevice.Position.back
    private let quality = AVCaptureSession.Preset.vga640x480
    
    private var permissionGranted = false
    private let sessionQueue = DispatchQueue(label: "session queue")
    let captureSession = AVCaptureSession()
    var cd: AVCaptureDevice = AVCaptureDevice.default(for: .video)!
    private let context = CIContext()
    
    weak var delegate: FrameExtractorDelegate?
    
    override init() {
        super.init()
        checkPermission()
        sessionQueue.async { [unowned self] in
            self.configureSession()
            self.captureSession.startRunning()
        }
    }
    
    // MARK: AVSession configuration
    private func checkPermission() {
        switch AVCaptureDevice.authorizationStatus(for: AVMediaType.video) {
        case .authorized:
            permissionGranted = true
        case .notDetermined:
            requestPermission()
        default:
            permissionGranted = false
        }
    }
    
    private func requestPermission() {
        sessionQueue.suspend()
        AVCaptureDevice.requestAccess(for: AVMediaType.video) { [unowned self] granted in
            self.permissionGranted = granted
            self.sessionQueue.resume()
        }
    }
    
    private func configureSession() {
        guard permissionGranted else { return }
        //captureSession.sessionPreset = quality
        guard let captureDevice = selectCaptureDevice() else {  return }
        guard let captureDeviceInput = try? AVCaptureDeviceInput(device: captureDevice) else {return }
        guard captureSession.canAddInput(captureDeviceInput) else { return }
        captureSession.addInput(captureDeviceInput)
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "sample buffer"))
        guard captureSession.canAddOutput(videoOutput) else { return }
        captureSession.addOutput(videoOutput)
        guard let connection = videoOutput.connection(with: .video) else { return }
        guard connection.isVideoOrientationSupported else { return }
        guard connection.isVideoMirroringSupported else { return }
        connection.videoOrientation = .portrait
        connection.isVideoMirrored = position == .front
    }
    
    private func selectCaptureDevice() -> AVCaptureDevice? {
        var bestFormat: AVCaptureDevice.Format? = nil
        var bestRange: AVFrameRateRange? = nil
        for format in cd.formats {
            if format.maxISO > bestFormat?.maxISO ?? 0 {
                bestFormat = format
                bestRange = nil
                for range: AVFrameRateRange in format.videoSupportedFrameRateRanges {
                    if range.maxFrameRate > bestRange?.maxFrameRate ?? 0{
                        bestRange = range
                    }
                }
            }
        }
        
        if (bestFormat != nil) {
            do {
                try cd.lockForConfiguration()
                cd.activeFormat = bestFormat!
                cd.activeVideoMinFrameDuration = bestRange!.minFrameDuration
                cd.activeVideoMaxFrameDuration = bestRange!.maxFrameDuration
                cd.focusMode = .continuousAutoFocus
                cd.setExposureModeCustom(duration: cd.exposureDuration, iso: cd.activeFormat.maxISO, completionHandler: nil)
                cd.unlockForConfiguration()
            } catch {
                return cd
            }
          
        }
        
        return cd
    
        }
        
    
    
    // MARK: Sample buffer to UIImage conversion
    private func imageFromSampleBuffer(sampleBuffer: CMSampleBuffer) -> UIImage? {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return nil }
        let ciImage = CIImage(cvPixelBuffer: imageBuffer)
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else { return nil }
        return UIImage(cgImage: cgImage)
    }
    
    // MARK: AVCaptureVideoDataOutputSampleBufferDelegate
    func captureOutput(_ output: AVCaptureOutput,
                                didOutput sampleBuffer: CMSampleBuffer,
                                from connection: AVCaptureConnection) {
        guard let uiImage = imageFromSampleBuffer(sampleBuffer: sampleBuffer) else { return }
        DispatchQueue.main.async { [unowned self] in
            self.delegate?.captured(image: uiImage)
        }
    }
}
