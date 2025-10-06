import SwiftUI
import AVFoundation

struct BarcodeScannerView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = BarcodeScannerViewModel()
    let onBarcodeScanned: (String) -> Void

    var body: some View {
        NavigationView {
            ZStack {
                // Camera preview
                BarcodeCameraPreview(session: viewModel.captureSession)
                    .ignoresSafeArea()

                // Scanning overlay
                VStack {
                    Spacer()

                    // Scanning frame
                    Rectangle()
                        .stroke(Color.green, lineWidth: 3)
                        .frame(width: 280, height: 200)
                        .overlay(
                            VStack {
                                if viewModel.isScanning {
                                    Text("Scanning...")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .padding(8)
                                        .background(Color.black.opacity(0.7))
                                        .cornerRadius(8)
                                } else {
                                    Text("Position barcode in frame")
                                        .font(.subheadline)
                                        .foregroundColor(.white)
                                        .padding(8)
                                        .background(Color.black.opacity(0.7))
                                        .cornerRadius(8)
                                }
                            }
                        )

                    Spacer()

                    // Instructions
                    VStack(spacing: 8) {
                        Text("Align barcode within the frame")
                            .font(.headline)
                            .foregroundColor(.white)

                        Text("The barcode will be scanned automatically")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding()
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(12)
                    .padding()
                }
            }
            .navigationTitle("Scan Barcode")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    if viewModel.torchAvailable {
                        Button(action: { viewModel.toggleTorch() }) {
                            Image(systemName: viewModel.torchOn ? "flashlight.on.fill" : "flashlight.off.fill")
                                .foregroundColor(.white)
                        }
                    }
                }
            }
            .alert("Camera Access Required", isPresented: $viewModel.showPermissionAlert) {
                Button("Settings") {
                    if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(settingsURL)
                    }
                }
                Button("Cancel", role: .cancel) {
                    dismiss()
                }
            } message: {
                Text("Please allow camera access in Settings to scan barcodes.")
            }
            .alert("Error", isPresented: $viewModel.showErrorAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(viewModel.errorMessage)
            }
        }
        .onAppear {
            viewModel.startScanning { barcode in
                onBarcodeScanned(barcode)
                dismiss()
            }
        }
        .onDisappear {
            viewModel.stopScanning()
        }
    }
}

// Camera preview layer
struct BarcodeCameraPreview: UIViewRepresentable {
    let session: AVCaptureSession

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        view.backgroundColor = .black

        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)

        context.coordinator.previewLayer = previewLayer

        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        DispatchQueue.main.async {
            context.coordinator.previewLayer?.frame = uiView.bounds
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator {
        var previewLayer: AVCaptureVideoPreviewLayer?
    }
}

// ViewModel for barcode scanner
class BarcodeScannerViewModel: NSObject, ObservableObject, AVCaptureMetadataOutputObjectsDelegate {
    @Published var isScanning = false
    @Published var showPermissionAlert = false
    @Published var showErrorAlert = false
    @Published var errorMessage = ""
    @Published var torchOn = false
    @Published var torchAvailable = false

    let captureSession = AVCaptureSession()
    private var onBarcodeScanned: ((String) -> Void)?

    override init() {
        super.init()
    }

    func startScanning(onBarcodeScanned: @escaping (String) -> Void) {
        self.onBarcodeScanned = onBarcodeScanned

        checkCameraPermission { [weak self] granted in
            if granted {
                self?.setupCaptureSession()
            } else {
                DispatchQueue.main.async {
                    self?.showPermissionAlert = true
                }
            }
        }
    }

    func stopScanning() {
        if captureSession.isRunning {
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                self?.captureSession.stopRunning()
            }
        }
        torchOff()
    }

    func toggleTorch() {
        if torchOn {
            torchOff()
        } else {
            torchOnFunc()
        }
    }

    private func torchOnFunc() {
        guard let device = AVCaptureDevice.default(for: .video), device.hasTorch else { return }

        do {
            try device.lockForConfiguration()
            device.torchMode = .on
            torchOn = true
            device.unlockForConfiguration()
        } catch {
            print("Torch could not be used")
        }
    }

    private func torchOff() {
        guard let device = AVCaptureDevice.default(for: .video), device.hasTorch else { return }

        do {
            try device.lockForConfiguration()
            device.torchMode = .off
            torchOn = false
            device.unlockForConfiguration()
        } catch {
            print("Torch could not be turned off")
        }
    }

    private func checkCameraPermission(completion: @escaping (Bool) -> Void) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            completion(true)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                completion(granted)
            }
        default:
            completion(false)
        }
    }

    private func setupCaptureSession() {
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            DispatchQueue.main.async {
                self.errorMessage = "Camera not available"
                self.showErrorAlert = true
            }
            return
        }

        // Check if torch is available
        DispatchQueue.main.async {
            self.torchAvailable = videoCaptureDevice.hasTorch
        }

        let videoInput: AVCaptureDeviceInput

        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Could not create video input"
                self.showErrorAlert = true
            }
            return
        }

        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        } else {
            DispatchQueue.main.async {
                self.errorMessage = "Could not add video input"
                self.showErrorAlert = true
            }
            return
        }

        let metadataOutput = AVCaptureMetadataOutput()

        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)

            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.ean8, .ean13, .upce, .code128, .code39]
        } else {
            DispatchQueue.main.async {
                self.errorMessage = "Could not add metadata output"
                self.showErrorAlert = true
            }
            return
        }

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession.startRunning()
            DispatchQueue.main.async {
                self?.isScanning = true
            }
        }
    }

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard let metadataObject = metadataObjects.first,
              let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject,
              let barcode = readableObject.stringValue else {
            return
        }

        // Vibration feedback
        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))

        // Call the callback with the scanned barcode
        onBarcodeScanned?(barcode)

        // Stop scanning after first successful scan
        stopScanning()
    }
}
